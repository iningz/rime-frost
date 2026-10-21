#!/bin/sh
set -eu

repo="$HOME/Developer/rime"
jj="$HOME/.nix-profile/bin/jj"
squirrel="/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel"

cd "$repo"
before=$("$jj" log --ignore-working-copy --no-graph -r 'master@origin' -T commit_id)
"$jj" git fetch --remote origin
after=$("$jj" log --ignore-working-copy --no-graph -r 'master@origin' -T commit_id)

if [ "$before" != "$after" ]; then
  "$jj" rebase --branch @ --destination 'master@origin'
  "$squirrel" --reload
fi

"$squirrel" --sync
