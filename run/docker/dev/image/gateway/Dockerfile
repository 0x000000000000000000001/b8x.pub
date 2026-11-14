FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_GATEWAY}

# Edit if you want to force a rebuild.
# Also fixes a bug around siblings on buildx, or changed files.
LABEL cache_bust="tc3b90cf_14d1_41ed_8430_a575b8589f19"

RUN mkdir -p /etc/traefik/mnt/dynamic

COPY docker/_shared/file/gateway/dynamic /etc/traefik/dynamic
COPY docker/${ENV}/file/gateway/traefik.yaml /etc/traefik/traefik.yaml
