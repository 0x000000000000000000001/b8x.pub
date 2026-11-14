FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_WEBSERVER}

# Edit if you want to force a rebuild.
# Also fixes a bug around siblings on buildx, or changed files.
LABEL cache_bust="idz590cf_14d0_43ed_8430_a575b8589z19"

COPY docker/${ENV}/file/webserver/conf.d/b8x.conf /etc/nginx/templates/b8x.conf.template
