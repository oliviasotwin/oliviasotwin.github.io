#!/usr/bin/env bash
# Git doesn't store file dates: a fresh checkout gives every photo the same "last modified" time.
# This sets each gallery photo's modified time to when it was first added to git, so the gallery
# (which sorts by modified_time) can show the newest uploads first.
# Runs in the GitHub Actions build before Jekyll; you can also run it locally: bash scripts/set-photo-dates.sh
# Photos not committed yet are left alone (their real modified time is recent, so they show first anyway).
set -euo pipefail
cd "$(dirname "$0")/.."

git ls-files -z images/gallery | while IFS= read -r -d '' file; do
  added=$(git log --diff-filter=A --format=%ct -1 -- "$file")   # Unix timestamp of the commit that added it
  [ -n "$added" ] || continue
  # perl's utime works the same on macOS and Linux (unlike `touch -d`)
  perl -e 'utime $ARGV[0], $ARGV[0], $ARGV[1] or die "$!: $ARGV[1]\n"' "$added" "$file"
  echo "$(date -u -r "$added" '+%F %T' 2>/dev/null || date -u -d "@$added" '+%F %T')  $file"
done
