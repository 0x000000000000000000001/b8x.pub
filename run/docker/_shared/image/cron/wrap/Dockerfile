FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_CRON}

COPY docker/_shared/file/_shared/bin/wait /wait

COPY docker/_shared/file/cron/entrypoint.sh /docker-entrypoint.sh
COPY docker/_shared/file/cron/logrotate /etc/logrotate.d/cron
