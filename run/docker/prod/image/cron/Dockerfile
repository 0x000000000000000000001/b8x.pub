FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_CRON_WRAP}

# Edit if you want to force a rebuild.
# Also fixes a bug around siblings on buildx, or changed files.
LABEL cache_bust="kd3by0cf_14d0_43ed_8430_a575b8589f19"

COPY docker/${ENV}/file/cron/crontab /etc/cron.d/b8x
