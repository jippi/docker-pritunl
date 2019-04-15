FROM debian:stretch-slim

LABEL MAINTAINER="Christian Winther <jippignu@gmail.com>"

RUN apt-get -y update && \
    apt-get -y install gnupg2 && \
    echo "deb http://repo.pritunl.com/stable/apt stretch main" > /etc/apt/sources.list.d/pritunl.list && \
    echo "deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.0 main" > /etc/apt/sources.list.d/mongodb-org-4.0.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 && \
    apt-get -y update && \
    apt-get install -y dirmngr curl procps iptables pritunl mongodb-server && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 80/tcp 443/tcp
EXPOSE 1194/udp

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["pritunl", "start"]
