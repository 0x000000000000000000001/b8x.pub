FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_NGINX}

# Edit if you want to force a rebuild.
# Also fixes a bug around siblings on buildx, or changed files.
LABEL cache_bust="xy4b90cf_1xd0_43ed_8430_a575b8589f21"

RUN apk add \
    bash \
    jq \
    nano \
    apache2-utils \
    nmap \
    curl

COPY docker/_shared/file/webserver/healthcheck.sh /healthcheck.sh

COPY docker/_shared/file/webserver/nginx.conf /etc/nginx/nginx.conf
COPY docker/_shared/file/webserver/conf.d /etc/nginx/conf.d

COPY docker/_shared/file/_shared/tls/self-signed/server.crt /etc/nginx/certs/server.crt
COPY docker/_shared/file/_shared/tls/self-signed/server.key /etc/nginx/certs/server.key

HEALTHCHECK --interval=${WEBSERVER_DOCKER_HEALTHCHECK_INTERVAL}s --timeout=30s --start-period=${WEBSERVER_DOCKER_HEALTHCHECK_START_PERIOD}s --retries=${WEBSERVER_DOCKER_HEALTHCHECK_RETRIES} CMD /healthcheck.sh
