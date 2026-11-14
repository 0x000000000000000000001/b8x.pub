FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_API_WRAP}

# Cron, AWS CLI
# Note: DEBIAN_FRONTEND=noninteractive prevents tzdata/exim4 from hanging the buildx process with interactive prompts
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq install -y cron awscli default-mysql-client

# Postgres
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ $$(. /etc/os-release && echo $$VERSION_CODENAME)-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq install -y postgresql-client-${DOCKER_BASE_IMAGE_POSTGRES_VERSION_MAJOR}

# Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \ 
    sh get-docker.sh