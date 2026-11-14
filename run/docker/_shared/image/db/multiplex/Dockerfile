FROM ${DOCKER_BASE_IMAGE_PGBOUNCE}

# Edit if you want to force a rebuild.
# Also fixes a bug around siblings on buildx, or changed files.
LABEL cache_bust="uf4b81cf_1dd0_43ed_8430_a575b8589f20"

USER root

RUN apk add --no-cache bash

USER postgres

COPY docker/_shared/file/_shared/bin/wait /wait
