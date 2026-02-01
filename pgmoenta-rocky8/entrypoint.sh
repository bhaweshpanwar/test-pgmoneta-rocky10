#!/bin/bash
set -e

# Config file paths — pgmoneta reads from here
PGMONETA_CONFIG_FILE="/etc/pgmoneta/pgmoneta.conf"
PGMONETA_USERS_FILE="/etc/pgmoneta/pgmoneta_users.conf"

# These are the only directories pgmoneta actually needs
mkdir -p /home/pgmoneta/logs
mkdir -p /home/pgmoneta/backups

# --- CONFIG SETUP ---
# Only runs on first start (when no config exists)
if [ ! -f "${PGMONETA_CONFIG_FILE}" ]; then
    echo "No configuration file found. Creating from environment..."

    # Validate required env vars
    if [ -z "${DB_HOST}" ]; then
        echo "ERROR: DB_HOST is not set"
        exit 1
    fi

    if [ -z "${DB_PORT}" ]; then
        echo "ERROR: DB_PORT is not set"
        exit 1
    fi

    # Generate the config file directly — no template, no sed
    cat > "${PGMONETA_CONFIG_FILE}" <<EOF
[pgmoneta]
host = *
metrics = 5000
create_slot = yes
base_dir = /home/pgmoneta/backups
compression = none
storage_engine = local
retention = 7
log_type = file
log_level = info
log_path = /home/pgmoneta/logs/pgmoneta.log
unix_socket_dir = /tmp/

[primary]
host = ${DB_HOST}
port = ${DB_PORT}
user = repl
wal_slot = repl
EOF
    echo "Config created at ${PGMONETA_CONFIG_FILE}"
fi

# --- MASTER KEY SETUP ---
if [ ! -f /home/pgmoneta/.pgmoneta/master.key ]; then
    if [ -z "${PGMONETA_MASTER_KEY}" ]; then
        echo "ERROR: PGMONETA_MASTER_KEY is not set"
        exit 1
    fi
    echo "Setting up master key..."
    echo "${PGMONETA_MASTER_KEY}" | pgmoneta-admin master-key
fi

# --- USERS FILE SETUP ---
if [ ! -f "${PGMONETA_USERS_FILE}" ]; then
    echo "Creating users file..."
    touch "${PGMONETA_USERS_FILE}"

    if [ -n "${REPL_PASSWORD}" ]; then
        echo "Adding repl user..."
        pgmoneta-admin -f "${PGMONETA_USERS_FILE}" -U repl -P "${REPL_PASSWORD}" user add
    else
        echo "WARNING: REPL_PASSWORD not set. Skipping repl user."
    fi
fi

# --- START ---
echo "Starting pgmoneta..."
exec pgmoneta -c "${PGMONETA_CONFIG_FILE}" -u "${PGMONETA_USERS_FILE}"