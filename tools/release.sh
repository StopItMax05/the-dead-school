#!/usr/bin/env bash
# Publish a new numbered version of The Dead School.
#
#   tools/release.sh <path to MAXGAME checkout> <version>
#   e.g.  tools/release.sh ~/code/MAXGAME v2
#
# What it does:
#   1. Builds the game from the MAXGAME checkout (typecheck, lint-free build, offline copy).
#   2. Copies the build to the root of this repo (the main link, always the latest)
#      and to <version>/ (a permanent link that never changes again).
#   3. Commits, tags <version> in this repo AND in MAXGAME, pushes both.
#   4. Creates a GitHub Release with the offline file attached.
#
# To go back to an older version on the main link, use tools/rollback.sh.
set -euo pipefail

SRC="${1:?usage: tools/release.sh <path to MAXGAME checkout> <version like v2>}"
VER="${2:?usage: tools/release.sh <path to MAXGAME checkout> <version like v2>}"
PUB="$(cd "$(dirname "$0")/.." && pwd)"
SITE="https://stopitmax05.github.io/the-dead-school"
BASE="/the-dead-school"
REPO="StopItMax05/the-dead-school"

[[ "$VER" =~ ^v[0-9]+(\.[0-9]+)*$ ]] || { echo "Version must look like v2 or v2.1"; exit 1; }
[ -f "$SRC/package.json" ] || { echo "No package.json in $SRC; is that the MAXGAME checkout?"; exit 1; }
cd "$PUB"
if git rev-parse -q --verify "refs/tags/$VER" >/dev/null; then echo "$VER already exists here. Pick the next number."; exit 1; fi
git pull -q --ff-only

cd "$SRC"
if ! git diff --quiet || ! git diff --cached --quiet; then echo "MAXGAME has uncommitted changes. Commit (or stash) them first so the release matches a real commit."; exit 1; fi
SHA="$(git rev-parse --short HEAD)"
SUBJECT="$(git log -1 --format=%s)"
TMP="$(mktemp -d)"

echo "==> Building MAXGAME $SHA as $VER"
npm ci --no-audit --no-fund --silent
npm run build                                   # standard build: typecheck + dist/ + offline copy
cp dist/The-Dead-School.html dist/LICENSES.txt "$TMP/"
npx vite build --base="$BASE/" --outDir "$TMP/root" --emptyOutDir
npx vite build --base="$BASE/$VER/" --outDir "$TMP/versioned" --emptyOutDir

echo "==> Updating the site"
cd "$PUB"
rm -rf index.html assets
cp -R "$TMP/root/." .
mkdir -p "$VER"
cp -R "$TMP/versioned/." "$VER/"
cp "$TMP/The-Dead-School.html" "$TMP/LICENSES.txt" .
cp "$TMP/The-Dead-School.html" "$VER/"
printf '| %s | %s | %s | [play](%s/%s/) | %s |\n' "$VER" "$(date +%Y-%m-%d)" "$SHA" "$SITE" "$VER" "$SUBJECT" >> VERSIONS.md

git add -A
git commit -q -m "Release $VER from MAXGAME $SHA"
git tag -a "$VER" -m "The Dead School $VER, built from MAXGAME $SHA"
git push -q origin main "$VER"

echo "==> Tagging the source"
( cd "$SRC" && git tag -a "$VER" -m "Published as The Dead School $VER" && git push -q origin "$VER" )

echo "==> Creating the GitHub Release"
gh release create "$VER" --repo "$REPO" --title "The Dead School $VER" \
  --notes "Built from MAXGAME $SHA: $SUBJECT

Play this version: $SITE/$VER/
Latest version: $SITE/" \
  "$VER/The-Dead-School.html#The-Dead-School-$VER.html"

rm -rf "$TMP"
echo
echo "Done. $VER is live at $SITE/ and permanently at $SITE/$VER/"
echo "GitHub Pages takes about a minute to update."
