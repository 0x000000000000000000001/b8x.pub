FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_GATEWAY}

# Edit if you want to force a rebuild.
# Also fixes a bug around siblings on buildx, or changed files.
LABEL cache_bust="tc2e10cr_14d9_43ed_8430_a575b8589f11"

RUN mkdir -p /etc/traefik/mnt/dynamic

COPY docker/_shared/file/gateway/dynamic /etc/traefik/dynamic
COPY docker/${ENV}/file/gateway/traefik.yaml /etc/traefik/traefik.yaml
