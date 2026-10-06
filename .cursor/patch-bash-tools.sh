#!/usr/bin/env bash
set -euo pipefail

bt="/workspace/bash-tools"
[ -d "$bt/lib" ] || exit 0

dbshell="$bt/lib/dbshell.sh"
if ! grep -q bash_tools_root "$dbshell"; then
  python3 - "$dbshell" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
old = 'srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"\n'
new = '''srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bash_tools_root="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
if [ ! -f "$bash_tools_root/lib/utils.sh" ]; then
    bash_tools_root="$srcdir"
fi
'''
if old not in text:
    sys.exit(0)
text = text.replace(old, new, 1)
text = text.replace(
    'sql_scripts="$srcdir/sql"\nif [ -d "$srcdir/../sql" ]; then\n    sql_scripts="$srcdir/../sql"\nfi',
    '''sql_scripts="$bash_tools_root/sql"
if [ -d "$bash_tools_root/../sql" ]; then
    sql_scripts="$bash_tools_root/../sql"
elif [ -f "$bash_tools_root/../postgres_info.sql" ]; then
    sql_scripts="$(cd "$bash_tools_root/.." && pwd)"
fi''',
    1,
)
text = text.replace(
    '    -v $srcdir:/bash \\\n    -v $sql_scripts:/sql \\',
    '    -v $bash_tools_root:/bash \\\n    -v $sql_scripts:/sql \\',
    1,
)
path.write_text(text)
PY
fi

postgres_sh="$bt/postgres/postgres.sh"
if grep -q '/bash/psql_colorized.sh' "$postgres_sh"; then
  sed -i 's|/bash/psql_colorized.sh|/bash/postgres/psql_colorized.sh|g' "$postgres_sh"
fi
