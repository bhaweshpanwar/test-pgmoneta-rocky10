# Multi-stage build for pgmoneta on Rocky Linux 8
FROM rockylinux/rockylinux:8 AS builder

ENV PGMONETA_VERSION=0.14.0

# Install build dependencies
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
 && rpm -Uvh https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
 && dnf -y update \
 && dnf -y install \
    cmake \
    make \
    gcc \
    openssl-devel \
    zlib-devel \
    zstd \
    lz4-devel \
    bzip2-devel \
    systemd-devel \
    libssh-devel \
    libarchive-devel \
    wget \
 && dnf -y clean all

# Download and build pgmoneta
WORKDIR /tmp
RUN wget https://github.com/pgmoneta/pgmoneta/releases/download/${PGMONETA_VERSION}/pgmoneta-${PGMONETA_VERSION}.tar.gz \
 && tar xzf pgmoneta-${PGMONETA_VERSION}.tar.gz \
 && cd pgmoneta-${PGMONETA_VERSION} \
 && mkdir build \
 && cd build \
 && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. \
 && make \
 && make install

# Final image
FROM rockylinux/rockylinux:8

# Install only runtime dependencies
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
 && dnf -y update \
 && dnf -y install \
    openssl \
    zlib \
    zstd \
    lz4 \
    bzip2 \
    systemd-libs \
    libssh \
    libcurl-minimal \
    libarchive \
    tini \
    procps \
 && dnf -y clean all

# Copy built pgmoneta from builder
COPY --from=builder /usr/local /usr/local

# Create pgmoneta user
RUN useradd -ms /bin/bash pgmoneta

# Create config directory owned by pgmoneta
RUN mkdir -p /etc/pgmoneta \
 && chown pgmoneta:pgmoneta /etc/pgmoneta

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to pgmoneta user
USER pgmoneta
WORKDIR /home/pgmoneta

# Expose ports
# 5000 - pgmoneta metrics
# 9100 - node_exporter (if added later)
EXPOSE 5000

ENTRYPOINT ["tini", "--"]
CMD ["/entrypoint.sh"]