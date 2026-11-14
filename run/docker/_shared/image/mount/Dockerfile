FROM ${DOCKER_BASE_IMAGE}

# Edit if you want to force a rebuild.
# Also fixes a bug around siblings on buildx, or changed files.
LABEL cache_bust="xdxw80cf_1dd0_43ed_8430_a575b8589f20"

COPY docker/_shared/file/mount/run.sh /run.sh
RUN chmod +x run.sh