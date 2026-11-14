FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_DB}

# Edit if you want to force a rebuild.
# Also fixes a bug around siblings on buildx, or changed files.
LABEL cache_bust="uf4b81cf_1dd0_43ed_8430_a575b8589f20"

# SSL
COPY docker/_shared/file/db/server.crt /var/lib/postgresql/server.crt
COPY docker/_shared/file/db/server.key /var/lib/postgresql/server.key
RUN chown postgres /var/lib/postgresql/server.key
RUN chmod 600 /var/lib/postgresql/server.key

# Timezone
ENV TZ=${TZ}
RUN echo "${TZ}" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
RUN ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime

# Keepalive TCP settings (e.g. for PHP processes)
RUN echo 'net.ipv4.tcp_keepalive_time=600' >> /etc/sysctl.conf; \
    echo 'net.ipv4.tcp_keepalive_intvl=60' >> /etc/sysctl.conf; \
    echo 'net.ipv4.tcp_keepalive_probes=5' >> /etc/sysctl.conf

COPY docker/_shared/file/db/healthcheck.sh /healthcheck.sh

COPY docker/_shared/file/db/init /docker-entrypoint-initdb.d/
RUN sed -i 's/$${POSTGRES_DB_STORE}/'${POSTGRES_DB_STORE}'/g' /docker-entrypoint-initdb.d/*.sql; \
    sed -i 's/$${POSTGRES_DB_EDGE}/'${POSTGRES_DB_EDGE}'/g' /docker-entrypoint-initdb.d/*.sql

COPY docker/_shared/file/db/entrypoint-wrap.sh /docker-entrypoint-wrap.sh
RUN chmod +x /docker-entrypoint-wrap.sh

ENTRYPOINT ["/docker-entrypoint-wrap.sh"]  

HEALTHCHECK --interval=5s --timeout=10s --start-period=30s --retries=3 CMD /healthcheck.sh
