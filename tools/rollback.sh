#!/usr/bin/env bash
# Make the main link serve an older version again.
#
#   tools/rollback.sh <version>
#   e.g.  tools/rollback.sh v1
#
# Only the main link changes. Every version's own link (/v1/, /v2/, ...) stays as it was.
# Nothing is deleted: this adds a new commit, so the rollback itself can be undone
# by releasing again or by rolling "back" to the newer version.
set -euo pipefail

VER="${1:?usage: tools/rollback.sh <version like v1>}"
PUB="$(cd "$(dirname "$0")/.." && pwd)"
SITE="https://stopitmax05.github.io/the-dead-school"
cd "$PUB"
git pull -q --ff-only
git rev-parse -q --verify "refs/tags/$VER" >/dev/null || { echo "No version called $VER. See VERSIONS.md for the list."; exit 1; }

rm -rf index.html assets The-Dead-School.html LICENSES.txt
git checkout -q "$VER" -- index.html assets The-Dead-School.html LICENSES.txt
printf '| rollback | %s | | [main link](%s/) | Main link set back to %s |\n' "$(date +%Y-%m-%d)" "$SITE" "$VER" >> VERSIONS.md
git add -A
git commit -q -m "Roll the main link back to $VER"
git push -q origin main
echo "Done. $SITE/ now serves $VER. GitHub Pages takes about a minute to update."
