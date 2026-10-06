#!/usr/bin/env bash
set -euo pipefail

cd /workspace
export PATH="$PATH:/workspace/bash-tools/mysql:/workspace/bash-tools/postgres"

POSTGRES_VERSIONS=13.0 ./test.sh postgres
MYSQL_VERSIONS=8.0 ./test.sh mysql
