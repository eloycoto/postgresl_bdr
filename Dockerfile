FROM ubuntu:14.04
MAINTAINER ELOY COTO <eloy.coto@foehn.co.uk>

ENV POSTGRES_VERSION=9.4

RUN apt-get install -y -f wget vim

RUN wget --quiet -O - http://packages.2ndquadrant.com/bdr/apt/AA7A6805.asc | apt-key add - && \
    echo "deb http://packages.2ndquadrant.com/bdr/apt/ "$(lsb_release -sc)"-2ndquadrant main" >> /etc/apt/sources.list.d/2ndquadrant.list && \
    wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt "$(lsb_release -sc)"-pgdg main" >> /etc/apt/sources.list

RUN locale-gen --no-purge en_GB.UTF-8
ENV LC_ALL en_GB.UTF-8
RUN update-locale LANG=en_GB.UTF-8

RUN apt-get update && \
    apt-get install -y -f \
        postgresql-bdr-${POSTGRES_VERSION} \
        postgresql-bdr-server-dev-${POSTGRES_VERSION} \
        postgresql-bdr-client-${POSTGRES_VERSION} \
        postgresql-bdr-contrib-${POSTGRES_VERSION} \
        postgresql-bdr-${POSTGRES_VERSION}-dbg \
        postgresql-bdr-${POSTGRES_VERSION}-bdr-plugin && \
        mkdir -p /opt/databases/ && chmod 777 -R /opt/databases && \
        mkdir -p /opt/examples

# USER postgres

# RUN rm -rf /opt/databases/* && \
#     /usr/lib/postgresql/9.4/bin/initdb -D /opt/databases/nodea/ -A trust && \
#     /usr/lib/postgresql/9.4/bin/initdb -D /opt/databases/nodeb/ -A trust && \
#     /usr/lib/postgresql/9.4/bin/bdr_resetxlog -s /opt/databases/nodeb/

COPY *.conf /opt/examples/


COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME /opt/databases
EXPOSE 5432 5423

