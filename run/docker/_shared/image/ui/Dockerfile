FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_NODE}

# Edit if you want to force a rebuild.
# Also fixes a bug around siblings on buildx, or changed files.
LABEL cache_bust="sc4f90cf_14d9_43ed_8430_a575b8589f1k"

RUN npm install -g browser-sync

EXPOSE 80
