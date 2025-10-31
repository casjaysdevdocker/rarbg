# Docker image for rarbg using the alpine template
ARG IMAGE_NAME="rarbg"
ARG PHP_SERVER="rarbg"
ARG BUILD_DATE="202509161150"
ARG LANGUAGE="en_US.UTF-8"
ARG TIMEZONE="America/New_York"
ARG WWW_ROOT_DIR="/usr/local/share/httpd/default"
ARG DEFAULT_FILE_DIR="/usr/local/share/template-files"
ARG DEFAULT_DATA_DIR="/usr/local/share/template-files/data"
ARG DEFAULT_CONF_DIR="/usr/local/share/template-files/config"
ARG DEFAULT_TEMPLATE_DIR="/usr/local/share/template-files/defaults"
ARG PATH="/usr/local/etc/docker/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

ARG USER="root"
ARG SHELL_OPTS="set -e -o pipefail"

ARG SERVICE_PORT=""
ARG EXPOSE_PORTS=""
ARG PHP_VERSION="system"
ARG NODE_VERSION="system"
ARG NODE_MANAGER="system"

ARG IMAGE_REPO="casjaysdevdocker/rarbg"
ARG IMAGE_VERSION="latest"
ARG CONTAINER_VERSION=""

ARG PULL_URL="casjaysdev/alpine"
ARG DISTRO_VERSION="${IMAGE_VERSION}"
ARG BUILD_VERSION="${BUILD_DATE}"

FROM tianon/gosu:latest AS gosu
FROM ${PULL_URL}:${DISTRO_VERSION} AS build
ARG TZ
ARG USER
ARG LICENSE
ARG TIMEZONE
ARG LANGUAGE
ARG IMAGE_NAME
ARG BUILD_DATE
ARG SERVICE_PORT
ARG EXPOSE_PORTS
ARG BUILD_VERSION
ARG IMAGE_VERSION
ARG WWW_ROOT_DIR
ARG DEFAULT_FILE_DIR
ARG DEFAULT_DATA_DIR
ARG DEFAULT_CONF_DIR
ARG DEFAULT_TEMPLATE_DIR
ARG DISTRO_VERSION
ARG NODE_VERSION
ARG NODE_MANAGER
ARG PHP_VERSION
ARG PHP_SERVER
ARG SHELL_OPTS
ARG PATH

ARG PACK_LIST=" "

ENV ENV=~/.profile
ENV SHELL="/bin/sh"
ENV PATH="${PATH}"
ENV TZ="${TIMEZONE}"
ENV TIMEZONE="${TZ}"
ENV LANG="${LANGUAGE}"
ENV TERM="xterm-256color"
ENV HOSTNAME="casjaysdevdocker-rarbg"

USER ${USER}
WORKDIR /root

COPY ./rootfs/usr/local/bin/. /usr/local/bin/

RUN set -e; \
  echo "Updating the system and ensuring bash is installed"; \
  pkmgr update;pkmgr install bash

RUN set -e; \
  echo "Setting up prerequisites"; \
  true

ENV SHELL="/bin/bash"
SHELL [ "/bin/bash", "-c" ]

COPY --from=gosu /usr/local/bin/gosu /usr/local/bin/gosu

RUN echo "Initializing the system"; \
  $SHELL_OPTS; \
  mkdir -p "${DEFAULT_DATA_DIR}" "${DEFAULT_CONF_DIR}" "${DEFAULT_TEMPLATE_DIR}" "/root/docker/setup" "/etc/profile.d"; \
  if [ -f "/root/docker/setup/00-init.sh" ];then echo "Running the init script";/root/docker/setup/00-init.sh||{ echo "Failed to execute /root/docker/setup/00-init.sh" >&2 && exit 10; };echo "Done running the init script";fi; \
  echo ""

RUN echo "Creating and editing system files "; \
  $SHELL_OPTS; \
  [ -f "/root/.profile" ] || touch "/root/.profile"; \
  if [ -f "/root/docker/setup/01-system.sh" ];then echo "Running the system script";/root/docker/setup/01-system.sh||{ echo "Failed to execute /root/docker/setup/01-system.sh" >&2 && exit 10; };echo "Done running the system script";fi; \
  echo ""

RUN echo "Running pre-package commands"; \
  $SHELL_OPTS; \
  echo ""

RUN echo "Setting up and installing packages"; \
  $SHELL_OPTS; \
  if [ -n "${PACK_LIST}" ];then echo "Installing packages: $PACK_LIST";echo "${PACK_LIST}" >/root/docker/setup/packages.txt;pkmgr install ${PACK_LIST};fi; \
  echo ""

RUN echo "Initializing packages before copying files to image"; \
  $SHELL_OPTS; \
  if [ -f "/root/docker/setup/02-packages.sh" ];then echo "Running the packages script";/root/docker/setup/02-packages.sh||{ echo "Failed to execute /root/docker/setup/02-packages.sh" >&2 && exit 10; };echo "Done running the packages script";fi; \
  echo ""

COPY ./rootfs/. /
COPY ./Dockerfile /root/docker/Dockerfile

RUN echo "Updating system files "; \
  $SHELL_OPTS; \
  echo "$TIMEZONE" >"/etc/timezone"; \
  touch "/etc/profile" "/root/.profile"; \
  echo 'hosts: files dns' >"/etc/nsswitch.conf"; \
  [ "$PHP_VERSION" = "system" ] && PHP_VERSION="php" || true; \
  PHP_BIN="$(command -v ${PHP_VERSION} 2>/dev/null || true)"; \
  PHP_FPM="$(ls /usr/*bin/php*fpm* 2>/dev/null || true)"; \
  pip_bin="$(command -v python3 2>/dev/null || command -v python2 2>/dev/null || command -v python 2>/dev/null || true)"; \
  py_version="$(command $pip_bin --version | sed 's|[pP]ython ||g' | awk -F '.' '{print $1$2}' | grep '[0-9]' || true)"; \
  [ "$py_version" -gt "310" ] && pip_opts="--break-system-packages " || pip_opts=""; \
  [ -f "/usr/share/zoneinfo/${TZ}" ] && ln -sf "/usr/share/zoneinfo/${TZ}" "/etc/localtime" || true; \
  [ -n "$PHP_BIN" ] && [ -z "$(command -v php 2>/dev/null)" ] && ln -sf "$PHP_BIN" "/usr/bin/php" 2>/dev/null || true; \
  [ -n "$PHP_FPM" ] && [ -z "$(command -v php-fpm 2>/dev/null)" ] && ln -sf "$PHP_FPM" "/usr/bin/php-fpm" 2>/dev/null || true; \
  if [ -f "/etc/profile.d/color_prompt.sh.disabled" ]; then mv -f "/etc/profile.d/color_prompt.sh.disabled" "/etc/profile.d/color_prompt.sh";fi ; \
  { [ -f "/etc/bash/bashrc" ] && cp -Rf "/etc/bash/bashrc" "/root/.bashrc"; } || { [ -f "/etc/bashrc" ] && cp -Rf "/etc/bashrc" "/root/.bashrc"; } || { [ -f "/etc/bash.bashrc" ] && cp -Rf "/etc/bash.bashrc" "/root/.bashrc"; } || true; \
  if [ -z "$(command -v "apt-get" 2>/dev/null)" ];then grep -sh -q 'alias quit' "/root/.bashrc" || printf '# Profile\n\n%s\n%s\n%s\n' '. /etc/profile' '. /root/.profile' "alias quit='exit 0 2>/dev/null'" >>"/root/.bashrc"; fi; \
  if [ "$PHP_VERSION" != "system" ] && [ -e "/etc/php" ] && [ -d "/etc/${PHP_VERSION}" ];then rm -Rf "/etc/php";fi; \
  if [ "$PHP_VERSION" != "system" ] && [ -n "${PHP_VERSION}" ] && [ -d "/etc/${PHP_VERSION}" ];then ln -sf "/etc/${PHP_VERSION}" "/etc/php";fi; \
  if [ -f "/root/docker/setup/03-files.sh" ];then echo "Running the files script";/root/docker/setup/03-files.sh||{ echo "Failed to execute /root/docker/setup/03-files.sh" >&2 && exit 10; };echo "Done running the files script";fi; \
  echo ""

RUN echo "Custom Settings"; \
  $SHELL_OPTS; \
  echo ""

RUN echo "Setting up users and scripts "; \
  $SHELL_OPTS; \
  if [ -f "/root/docker/setup/04-users.sh" ];then echo "Running the users script";/root/docker/setup/04-users.sh||{ echo "Failed to execute /root/docker/setup/04-users.sh" >&2 && exit 10; };echo "Done running the users script";fi; \
  echo ""

RUN echo "Running the user init commands"; \
  $SHELL_OPTS; \
  echo ""

RUN echo "Setting OS Settings "; \
  $SHELL_OPTS; \
  echo ""

RUN echo "Custom Applications"; \
  $SHELL_OPTS; \
  echo ""

RUN echo "Running custom commands"; \
  if [ -f "/root/docker/setup/05-custom.sh" ];then echo "Running the custom script";/root/docker/setup/05-custom.sh||{ echo "Failed to execute /root/docker/setup/05-custom.sh" && exit 10; };echo "Done running the custom script";fi; \
  echo ""

RUN echo "Running final commands before cleanup"; \
  $SHELL_OPTS; \
  if [ -f "/root/docker/setup/06-post.sh" ];then echo "Running the post script";/root/docker/setup/06-post.sh||{ echo "Failed to execute /root/docker/setup/06-post.sh" >&2 && exit 10; };echo "Done running the post script";fi; \
  echo ""

RUN echo "Deleting unneeded files"; \
  $SHELL_OPTS; \
  pkmgr clean; \
  rm -Rf "/config" "/data" || true; \
  rm -rf /etc/systemd/system/*.wants/* || true; \
  rm -rf /lib/systemd/system/systemd-update-utmp* || true; \
  rm -rf /lib/systemd/system/anaconda.target.wants/* || true; \
  rm -rf /lib/systemd/system/local-fs.target.wants/* || true; \
  rm -rf /lib/systemd/system/multi-user.target.wants/* || true; \
  rm -rf /lib/systemd/system/sockets.target.wants/*udev* || true; \
  rm -rf /lib/systemd/system/sockets.target.wants/*initctl* || true; \
  rm -Rf /usr/share/doc/* /var/tmp/* /var/cache/*/* /root/.cache/* /usr/share/info/* /tmp/* || true; \
  if [ -d "/lib/systemd/system/sysinit.target.wants" ];then cd "/lib/systemd/system/sysinit.target.wants" && rm -f $(ls | grep -v systemd-tmpfiles-setup);fi; \
  if [ -f "/root/docker/setup/07-cleanup.sh" ];then echo "Running the cleanup script";/root/docker/setup/07-cleanup.sh||{ echo "Failed to execute /root/docker/setup/07-cleanup.sh" >&2 && exit 10; };echo "Done running the cleanup script";fi; \
  echo ""

RUN echo "Init done"
FROM scratch
ARG TZ
ARG PATH
ARG USER
ARG TIMEZONE
ARG LANGUAGE
ARG IMAGE_NAME
ARG BUILD_DATE
ARG SERVICE_PORT
ARG EXPOSE_PORTS
ARG BUILD_VERSION
ARG IMAGE_VERSION
ARG WWW_ROOT_DIR
ARG DEFAULT_FILE_DIR
ARG DEFAULT_DATA_DIR
ARG DEFAULT_CONF_DIR
ARG DEFAULT_TEMPLATE_DIR
ARG DISTRO_VERSION
ARG NODE_VERSION
ARG NODE_MANAGER
ARG PHP_VERSION
ARG PHP_SERVER
ARG LICENSE="WTFPL"
ARG ENV_PORTS="${EXPOSE_PORTS}"

USER ${USER}
WORKDIR /root

LABEL maintainer="CasjaysDev <docker-admin@casjaysdev.pro>"
LABEL org.opencontainers.image.vendor="CasjaysDev"
LABEL org.opencontainers.image.authors="CasjaysDev"
LABEL org.opencontainers.image.description="Containerized version of ${IMAGE_NAME}"
LABEL org.opencontainers.image.title="${IMAGE_NAME}"
LABEL org.opencontainers.image.base.name="${IMAGE_NAME}"
LABEL org.opencontainers.image.authors="${LICENSE}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.version="${BUILD_VERSION}"
LABEL org.opencontainers.image.schema-version="${BUILD_VERSION}"
LABEL org.opencontainers.image.url="docker.io"
LABEL org.opencontainers.image.source="docker.io"
LABEL org.opencontainers.image.vcs-type="Git"
LABEL org.opencontainers.image.revision="${BUILD_VERSION}"
LABEL org.opencontainers.image.source="https://github.com/casjaysdevdocker/rarbg"
LABEL org.opencontainers.image.documentation="https://github.com/casjaysdevdocker/rarbg"
LABEL com.github.containers.toolbox="false"

ENV ENV=~/.bashrc
ENV USER="${USER}"
ENV PATH="${PATH}"
ENV TZ="${TIMEZONE}"
ENV SHELL="/bin/bash"
ENV TIMEZONE="${TZ}"
ENV LANG="${LANGUAGE}"
ENV TERM="xterm-256color"
ENV PORT="${SERVICE_PORT}"
ENV ENV_PORTS="${ENV_PORTS}"
ENV CONTAINER_NAME="${IMAGE_NAME}"
ENV HOSTNAME="casjaysdev-${IMAGE_NAME}"
ENV PHP_SERVER="${PHP_SERVER}"
ENV NODE_VERSION="${NODE_VERSION}"
ENV NODE_MANAGER="${NODE_MANAGER}"
ENV PHP_VERSION="${PHP_VERSION}"
ENV DISTRO_VERSION="${IMAGE_VERSION}"
ENV WWW_ROOT_DIR="${WWW_ROOT_DIR}"

COPY --from=build /. /

VOLUME [ "/config","/data" ]

EXPOSE ${SERVICE_PORT} ${ENV_PORTS}

ENTRYPOINT [ "tini","--","/usr/local/bin/entrypoint.sh", "start" ]
HEALTHCHECK --start-period=10m --interval=5m --timeout=15s CMD [ "/usr/local/bin/entrypoint.sh", "healthcheck" ]
