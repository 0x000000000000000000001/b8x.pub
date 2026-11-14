FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_CTL}

# Edit if you want to force a rebuild.
# Also fixes a bug around siblings on buildx, or changed files.
LABEL cache_bust="fe4f80cf_14d9_43ed_8430_a575b8589f1k"

# SSH
COPY node/ssh/id_rsa /root/.ssh/id_rsa
COPY node/ssh/id_rsa.pub /root/.ssh/id_rsa.pub
RUN chmod 600 /root/.ssh/id_rsa && \
    chmod 644 /root/.ssh/id_rsa.pub

COPY docker/_shared/file/ctl/postpull.sh /postpull.sh

COPY docker/_shared/file/_shared/bin/getservicename.sh /getservicename.sh

COPY docker/_shared/file/_shared/bin/git/ctl/healthcheck.sh /healthcheck.sh
COPY docker/_shared/file/_shared/bin/git/ctl/run.sh /run.sh
