FROM golang:1.26-bookworm AS golang
FROM rust:1.96.0-bookworm AS rust
FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_NODE}

# Go
COPY --from=golang /usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:$${PATH}"

# Rust
COPY --from=rust /usr/local/cargo /usr/local/cargo
COPY --from=rust /usr/local/rustup /usr/local/rustup
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH="/usr/local/cargo/bin:$${PATH}"

# .NET 8
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -qq install -y curl ca-certificates && \
    curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh && \
    bash /tmp/dotnet-install.sh --channel 8.0 --install-dir /usr/share/dotnet && \
    ln -sf /usr/share/dotnet/dotnet /usr/local/bin/dotnet && \
    rm -f /tmp/dotnet-install.sh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
ENV DOTNET_ROOT=/usr/share/dotnet \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_NOLOGO=1 \
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

# Java 17
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -qq install -y openjdk-17-jdk-headless && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Spago must have the same version than the one used in the local host
# (e.g. for .lock compatibility between local and prod envs).
RUN npm install -g purescript spago@$SPAGO_VERSION nodemon ulid
ENV NODE_PATH=/usr/local/lib/node_modules

# PHP 8.4
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -qq install -y apt-transport-https ca-certificates curl && \
    curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $$(. /etc/os-release && echo $$VERSION_CODENAME) main" > /etc/apt/sources.list.d/php.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq install -y php8.4-cli php8.4-mbstring php8.4-xml php8.4-curl php8.4-pgsql php8.4-gd php8.4-gmp unzip && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# PECL Extensions & SPX Profiler
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y php-pear php8.4-dev gcc make git zlib1g-dev libevent-dev libssl-dev libevent-2.1-7 libevent-extra-2.1-7 libevent-openssl-2.1-7 && \
    yes "" | pecl install event && \
    echo "extension=event.so" > /etc/php/8.4/cli/conf.d/30-event.ini && \
    git clone https://github.com/NoiseByNorthwest/php-spx.git /tmp/php-spx && \
    cd /tmp/php-spx && \
    phpize && \
    ./configure && \
    make && make install && \
    echo "extension=spx.so" > /etc/php/8.4/cli/conf.d/20-spx.ini && \
    rm -rf /tmp/php-spx && \
    apt-get remove -y php-pear php8.4-dev make git libevent-dev libssl-dev && \
    apt-get autoremove -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
