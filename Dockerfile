ARG IMAGE
ARG IMAGE_TAG
FROM ${IMAGE:-alpine}:${IMAGE_TAG:-3}

ENV SPIDER_INSTALL_DIR=${SPIDER_INSTALL_DIR:-/spider}
ENV SPIDER_USERNAME=${SPIDER_USERNAME:-sysop} SPIDER_UID=${SPIDER_UID:-1000}

RUN export SPIDER_GIT_REPOSITORY=${SPIDER_GIT_REPOSITORY:-git://scm.dxcluster.org/scm/spider} && \
    export SPIDER_VERSION=${SPIDER_VERSION:-HEAD} && \
    apk update && \
    apk add gcc git make \
    musl-dev ncurses-libs ncurses-dev \
    perl-db_file perl-dev perl-digest-sha1 perl-io-socket-ssl perl-net-telnet perl-timedate perl-yaml-libyaml \
    perl-test-simple perl-app-cpanminus && \
    cpanm --no-wget Curses && \
    cpanm --no-wget Redis && \
    adduser -D -u $SPIDER_UID -h ${SPIDER_INSTALL_DIR} $SPIDER_USERNAME && \
    git clone $SPIDER_GIT_REPOSITORY ${SPIDER_INSTALL_DIR} &&  \
    (cd $SPIDER_INSTALL_DIR && git reset --hard $SPIDER_VERSION) && \
    mkdir -p ${SPIDER_INSTALL_DIR}/local ${SPIDER_INSTALL_DIR}/local_cmd && \
    find ${SPIDER_INSTALL_DIR}/. -type d -exec chmod 2775 {} \; && \
    find ${SPIDER_INSTALL_DIR}/. -type f -name '*.pl' -exec chmod 775 {} \; && \
    (cd ${SPIDER_INSTALL_DIR}/src && make) && \
    chown -R ${SPIDER_USERNAME}:${SPIDER_USERNAME} ${SPIDER_INSTALL_DIR}/. && \
    apk del --purge gcc git make \
    musl-dev ncurses-dev perl-app-cpanminus perl-dev && \
    rm -rf /var/cache/apk/* && \
    unset SPIDER_GIT_REPOSITORY SPIDER_VERSION TMPDIR

USER $SPIDER_UID
# ENTRYPOINT ["/bin/sh"]

# CMD ["/entrypoint.sh"]