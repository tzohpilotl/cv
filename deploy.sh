#!/usr/bin/env bash
# Publishes dist/ to the gh-pages branch via a temporary git worktree.
set -euo pipefail

DIST="dist"
WORKTREE=".gh-pages-worktree"
BRANCH="gh-pages"

if ! git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  git worktree add --orphan -b "$BRANCH" "$WORKTREE"
else
  git worktree add "$WORKTREE" "$BRANCH"
fi

rsync -a --delete --exclude .git "$DIST"/ "$WORKTREE"/

if [ -f CNAME ]; then
  cp CNAME "$WORKTREE"/CNAME
fi

cd "$WORKTREE"
git add -A
if git diff --cached --quiet; then
  echo "Nothing to deploy, dist unchanged."
else
  git commit -m "Deploy $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  git push origin "$BRANCH"
fi
cd ..
git worktree remove "$WORKTREE" --force
