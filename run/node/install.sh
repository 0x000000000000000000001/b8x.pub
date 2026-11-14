#!/usr/bin/env bash
#
# Required OS: Debian 12
#
# Copy these commands and run them in your machine(s):
#   E.g. sudo apt-get update; sudo apt-get install -y curl; export FLOATING_IP=57.130.25.162; bash -c "$(curl -H 'Authorization: token ...' 'https://raw.githubusercontent.com/0x000000000000000000001/b8x/master/run/node/install.sh')"
#
# Don't forget to reboot afterwards.
#

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
ORANGE=$(tput setaf 208)
BOLD=$(tput bold)
CLEAR=$(tput sgr0)

#
# Returns current release among 'debian' or 'ubuntu'
#
release() {
  if [ "$(lsb_release -d | awk -F"\t" '{print $2}' | cut -d ' ' -f1)" = 'Debian' ]; then
    echo 'debian'
  else
    echo 'ubuntu'
  fi
}

main() {
  # Stop on error
  set -e
  # Show each command before its execution
  set -x

  # Is the provider AWS or OVH?
  provider=$([[ "$(sudo head -c 3 /sys/devices/virtual/dmi/id/product_uuid 2>&1 | awk '{print tolower($0)}')" == *'ec2'* ]] && echo 'aws' || echo 'ovh')

  export ENV=prod

  echo $ENV | sudo tee /.env >/dev/null

  # That would cause a crash on "sudo apt update" otherwise.
  (sudo rm -R /etc/apt/sources.list.d/php.list || true) &>/dev/null

  # Fix OVH DNS resolution issues (their internal OpenStack DNS can return REFUSED)
  if [[ "$provider" == 'ovh' ]]; then
    if systemctl is-active --quiet systemd-resolved; then
      sudo mkdir -p /etc/systemd/resolved.conf.d
      echo -e "[Resolve]\nDNS=8.8.8.8 1.1.1.1" | sudo tee /etc/systemd/resolved.conf.d/dns_fallback.conf >/dev/null
      sudo systemctl restart systemd-resolved
      sleep 5
    fi
  fi

  # Useful variables
  export ROOT_DIR=$HOME/b8x

  GIT_ACCESS_TOKEN=...
  GIT_USER_NAME=0x000000000000000000001
  GIT_REPO_NAME=b8x
  GIT_BRANCH=master
  GIT_RAW_PREFIX="https://raw.githubusercontent.com/${GIT_USER_NAME}/${GIT_REPO_NAME}/${GIT_BRANCH}/"
  GIT_AUTH_HEADER="Authorization: token $GIT_ACCESS_TOKEN"

  # Multi-node group id_rsa/id_rsa.pub couple, and multi-admin group authorized key (ansible, openstack, etc.)
  cp run/node/ssh/id_rsa.pub $HOME/.ssh/id_rsa.pub
  cp run/node/ssh/id_rsa $HOME/.ssh/id_rsa
  ## security flaws would otherwise result in bash throwing warning errors in later ssh calls (ex: git)
  chmod 0600 $HOME/.ssh/id_rsa.pub $HOME/.ssh/id_rsa

  # Avoid ssh host verifications (git, etc.)
  echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >>~/.ssh/config

  if [[ "$provider" == 'ovh' && "$FLOATING_IP" != '' ]]; then
    sudo su -c " \
      echo 'network:' > /etc/netplan/60-floating-ip.yaml; \
      echo '  version: 2' >> /etc/netplan/60-floating-ip.yaml; \
      echo '  ethernets:' >> /etc/netplan/60-floating-ip.yaml; \
      echo '    ens3:' >> /etc/netplan/60-floating-ip.yaml; \
      echo '      addresses:' >> /etc/netplan/60-floating-ip.yaml; \
      echo '        - ${FLOATING_IP}/32' >> /etc/netplan/60-floating-ip.yaml;"
    sudo chmod 600 /etc/netplan/60-floating-ip.yaml
    sudo netplan apply
  fi

  # Install basics
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    make \
    zsh \
    apt-transport-https \
    ca-certificates \
    gnupg2 \
    httpie \
    jq \
    bc \
    msmtp \
    iotop \
    micro \
    age
  curl https://getmic.ro | bash

  # Project folder initialization
  mkdir -p ${ROOT_DIR}
  cd ${ROOT_DIR}

  # Download and decrypt environment variables
  curl -4 -sS --retry 5 --retry-all-errors --retry-delay 2 -H "$GIT_AUTH_HEADER" "${GIT_RAW_PREFIX}sec.tar.gz" -o sec.tar.gz
  echo "🔑 Please enter your password to decrypt the environment:"
  age -d -o tmp.sec.tar.gz sec.tar.gz
  tar -xzf tmp.sec.tar.gz
  rm sec.tar.gz tmp.sec.tar.gz

  ## Extract variables from given environment ones
  touch .env
  files="_shared/aws ${ENV}/aws _shared/git _shared/docker ${ENV}/docker _shared/db _shared/db2"
  for file in $files
  do
    [ -f "env/${file}.env" ] && cat "env/${file}.env" >>.env
    echo -e '\n' >>.env
  done
  source .env &>/dev/null
  rm .env

  # Global git settings
  git config --global user.email ${GIT_USER_EMAIL}
  git config --global user.name ${GIT_USER_NAME}
  git config --global init.defaultBranch master

  # Install docker, docker-compose
  ## docker
  ### repo
  sudo apt-get update
  sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg
  sudo mkdir -m 0755 -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  ### engine
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  ### permissions
  sudo usermod -aG docker ${USER}

  # Secure Docker port mapping bypass (Block public access to 3306)
  PUB_IF=$(ip -o -4 route show to default | awk '{print $5}' | head -n1)
  sudo bash -c "cat <<EOF > /etc/systemd/system/docker-iptables-secure.service
[Unit]
Description=Docker User Iptables Rules
After=docker.service
BindsTo=docker.service
ReloadPropagatedFrom=docker.service

[Service]
Type=oneshot
ExecStartPre=/bin/bash -c "while ! /sbin/iptables -L DOCKER-USER >/dev/null 2>&1; do sleep 1; done"
ExecStart=/sbin/iptables -I DOCKER-USER -i ${PUB_IF} -p tcp -m multiport --dports ${MYSQL_PORT},${POSTGRES_PORT} -j DROP
RemainAfterExit=yes

[Install]
WantedBy=docker.service
EOF"
  sudo systemctl daemon-reload
  sudo systemctl enable docker-iptables-secure.service
  sudo systemctl start docker-iptables-secure.service

  if [[ "$provider" == 'aws' ]]; then
    # NVMe support (see https://rexray.readthedocs.io/en/stable/user-guide/storage-providers/aws/#nvme-support, inspired by https://github.com/oogali/ebs-automatic-nvme-mapping)
    # Note that C5, C5d, i3.metal, M5, M5d, R5, R5d, T3, and z1d are problematic in general. See https://github.com/rexray/rexray/issues/1282 and https://github.com/rexray/rexray/issues/1104
    sudo apt install -y nvme-cli
    sudo touch /etc/udev/rules.d/999-aws-ebs-nvme.rules
    curl -H "PRIVATE-TOKEN: $GIT_ACCESS_TOKEN" "${GIT_CURL_PREFIX}bin${SLASH}devops${SLASH}node${SLASH}aws${SLASH}999-aws-ebs-nvme${DOT}rules${GIT_CURL_SUFFIX}" | sudo tee /etc/udev/rules.d/999-aws-ebs-nvme.rules
    sudo touch /usr/local/bin/ebs-nvme-mapping.sh
    curl -H "PRIVATE-TOKEN: $GIT_ACCESS_TOKEN" "${GIT_CURL_PREFIX}bin${SLASH}devops${SLASH}node${SLASH}aws${SLASH}ebs-nvme-mapping${DOT}sh${GIT_CURL_SUFFIX}" | sudo tee /usr/local/bin/ebs-nvme-mapping.sh
    sudo chmod u+x /usr/local/bin/ebs-nvme-mapping.sh
    sudo udevadm control --reload-rules && sudo udevadm trigger
  fi

  git init
  git remote add origin ${GIT_REPO_URL_SSH} 2>/dev/null || git remote set-url origin ${GIT_REPO_URL_SSH}
  git pull origin master
  git branch --set-upstream-to=origin/master master

  # Swap
  if [[ "$provider" == 'ovh' ]]; then
    echo 'Configuring swap...'
    sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=2M count=2048
    sudo /sbin/mkswap /var/swap.1
    sudo /sbin/swapon /var/swap.1
  fi

  # Configure zsh
  ## authorize no-pwd shell change
  sudo sed s/required/sufficient/g -i /etc/pam.d/chsh
  sudo chsh -s "$(which zsh)" ${USER}
  ## install that does not change shell on the fly
  export RUNZSH=no && (yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)")
  ## rc
  curl -H "$GIT_AUTH_HEADER" "${GIT_RAW_PREFIX}run/node/zsh/zshrc" | sed -Ee "s:%ENV%:${ENV}:g; s:%ROOT_DIR%:${ROOT_DIR}:g;" >$HOME/.zshrc

  # Quiet welcome message when entering server
  touch ~/.hushlogin

  # Change hostname (try to keep this line at the end since sudo shows a warning: sudo: unable to resolve host <hostname>: Name or service not known)
  hostname=b8x
  if [[ "$HOST_NAME" != '' ]]; then
    if [[ "$provider" == 'ovh' ]]; then
      # see https://docs.ovh.com/fr/public-cloud/modifier-le-hostname-dune-instance/
      echo -e '\n# This will let us persist the hostname change in /etc/hosts (see https://docs.ovh.com/fr/public-cloud/modifier-le-hostname-dune-instance/)\npreserve_hostname: true\nmanage_etc_hosts: false' | sudo tee -a /etc/cloud/cloud.cfg >/dev/null
      echo "127.0.1.1 $HOST_NAME.localdomain $HOST_NAME" | sudo tee -a /etc/hosts >/dev/null
      echo $HOST_NAME | sudo tee /etc/hostname >/dev/null
    else
      sudo sed -i "s/{{fqdn}} {{hostname}}/{{fqdn}} {{hostname}} $HOST_NAME/" /etc/cloud/templates/hosts.debian.tmpl
      sudo sed -E -i "s/^(127\.0\.1\.1.*)$/\1 $HOST_NAME/" /etc/hosts
    fi

    sudo hostnamectl set-hostname $HOST_NAME
  fi

  # Some AWS EC2 instances may have this installed... removed it!
  if [[ "$provider" == 'aws' ]]; then
    sudo apt remove --purge -y apache2
  fi

  # Localhost domain names (e.g. useful for traefik)
  echo '127.0.0.1 pilot.localhost' | sudo tee -a /etc/hosts
  if [[ "$provider" == 'aws' ]]; then
    echo '127.0.0.1 pilot.localhost' | sudo tee -a /etc/cloud/templates/hosts.debian.tmpl
  fi

  # Pretty final message
  printf "\n\n\n ${GREEN} \xE2\x9C\x94 The machine is now ready for your ${BOLD}${ENV}${CLEAR}${GREEN} environment! ${ORANGE}Note that, for important reasons (docker group rights, shell, hostname, firewall rules, etc.), ${BOLD}you firstly need to reboot.${CLEAR} \n\n\n"

  # File which indicates that the install is now finished
  # E.g. the docker service "machine-explorer" will not try to join the node to a swarm cluster as long as this file does not exist yet, even if the machine seems to be ready in the AWS dashboard
  sudo touch /.ready && sudo chmod 0777 /.ready
}

trap 'if [ $? -ne 0 ]; then printf "\n\n\n ${RED} \xE2\x9C\x98 Ouch! Error ${CLEAR} \n\n\n"; fi' EXIT

main
