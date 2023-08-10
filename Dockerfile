# Docker image for rarbg using the alpine template
ARG LICENSE="MIT"
ARG IMAGE_NAME="rarbg"
ARG PHP_SERVER="rarbg"
ARG BUILD_DATE="Mon Jul  3 05:05:08 PM EDT 2023"
ARG LANGUAGE="en_US.UTF-8"
ARG TIMEZONE="America/New_York"
ARG WWW_ROOT_DIR="/data/htdocs"
ARG DEFAULT_FILE_DIR="/usr/local/share/template-files"
ARG DEFAULT_DATA_DIR="/usr/local/share/template-files/data"
ARG DEFAULT_CONF_DIR="/usr/local/share/template-files/config"
ARG DEFAULT_TEMPLATE_DIR="/usr/local/share/template-files/defaults"

ARG IMAGE_REPO="casjaysdev/alpine"
ARG IMAGE_VERSION="latest"
ARG CONTAINER_VERSION="${IMAGE_VERSION}"

ARG SERVICE_PORT="3333"
ARG EXPOSE_PORTS="3333"
ARG PHP_VERSION="php81"

ARG USER="root"
ARG DISTRO_VERSION="${IMAGE_VERSION}"
ARG BUILD_VERSION="${DISTRO_VERSION}"

FROM tianon/gosu:latest AS gosu
FROM ghcr.io/casjaysdevdocker/rarbg:latest AS src
FROM ${IMAGE_REPO}:${DISTRO_VERSION} AS build
ARG USER
ARG LICENSE
ARG TIMEZONE
ARG LANGUAGE
ARG IMAGE_NAME
ARG PHP_SERVER
ARG BUILD_DATE
ARG SERVICE_PORT
ARG EXPOSE_PORTS
ARG BUILD_VERSION
ARG WWW_ROOT_DIR
ARG DEFAULT_FILE_DIR
ARG DEFAULT_DATA_DIR
ARG DEFAULT_CONF_DIR
ARG DEFAULT_TEMPLATE_DIR
ARG DISTRO_VERSION
ARG PHP_VERSION

ARG PACK_LIST="bash bash-completion git curl wget sudo unzip iproute2 ssmtp openssl jq ca-certificates tzdata mailcap ncurses util-linux pciutils usbutils coreutils binutils findutils grep rsync zip certbot tini certbot py3-pip procps net-tools coreutils sed gawk grep attr findutils readline lsof less curl shadow \
  "

ENV ENV=~/.bashrc
ENV SHELL="/bin/sh"
ENV TZ="${TIMEZONE}"
ENV TIMEZONE="${TZ}"
ENV LANG="${LANGUAGE}"
ENV TERM="xterm-256color"
ENV HOSTNAME="casjaysdev-rarbg"

USER ${USER}
WORKDIR /root

RUN set -ex ; \
  echo ""

COPY --from=gosu /usr/local/bin/gosu /usr/local/bin/gosu
COPY --from=src /rarbg-selfhosted /usr/local/bin/rarbg

COPY ./rootfs/. /
COPY ./Dockerfile /root/Dockerfile

RUN set -ex ; \
  echo ""

RUN set -ex ; \
  rm -Rf "/etc/apk/repositories"; \
  [ "$DISTRO_VERSION" = "latest" ] && DISTRO_VERSION="edge"; \
  [ "$DISTRO_VERSION" = "edge" ] || DISTRO_VERSION="v${DISTRO_VERSION}" ; \
  mkdir -p "${DEFAULT_DATA_DIR}" "${DEFAULT_CONF_DIR}" "${DEFAULT_TEMPLATE_DIR}"; \
  echo "http://dl-cdn.alpinelinux.org/alpine/${DISTRO_VERSION}/main" >>"/etc/apk/repositories"; \
  echo "http://dl-cdn.alpinelinux.org/alpine/${DISTRO_VERSION}/community" >>"/etc/apk/repositories"; \
  if [ "${DISTRO_VERSION}" = "edge" ]; then echo "http://dl-cdn.alpinelinux.org/alpine/${DISTRO_VERSION}/testing" >>"/etc/apk/repositories" ; fi ; \
  apk -U upgrade --no-cache && apk add --no-cache ${PACK_LIST}

RUN set -ex ; \
  echo "$TIMEZONE" >"/etc/timezone" ; \
  echo 'hosts: files dns' >"/etc/nsswitch.conf" ; \
  [ -f "/usr/share/zoneinfo/${TZ}" ] && ln -sf "/usr/share/zoneinfo/${TZ}" "/etc/localtime" ; \
  PHP_FPM="$(ls /usr/*bin/php*fpm* 2>/dev/null || echo '')" ; \
  [ -n "$PHP_FPM" ] && [ -z "$(type -P php-fpm)" ] && ln -sf "$PHP_FPM" "/usr/bin/php-fpm" || true ; \
  if [ -f "/etc/profile.d/color_prompt.sh.disabled" ]; then mv -f "/etc/profile.d/color_prompt.sh.disabled" "/etc/profile.d/color_prompt.sh"; fi

RUN set -ex ; \
  touch "/etc/profile" "/root/.profile" ; \
  { [ -f "/etc/bash/bashrc" ] && cp -Rf "/etc/bash/bashrc" "/root/.bashrc" ; } || { [ -f "/etc/bashrc" ] && cp -Rf "/etc/bashrc" "/root/.bashrc" ; } || { [ -f "/etc/bash.bashrc" ] && cp -Rf "/etc/bash.bashrc" "/root/.bashrc" ; }; \
  sed -i 's|root:x:.*|root:x:0:0:root:/root:/bin/bash|g' "/etc/passwd" ; \
  grep -s -q 'alias quit' "/root/.bashrc" || printf '# Profile\n\n%s\n%s\n%s\n' '. /etc/profile' '. /root/.profile' "alias quit='exit 0 2>/dev/null'" >>"/root/.bashrc" ; \
  [ -f "/usr/local/etc/docker/env/default.sample" ] && [ -d "/etc/profile.d" ] && \
  cp -Rf "/usr/local/etc/docker/env/default.sample" "/etc/profile.d/container.env.sh" && chmod 755 "/etc/profile.d/container.env.sh" ; \
  BASH_CMD="$(type -P bash)" ; [ -f "$BASH_CMD" ] && rm -rf "/bin/sh" && ln -sf "$BASH_CMD" "/bin/sh" ; \
  pip install certbot-dns-rfc2136

RUN set -ex ; \
  echo

RUN set -ex ; \
  echo 'Running cleanup' ; \
  echo ""

RUN set -ex ; \
  rm -Rf "/config" "/data" ; \
  rm -rf /etc/systemd/system/*.wants/* ; \
  rm -rf /lib/systemd/system/systemd-update-utmp* ; \
  rm -rf /lib/systemd/system/anaconda.target.wants/*; \
  rm -rf /lib/systemd/system/local-fs.target.wants/* ; \
  rm -rf /lib/systemd/system/multi-user.target.wants/* ; \
  rm -rf /lib/systemd/system/sockets.target.wants/*udev* ; \
  rm -rf /lib/systemd/system/sockets.target.wants/*initctl* ; \
  rm -Rf /usr/share/doc/* /usr/share/info/* /tmp/* /var/tmp/* /var/cache/*/* ; \
  if [ -d "/lib/systemd/system/sysinit.target.wants" ]; then cd "/lib/systemd/system/sysinit.target.wants" && rm -f $(ls | grep -v systemd-tmpfiles-setup) ; fi

RUN echo "Init done"

FROM scratch
ARG USER
ARG LICENSE
ARG LANGUAGE
ARG TIMEZONE
ARG IMAGE_NAME
ARG PHP_SERVER
ARG BUILD_DATE
ARG SERVICE_PORT
ARG EXPOSE_PORTS
ARG BUILD_VERSION
ARG DEFAULT_DATA_DIR
ARG DEFAULT_CONF_DIR
ARG DEFAULT_TEMPLATE_DIR
ARG DISTRO_VERSION
ARG PHP_VERSION

USER ${USER}
WORKDIR /root

LABEL maintainer="CasjaysDev <docker-admin@casjaysdev.pro>"
LABEL org.opencontainers.image.vendor="CasjaysDev"
LABEL org.opencontainers.image.authors="CasjaysDev"
LABEL org.opencontainers.image.vcs-type="Git"
LABEL org.opencontainers.image.name="${IMAGE_NAME}"
LABEL org.opencontainers.image.base.name="${IMAGE_NAME}"
LABEL org.opencontainers.image.license="${LICENSE}"
LABEL org.opencontainers.image.vcs-ref="${BUILD_VERSION}"
LABEL org.opencontainers.image.build-date="${BUILD_DATE}"
LABEL org.opencontainers.image.version="${BUILD_VERSION}"
LABEL org.opencontainers.image.schema-version="${BUILD_VERSION}"
LABEL org.opencontainers.image.url="https://hub.docker.com/r/casjaysdevdocker/${IMAGE_NAME}"
LABEL org.opencontainers.image.vcs-url="https://github.com/casjaysdevdocker/${IMAGE_NAME}"
LABEL org.opencontainers.image.url.source="https://github.com/casjaysdevdocker/${IMAGE_NAME}"
LABEL org.opencontainers.image.documentation="https://hub.docker.com/r/casjaysdevdocker/${IMAGE_NAME}"
LABEL org.opencontainers.image.description="Containerized version of ${IMAGE_NAME}"
LABEL com.github.containers.toolbox="false"

ENV ENV=~/.bashrc
ENV SHELL="/bin/bash"
ENV TZ="${TIMEZONE}"
ENV TIMEZONE="${TZ}"
ENV LANG="${LANGUAGE}"
ENV TERM="xterm-256color"
ENV PORT="${SERVICE_PORT}"
ENV ENV_PORTS="${EXPOSE_PORTS}"
ENV PHP_SERVER="${PHP_SERVER}"
ENV PHP_VERSION="${PHP_VERSION}"
ENV CONTAINER_NAME="${IMAGE_NAME}"
ENV HOSTNAME="casjaysdev-${IMAGE_NAME}"
ENV USER="${USER}"
ENV PATH_SQLITE_DB="/data/db/rarbg/database.sqlite"
ENV PATH_TRACKERS="/config/rarbg/trackers.txt"

COPY --from=build /. /

VOLUME [ "/config","/data" ]

EXPOSE ${ENV_PORTS}

CMD [ "start", "all" ]
ENTRYPOINT [ "tini", "--", "/usr/local/bin/entrypoint.sh" ]
HEALTHCHECK --start-period=1m --interval=2m --timeout=3s CMD [ "/usr/local/bin/entrypoint.sh", "healthcheck" ]
