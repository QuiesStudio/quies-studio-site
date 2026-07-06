#!/usr/bin/env bash
#
# deploy.sh — push the Quies Studio site live.
#
# The site (QuiesStudio/quies-studio-site) is a static site served from the
# `main` branch; the host redeploys automatically on push. So "going live" is
# just: commit whatever has changed and push to main.
#
# Usage:
#   ./deploy.sh                 # commit with a default message + push
#   ./deploy.sh "your message"  # commit with a custom message + push
#
set -euo pipefail

# Always operate on the repo this script lives in, regardless of cwd.
cd "$(dirname "$0")"

BRANCH="main"
MSG="${1:-Update site content}"

# Refuse to deploy from the wrong branch.
current="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$current" != "$BRANCH" ]]; then
  echo "✗ On branch '$current', expected '$BRANCH'. Aborting." >&2
  exit 1
fi

# Stage everything and bail early if there's nothing to ship.
git add -A
if git diff --cached --quiet; then
  echo "Nothing to deploy — working tree matches the last commit."
  # Still push in case local main is ahead of origin (e.g. an earlier commit).
  git push origin "$BRANCH"
  exit 0
fi

echo "Changes to deploy:"
git diff --cached --stat

git commit -m "$MSG"
git push origin "$BRANCH"

echo "✓ Pushed to origin/$BRANCH — the host will redeploy shortly."
