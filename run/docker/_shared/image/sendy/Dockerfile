# Inspired by https://github.com/open-forest/sendy/tree/master
FROM ${DOCKER_BASE_IMAGE_SENDY}

# Edit if you want to force a rebuild.
# Also fixes a bug around siblings on buildx, or changed files.
LABEL cache_bust="eh4y00cf_14d9_43ed_8430_a575b8589f1l"

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    unzip \
    cron \
    libxml2-dev \
    libcurl4-openssl-dev \
    gettext \
    && docker-php-ext-install -j$$(nproc) calendar mysqli gettext simplexml curl \
    && a2enmod rewrite \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Apache & PHP
RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && echo 'ServerName ${NEWS_DNS_LEVEL_3_GTE}' > /etc/apache2/conf-available/serverName.conf \
    && printf "[PHP]\nerror_reporting = E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED\n" > /usr/local/etc/php/conf.d/error_reporting.ini \
    && a2enconf serverName \
    && a2enmod headers

COPY docker/_shared/file/sendy/entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
