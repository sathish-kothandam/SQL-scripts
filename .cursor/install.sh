#!/usr/bin/env bash
set -euo pipefail

cd /workspace

export DEBIAN_FRONTEND=noninteractive

if ! command -v docker >/dev/null 2>&1; then
  sudo apt-get update -qq
  sudo apt-get install -y -qq --no-install-recommends \
    docker.io fuse-overlayfs iptables ca-certificates curl git make
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    -o Dpkg::Options::="--force-confnew" fuse3 fuse-overlayfs || true
fi

if ! command -v make >/dev/null 2>&1; then
  sudo apt-get update -qq
  sudo apt-get install -y -qq --no-install-recommends make git curl
fi

sudo mkdir -p /etc/docker
if [ ! -f /etc/docker/daemon.json ]; then
  echo '{"storage-driver": "fuse-overlayfs"}' | sudo tee /etc/docker/daemon.json >/dev/null
fi

if command -v update-alternatives >/dev/null 2>&1; then
  sudo update-alternatives --set iptables /usr/sbin/iptables-legacy 2>/dev/null || true
fi

make init

if [ ! -d bash-tools/.git ]; then
  curl -fsSL https://raw.githubusercontent.com/HariSekhon/DevOps-Bash-tools/master/setup/bootstrap.sh | sh
fi

export PATH="$PATH:/workspace/bash-tools/mysql:/workspace/bash-tools/postgres"

bash /workspace/.cursor/patch-bash-tools.sh

if [ -d bash-tools ]; then
  (
    cd bash-tools
    make update2
  )
fi

# Second idempotent pass
bash /workspace/.cursor/patch-bash-tools.sh
make init
