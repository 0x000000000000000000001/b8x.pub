FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_POSTGRES} AS ulid

RUN apt update && apt install -y \
    build-essential \
    postgresql-server-dev-${DOCKER_BASE_IMAGE_POSTGRES_VERSION_MAJOR} \
    postgresql-contrib-${DOCKER_BASE_IMAGE_POSTGRES_VERSION_MAJOR} \
    git \
    curl \
    pkg-config \
    libssl-dev 

# ULID
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . "$$HOME/.cargo/env" && \
    export RUST_MIN_STACK=16777216 && \
    cargo install --version 0.16.1 --locked cargo-pgrx && \
    cargo pgrx init --pg${DOCKER_BASE_IMAGE_POSTGRES_VERSION_MAJOR} /usr/lib/postgresql/${DOCKER_BASE_IMAGE_POSTGRES_VERSION_MAJOR}/bin/pg_config && \
    cd /tmp && \
    git clone -b v0.2.2 https://github.com/pksunkara/pgx_ulid.git && \
    cd pgx_ulid && \
    cargo pgrx install --pg-config /usr/lib/postgresql/${DOCKER_BASE_IMAGE_POSTGRES_VERSION_MAJOR}/bin/pg_config --release

FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_POSTGRES}

COPY --from=ulid \
    /usr/lib/postgresql/${DOCKER_BASE_IMAGE_POSTGRES_VERSION_MAJOR}/lib/pgx_ulid.so \
    /usr/lib/postgresql/${DOCKER_BASE_IMAGE_POSTGRES_VERSION_MAJOR}/lib/

COPY --from=ulid \
    /usr/share/postgresql/${DOCKER_BASE_IMAGE_POSTGRES_VERSION_MAJOR}/extension/pgx_ulid* \
    /usr/share/postgresql/${DOCKER_BASE_IMAGE_POSTGRES_VERSION_MAJOR}/extension/

RUN apt update && apt install -y \
    postgresql-contrib-${DOCKER_BASE_IMAGE_POSTGRES_VERSION_MAJOR} \
    postgresql-${DOCKER_BASE_IMAGE_POSTGRES_VERSION_MAJOR}-pgvector \
    postgresql-${DOCKER_BASE_IMAGE_POSTGRES_VERSION_MAJOR}-rum
