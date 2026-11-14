FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_TRAEFIK}

# Edit if you want to force a rebuild.
# Also fixes a bug around siblings on buildx, or changed files.
LABEL cache_bust="oe4b81cf_1dd0_43ed_8430_a575b8589f20"

RUN apk update
RUN apk add --no-cache \
    bash \
    jq \
    nano \
    docker-cli \
    supervisor \
    curl \
    bind-tools # for "dig"

# Launch the supervisord meanwhile...
# ...and ensure mount directories exist (Traefik will throw an error otherwise)
RUN sed -i 's!^exec "$@"!supervisord -c /etc/supervisord.conf \&>/var/log/entrypoint-patch.log\n\nmkdir -p /etc/traefik/mnt/certs\nmkdir -p /etc/traefik/mnt/dynamic\n\n\0!' /entrypoint.sh

COPY docker/_shared/file/_shared/tls/self-signed/server.crt /etc/traefik/certs/default.crt
COPY docker/_shared/file/_shared/tls/self-signed/server.key /etc/traefik/certs/default.key

COPY docker/_shared/file/_shared/bin/getenv.sh /getenv.sh

COPY docker/_shared/file/gateway/supervise-domains.sh /supervise-domains.sh
COPY docker/_shared/file/gateway/supervisord.conf /etc/supervisord.conf
COPY docker/_shared/file/gateway/update-tls-conf.sh /update-tls-conf.sh
