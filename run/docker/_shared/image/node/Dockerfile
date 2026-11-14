FROM ${DOCKER_BASE_IMAGE_NODE}

# On macos, the single quote can cause trouble (e.g. input to a CLI command).
# So we force the locale to C.UTF-8.
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -qq install -y \
    jq \
    curl \ 
    wget \ 
    bash \
    gettext-base

RUN npm install -g \
    yamljs \
    dotsunited-merge-json \
    dotenv-to-json \
    clipboard-cli
# Separate install to replace yamljs one (which does not work...)
RUN npm install --force -g json2yaml
