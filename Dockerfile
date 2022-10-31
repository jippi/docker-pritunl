# syntax=docker/dockerfile:1.4

ARG UBUNTU_RELEASE=18.04

FROM ubuntu:$UBUNTU_RELEASE

ARG PRITUNL_VERSION="*"
ENV PRITUNL_VERSION=${PRITUNL_VERSION}

ARG MONGODB_VERSION="*"
ENV MONGODB_VERSION=${MONGODB_VERSION}

COPY --chown=root:root ["docker-install.sh", "/root"]

RUN --mount=id=pritunl-apt-lists,target=/var/lib/apt/lists,type=cache \
    --mount=id=pritunl-apt-cache,target=/var/cache/apt,type=cache \
    --mount=id=pritunl-cache,target=/pritunl/cache,type=cache \
    bash /root/docker-install.sh && rm /root/docker-install.sh

ADD start-pritunl /bin/start-pritunl

EXPOSE 80
EXPOSE 443
EXPOSE 1194
EXPOSE 1194/udp

ENTRYPOINT ["/bin/start-pritunl"]

CMD ["/usr/bin/tail", "-f", "/var/log/pritunl.log", "/var/log/mongodb/mongod.log"]

ARG BUILD_DATE

LABEL org.opencontainers.image.created=${BUILD_DATE}
LABEL org.opencontainers.image.authors="Christian 'Jippi' Winther <github-pritunl@jippi.dev>"
LABEL org.opencontainers.image.url="https://github.com/jippi/docker-pritunl"
LABEL org.opencontainers.image.documentation="https://github.com/jippi/docker-pritunl"
LABEL org.opencontainers.image.source="https://github.com/jippi/docker-pritunl"
LABEL org.opencontainers.image.version=${PRITUNL_VERSION}
LABEL org.opencontainers.image.vendor="Christian 'Jippi' Winther <github-pritunl@jippi.dev>"
LABEL org.opencontainers.image.licenses="MIT"

LABEL org.opencontainers.image.title="Pritunl on Docker"
LABEL org.opencontainers.image.description="Easy way to run Pritunl on Docker"
