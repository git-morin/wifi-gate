#!/usr/bin/env bash
# Packs the flashable Wi-Fi Gate zip into dist/.
#
#   ./build.sh                                      # metadata from module.prop
#   ./build.sh 2.1.0 42 https://host/update.json    # the way CI cuts a release
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "$0")" && pwd)
DIST=$ROOT/dist
WORK=$DIST/payload

PAYLOAD=(
  module.prop
  customize.sh
  common.sh
  service.sh
  on_event.sh
  action.sh
  uninstall.sh
  META-INF
)

prop() { sed -n "s/^$1=//p" "$ROOT/module.prop" | head -1; }
die() { echo "build: $*" >&2; exit 1; }

ID=$(prop id)
NAME=$(prop name)
AUTHOR=$(prop author)
DESCRIPTION=$(prop description)
VERSION=${1:-$(prop version)}
VERSION_CODE=${2:-$(prop versionCode)}
UPDATE_JSON=${3:-$(prop updateJson)}

[ -n "$ID" ] || die "module.prop has no id"
[ -n "$VERSION" ] || die "no version given and module.prop has none"
case $ID in
  [A-Za-z]*) ;;
  *) die "id must start with a letter, got '$ID'" ;;
esac
case $VERSION_CODE in
  '' | *[!0-9]*) die "versionCode must be a non-negative integer, got '$VERSION_CODE'" ;;
esac

rm -rf "$WORK"
mkdir -p "$WORK"
for entry in "${PAYLOAD[@]}"; do
  [ -e "$ROOT/$entry" ] || die "missing payload entry $entry"
  cp -r "$ROOT/$entry" "$WORK/"
done

{
  printf 'id=%s\n' "$ID"
  printf 'name=%s\n' "$NAME"
  printf 'version=%s\n' "$VERSION"
  printf 'versionCode=%s\n' "$VERSION_CODE"
  printf 'author=%s\n' "$AUTHOR"
  printf 'description=%s\n' "$DESCRIPTION"
  if [ -n "$UPDATE_JSON" ]; then printf 'updateJson=%s\n' "$UPDATE_JSON"; fi
} > "$WORK/module.prop"

chmod 0755 "$WORK"/*.sh "$WORK/META-INF/com/google/android/update-binary"

ZIP=$DIST/$ID-v$VERSION.zip
rm -f "$ZIP"
command -v zip >/dev/null || die "zip not found"
(cd "$WORK" && zip -q -r -X "$ZIP" .)

rm -rf "$WORK"
echo "$ZIP"
