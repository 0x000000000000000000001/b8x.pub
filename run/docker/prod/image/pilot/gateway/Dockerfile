FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_PILOT_GATEWAY}

# Edit if you want to force a rebuild.
# Also fixes a bug around siblings on buildx, or changed files.
LABEL cache_bust="tc2bq0cf_14d0_43ed_8430_a575b8589f19"

COPY docker/${ENV}/file/pilot/gateway/traefik.yaml /etc/traefik/traefik.yaml
