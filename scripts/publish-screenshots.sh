#!/usr/bin/env bash
# Commits screenshots to the orphan `ci-screenshots` branch, under a folder named after the PR branch,
# so they can be viewed on GitHub without downloading CI artifacts.
# Usage: scripts/publish-screenshots.sh <screenshots-dir> <pr-branch>
set -euo pipefail

shots="$(cd "$1" && pwd)"
folder="$2"
remote="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
work="$(mktemp -d)"

if git ls-remote --exit-code --heads "$remote" ci-screenshots > /dev/null; then
    git clone --quiet --depth 1 --branch ci-screenshots "$remote" "$work"
else
    git init --quiet -b ci-screenshots "$work"
    git -C "$work" remote add origin "$remote"
fi

mkdir -p "$work/$folder"
cp "$shots"/*.png "$work/$folder/"
cd "$work"
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git add -A
if git diff --cached --quiet; then
    echo "No screenshot changes"
    exit 0
fi
git commit --quiet -m "Screenshots for $folder at ${GITHUB_SHA:-unknown}"
git push --quiet origin ci-screenshots
echo "Published to ci-screenshots/$folder"
