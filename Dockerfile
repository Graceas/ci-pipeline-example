FROM docker-registry.default.svc:5000/python:3.8-slim

MAINTAINER AG_

ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_USER_HOME=/usr/local/af
ARG AIRFLOW_HOME=/usr/local/af/airflow

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8

RUN set -ex \
    && buildDeps=' \
        python3-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        build-essential \
        libblas-dev \
        liblapack-dev \
        libpq-dev \
        git \
    ' \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        python3-pip \
        python3-requests \
        apt-utils \
        curl \
        rsync \
        netcat \
        krb5-user \
        telnet \
        vim \
        zip \
        dnsutils \
        iputils-ping \
        locales \
        postgresql-client \
        moreutils \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd -ms /bin/bash -d ${AIRFLOW_USER_HOME} af

COPY ./requirements.txt /requirements.txt
RUN pip install -U pip setuptools wheel && pip install -r /requirements.txt
RUN apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

COPY . ${AIRFLOW_USER_HOME}/
COPY app/config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg
COPY app/config/unittests.cfg ${AIRFLOW_HOME}/unittests.cfg
COPY app/config/krb5.conf /etc/krb5.conf

COPY app/bin/scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV PYTHONPATH ${AIRFLOW_USER_HOME}/
ENV DAGS_PATH ${AIRFLOW_HOME}/dags/

RUN mkdir -p /storage
RUN chmod -R 777 /storage

RUN chown -R af: ${AIRFLOW_USER_HOME}
RUN chmod -R 777 ${AIRFLOW_USER_HOME}/app/logs

EXPOSE 8080 5555 8793

USER af
WORKDIR ${AIRFLOW_USER_HOME}

ENTRYPOINT ["/entrypoint.sh"]
