ARG IMAGE=alpine
ARG IMAGE_TAG=3.9

FROM ${IMAGE}:${IMAGE_TAG}

ARG SPIDER_BRANCH=mojo
ARG SPIDER_VERSION=HEAD
ARG SPIDER_GIT_REPOSITORY=git://scm.dxcluster.org/scm/spider
ARG SPIDER_INSTALL_DIR=/spider

ENV SPIDER_USERNAME=${SPIDER_USERNAME:-sysop} SPIDER_UID=${SPIDER_UID:-1000}

RUN apk update && \
    apk add gcc git make \
    musl-dev ncurses-libs ncurses-dev \
    perl-db_file perl-dev perl-digest-sha1 perl-io-socket-ssl perl-net-telnet perl-timedate perl-yaml-libyaml \
    perl-test-simple perl-app-cpanminus && \
    cpanm --no-wget Curses && \
    cpanm --no-wget Redis && \
    cpanm --no-wget Data::Structure::Util && \
    cpanm --no-wget Mojo::IOLoop && \
    cpanm --no-wget JSON && \
    cpanm --no-wget Math::Round && \
    adduser -D -u $SPIDER_UID -h ${SPIDER_INSTALL_DIR} $SPIDER_USERNAME && \
    git clone -b ${SPIDER_BRANCH} ${SPIDER_GIT_REPOSITORY} ${SPIDER_INSTALL_DIR} && \
    (cd ${SPIDER_INSTALL_DIR} && git reset --hard ${SPIDER_VERSION}) && \
    mkdir -p ${SPIDER_INSTALL_DIR}/local ${SPIDER_INSTALL_DIR}/local_cmd && \
    find ${SPIDER_INSTALL_DIR}/. -type d -exec chmod 2775 {} \; && \
    find ${SPIDER_INSTALL_DIR}/. -type f -name '*.pl' -exec chmod 775 {} \; && \
    (cd ${SPIDER_INSTALL_DIR}/src && make) && \
    chown -R ${SPIDER_USERNAME}:${SPIDER_USERNAME} ${SPIDER_INSTALL_DIR}/. && \
    apk del --purge gcc git make \
    musl-dev ncurses-dev perl-app-cpanminus perl-dev && \
    rm -rf /var/cache/apk/*

USER $SPIDER_UID
# ENTRYPOINT ["/bin/sh"]

# CMD ["/entrypoint.sh"]