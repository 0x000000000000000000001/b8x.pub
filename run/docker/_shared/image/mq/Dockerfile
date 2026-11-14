FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_RABBITMQ}

COPY docker/_shared/file/mq/rabbitmq.conf /etc/rabbitmq/rabbitmq.conf

# Keepalive (alternative to heartbeats, when we deal with single-thread languages such as PHP)
# See https://www.rabbitmq.com/networking.html#tcp-keepalives
# Value of "tcp_keepalive_time" needs to be higher than the maximum of ALL consumers ttls (e.g. one of them is the "app-consumer" Docker service)
# Here: 1200s + 4 * 60s = 20m + 4 * 1m = 24m before considering that the peer is dead
RUN echo 'net.ipv4.tcp_keepalive_time=1200' >> /etc/sysctl.conf; \
    echo 'net.ipv4.tcp_keepalive_intvl=60' >> /etc/sysctl.conf; \
    echo 'net.ipv4.tcp_keepalive_probes=4' >> /etc/sysctl.conf
