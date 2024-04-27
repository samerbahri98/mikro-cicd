FROM docker/buildx-bin:0.14.0 as buildx
FROM docker/compose-bin:v2.27.0 as compose

####################  DOWNLOADER  ####################

FROM debian:bookworm-slim as downloader

WORKDIR /tmp
ARG SEMAPHORE_VERSION=2.9.64
ADD https://github.com/ansible-semaphore/semaphore/releases/download/v${SEMAPHORE_VERSION}/semaphore_${SEMAPHORE_VERSION}_linux_amd64.tar.gz ./semaphore.tar.gz
RUN tar -zxvf semaphore.tar.gz
RUN chmod 755 /tmp/semaphore

## DOCKER
ARG DOCKER_VERSION=23.0.1
ADD https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VERSION.tgz .
RUN tar -zxvf docker-$DOCKER_VERSION.tgz

## MC
# https://dl.min.io/client/mc/release/linux-amd64/
ARG MC_VERSION=RELEASE.2024-04-18T16-45-29Z
ARG MC_CHECKSUM=ff54d2d6a6fad91a0b1383a3ce515852b2b3901697166f3ce6f17d698f5711d4
ADD https://dl.min.io/client/mc/release/linux-amd64/archive/mc.$MC_VERSION ./mc
RUN echo $MC_CHECKSUM mc > mc.sha256sum
RUN sha256sum -c mc.sha256sum && chmod 755 /tmp/mc

## Task
# https://github.com/go-task/task/releases/
ARG TASK_VERSION=v3.36.0
ARG TASK_CHECKSUM=e2b1d50129db500746e1ed35a4e43f9bebc1ae5849d87b2d12e6a98512eae56f
ADD https://github.com/go-task/task/releases/download/$TASK_VERSION/task_linux_amd64.tar.gz .
RUN echo $TASK_CHECKSUM task_linux_amd64.tar.gz > task_linux_amd64.sha256sum
RUN sha256sum -c task_linux_amd64.sha256sum
RUN tar -zxvf task_linux_amd64.tar.gz && chmod 755 /tmp/task


####################  ANSIBLE-RUNNER  ####################
FROM python:3.12-bookworm as ansible-runner

ENV TZ="Europe/Budapest"

COPY requirements.txt /tmp/

RUN pip install -r /tmp/requirements.txt \
      && rm /tmp/requirements.txt \
      && apt update && apt install -y dumb-init \
      && rm -rf /var/lib/{apt,dpkg,cache,log}/* /var/log/* 

VOLUME /runner

WORKDIR /runner

ENV HOME=/home/runner

COPY --chmod=755 ./entrypoint.sh /entrypoint.sh

RUN for dir in \
      /home/runner \
      /home/runner/.ansible \
      /home/runner/.ansible/tmp \
      /runner \
      /home/runner \
      /runner/env \
      /runner/inventory \
      /runner/project \
      /runner/artifacts ; \
    do mkdir -m 0775 -p $dir ; chmod -R g+rwx $dir ; chgrp -R root $dir ; done && \
    for file in \
      /home/runner/.ansible/galaxy_token \
      /etc/passwd \
      /etc/group ; \
    do touch $file ; chmod g+rw $file ; chgrp root $file ; done

ENTRYPOINT ["/entrypoint.sh"]
CMD ["ansible-runner", "run", "/runner"]


####################  ANSIBLE-EE  ####################

FROM ansible-runner as ansible-ee

COPY ./ee/requirements.txt ./ee/requirements.yml /tmp/

RUN pip install -r /tmp/requirements.txt \
  && ansible-galaxy install -r /tmp/requirements.yml \
  && rm /tmp/requirements.txt /tmp/requirements.yml

COPY --from=downloader /tmp/mc /usr/bin/mc
COPY --from=downloader /tmp/task /usr/bin/task
COPY --from=downloader /tmp/docker/* /usr/bin/
COPY --from=buildx /buildx /usr/local/lib/docker/cli-plugins/docker-buildx
COPY --from=compose /docker-compose /usr/local/lib/docker/cli-plugins/docker-compose

####################  SEMAPHORE-SERVER  ####################

FROM debian:bookworm-slim as semaphore-server

ENV TZ="Europe/Budapest"

COPY --from=downloader /tmp/semaphore /usr/bin/semaphore

RUN mkdir /var/www && chown www-data:www-data /var/www

USER www-data

ENTRYPOINT [ "/usr/bin/semaphore" ]
CMD ["service", "--config=/etc/semaphore/config.json"]

####################  SEMAPHORE-RUNNER  ####################

FROM ansible-ee as semaphore-runner

ENV TZ="Europe/Budapest"

COPY --from=downloader /tmp/semaphore /usr/bin/semaphore

RUN mkdir /var/www && chown www-data:www-data /var/www

USER www-data

ENTRYPOINT [ "/usr/bin/semaphore" ]
CMD ["ruuner", "--config=/etc/semaphore/config.json"]
