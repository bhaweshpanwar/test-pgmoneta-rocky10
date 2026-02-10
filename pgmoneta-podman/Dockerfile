FROM rockylinux:8

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm \
 && rpm -Uvh https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
 && dnf -y update \
 && dnf -y module disable postgresql \
 && dnf -y install postgresql14 \
 && dnf -y install pgmoneta \
 && dnf -y clean all

RUN useradd -ms /bin/bash pgmoneta

COPY root/ /

RUN mkdir -p /conf /pgmoneta
COPY conf/pgmoneta.conf /conf/
RUN chown -R pgmoneta:pgmoneta /conf /pgmoneta
RUN chmod 700 /conf /pgmoneta

VOLUME ["/pgmoneta"]

EXPOSE 5001

USER pgmoneta
WORKDIR /home/pgmoneta

CMD ["/usr/bin/run-pgmoneta"]