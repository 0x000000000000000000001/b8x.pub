FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_API}

# Edit if you want to force a rebuild.
# Also fixes a bug around siblings on buildx, or changed files.
LABEL cache_bust="wa4f91cf_f4d9_43ed_8430_x575b8589f1k"

COPY docker/_shared/file/_shared/bin/wait /wait
COPY docker/_shared/file/api/healthcheck.sh /healthcheck.sh

# Keepalive TCP settings (e.g. for PostgreSQL)
RUN echo 'net.ipv4.tcp_keepalive_time=9600' >> /etc/sysctl.conf; \
    echo 'net.ipv4.tcp_keepalive_intvl=60' >> /etc/sysctl.conf; \
    echo 'net.ipv4.tcp_keepalive_probes=5' >> /etc/sysctl.conf

COPY docker/_shared/file/api/cli/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80 
