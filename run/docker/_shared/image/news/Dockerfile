FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_SENDY}

# Edit if you want to force a rebuild.
# Also fixes a bug around siblings on buildx, or changed files.
LABEL cache_bust="dg2e90cf_14d9_43ed_8430_a575b8589f11"

COPY docker/_shared/file/sendy/crontab /etc/cron.d/sendy-cron
RUN chmod 0644 /etc/cron.d/sendy-cron
