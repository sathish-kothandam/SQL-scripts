#!/usr/bin/env bash
set -euo pipefail

if [ -S /var/run/docker.sock ] && docker info >/dev/null 2>&1; then
  exit 0
fi

if ! pgrep -x dockerd >/dev/null 2>&1; then
  sudo dockerd >/tmp/dockerd.log 2>&1 &
  for _ in $(seq 1 60); do
    [ -S /var/run/docker.sock ] && break
    sleep 1
  done
fi

if [ -S /var/run/docker.sock ]; then
  sudo chmod 666 /var/run/docker.sock 2>/dev/null || true
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not ready; see /tmp/dockerd.log" >&2
  exit 1
fi
