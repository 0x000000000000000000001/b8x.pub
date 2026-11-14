FROM ${DOCKER_IMAGE_PREFIX}/${DOCKER_IMAGE_NODE}

# Edit if you want to force a rebuild.
# Also fixes a bug around siblings on buildx, or changed files.
LABEL cache_bust="oc2e90cf_14d9_43ed_8430_a575b8589f11"

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git 

# Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \ 
    sh get-docker.sh

# Spago must have the same version than the one used in the local host
# (e.g. for .lock compatibility between local and prod envs).
RUN npm install -g purescript spago@$SPAGO_VERSION nodemon
