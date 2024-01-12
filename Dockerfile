# syntax=docker/dockerfile:1

ARG BUILDKIT_SBOM_SCAN_STAGE=true
ARG BUILDKIT_SBOM_SCAN_CONTEXT=true
ARG UBUNTU_RELEASE=18.04

#############################################
# Base layer
#############################################

FROM ubuntu:$UBUNTU_RELEASE AS base-layer

COPY --chown=root:root ["docker-install-base.sh", "/root"]

RUN --mount=id=pritunl-apt-lists,target=/var/lib/apt,type=cache \
    --mount=id=pritunl-apt-cache,target=/var/cache/apt,type=cache \
    bash /root/docker-install-base.sh && rm /root/docker-install-base.sh

#############################################
# MongoDB layer
#############################################

FROM base-layer AS monogodb-layer

COPY --chown=root:root ["docker-install-mongo.sh", "/root"]

ARG MONGODB_VERSION="*"
ENV MONGODB_VERSION=${MONGODB_VERSION}

RUN --mount=id=pritunl-apt-lists,target=/var/lib/apt,type=cache \
    --mount=id=pritunl-apt-cache,target=/var/cache/apt,type=cache \
    bash /root/docker-install-mongo.sh && rm /root/docker-install-mongo.sh

#############################################
# Final/runtime layer
#############################################

FROM monogodb-layer

ARG PRITUNL_VERSION="*"
ENV PRITUNL_VERSION=${PRITUNL_VERSION}

COPY --chown=root:root ["docker-install-pritunl.sh", "/root"]

RUN --mount=id=pritunl-apt-lists,target=/var/lib/apt,type=cache \
    --mount=id=pritunl-apt-cache,target=/var/cache/apt,type=cache \
    --mount=id=pritunl-cache,target=/pritunl/cache,type=cache \
    bash /root/docker-install-pritunl.sh && rm /root/docker-install-pritunl.sh

ADD start-pritunl /bin/start-pritunl

EXPOSE 80
EXPOSE 443
EXPOSE 1194
EXPOSE 1194/udp
EXPOSE 1195/udp
EXPOSE 9700/tcp

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
