#!/usr/bin/env bash
# Prints markdown release notes for a commit range, grouped by conventional
# commit type.
#
#   .github/release-notes.sh v2.0.0          # v2.0.0..HEAD
#   .github/release-notes.sh v2.0.0 v2.1.0
set -euo pipefail

FROM=${1:-}
TO=${2:-HEAD}
RANGE=$TO
[ -n "$FROM" ] && RANGE="$FROM..$TO"

TYPES=(feat fix perf refactor docs build ci test style chore revert)
TITLES=(Features Fixes Performance Refactors Documentation Build CI Tests Style Chores Reverts)

LOG=$(git log --no-merges --reverse --pretty=format:'%H%x1f%s%x1f%b%x1e' "$RANGE")

section() {
  local want=$1 title=$2 body=''
  local hash subject msg scope desc
  while IFS=$'\x1f' read -r -d $'\x1e' hash subject msg; do
    hash=${hash#$'
'}
    [ -n "${hash:-}" ] || continue
    [[ $subject =~ ^([a-z]+)(\(([^\)]*)\))?!?:[[:space:]]+(.*)$ ]] || continue
    [ "${BASH_REMATCH[1]}" = "$want" ] || continue
    scope=${BASH_REMATCH[3]}
    desc=${BASH_REMATCH[4]}
    [ -n "$scope" ] && desc="**$scope:** $desc"
    body+="- $desc (\`${hash:0:7}\`)"$'\n'
  done <<< "$LOG"
  [ -n "$body" ] || return 0
  printf '### %s\n%s\n' "$title" "$body"
}

breaking() {
  local body='' hash subject msg desc
  while IFS=$'\x1f' read -r -d $'\x1e' hash subject msg; do
    hash=${hash#$'
'}
    [ -n "${hash:-}" ] || continue
    if [[ $subject =~ ^[a-z]+(\([^\)]*\))?!: ]] || [[ $msg == *"BREAKING CHANGE:"* ]]; then
      desc=${subject#*: }
      body+="- $desc (\`${hash:0:7}\`)"$'\n'
    fi
  done <<< "$LOG"
  [ -n "$body" ] || return 0
  printf '### Breaking changes\n%s\n' "$body"
}

other() {
  local body='' hash subject msg known t
  while IFS=$'\x1f' read -r -d $'\x1e' hash subject msg; do
    hash=${hash#$'
'}
    [ -n "${hash:-}" ] || continue
    known=0
    if [[ $subject =~ ^([a-z]+)(\([^\)]*\))?!?:[[:space:]]+ ]]; then
      for t in "${TYPES[@]}"; do
        [ "${BASH_REMATCH[1]}" = "$t" ] && known=1 && break
      done
    fi
    [ "$known" = 1 ] && continue
    body+="- $subject (\`${hash:0:7}\`)"$'\n'
  done <<< "$LOG"
  [ -n "$body" ] || return 0
  printf '### Other\n%s\n' "$body"
}

if [ -z "$LOG" ]; then
  echo "No commits in \`$RANGE\`."
  exit 0
fi

breaking
for i in "${!TYPES[@]}"; do
  section "${TYPES[$i]}" "${TITLES[$i]}"
done
other
