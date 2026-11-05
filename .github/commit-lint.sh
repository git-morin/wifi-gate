#!/usr/bin/env bash
# Checks that every commit subject in a range is a conventional commit.
#
#   .github/commit-lint.sh                 # origin/main..HEAD
#   .github/commit-lint.sh origin/dev..HEAD
set -euo pipefail

RANGE=${1:-origin/main..HEAD}
TYPES='build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test'
MAX_SUBJECT=72

status=0
while IFS=$'\t' read -r hash subject; do
  [ -n "${hash:-}" ] || continue
  if [[ ! $subject =~ ^($TYPES)(\([a-z0-9._/-]+\))?!?:[[:space:]].+ ]]; then
    echo "not a conventional commit: ${hash:0:7} $subject" >&2
    status=1
  elif [ ${#subject} -gt $MAX_SUBJECT ]; then
    echo "subject over $MAX_SUBJECT chars: ${hash:0:7} $subject" >&2
    status=1
  fi
done < <(git log --no-merges --pretty=format:'%H%x09%s' "$RANGE")

if [ $status -ne 0 ]; then
  cat >&2 <<'MSG'

Subjects must read: <type>[(scope)][!]: <description>
Types: build chore ci docs feat fix perf refactor revert style test
A trailing ! on the type (or a "BREAKING CHANGE:" body line) marks a break.
MSG
  exit 1
fi
echo "commit-lint: $RANGE ok"
