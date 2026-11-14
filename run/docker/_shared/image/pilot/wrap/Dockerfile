FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_PILOT}

# Edit if you want to force a rebuild.
# Also fixes a bug around siblings on buildx, or changed files.
LABEL cache_bust="we4b81cf_1dd0_43ed_8430_a575b8589f20"

COPY docker/_shared/file/pilot/admin-password /tmp/admin-password

# if you changed it, you'll have to clear the one cached by portainer in its volume
COPY docker/_shared/file/_shared/tls/self-signed/server.key /certs/server.key
COPY docker/_shared/file/_shared/tls/self-signed/server.crt /certs/server.crt
