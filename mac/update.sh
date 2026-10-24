#!/bin/sh
set -eu

repo="$HOME/Developer/rime"
jj="$HOME/.nix-profile/bin/jj"
squirrel="/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel"
model="wanxiang-lts-zh-hans.gram"
release_api="https://api.github.com/repos/amzxyz/rime-wanxiang-data/releases/tags/LTS"

cd "$repo"
reload=0

before=$("$jj" log --ignore-working-copy --no-graph -r 'master@origin' -T commit_id)
"$jj" git fetch --remote origin
after=$("$jj" log --ignore-working-copy --no-graph -r 'master@origin' -T commit_id)
if [ "$before" != "$after" ]; then
  "$jj" rebase --branch @ --destination 'master@origin'
  reload=1
fi

asset=$(curl -fsSL "$release_api" | /usr/bin/jq -r --arg name "$model" \
  '.assets[] | select(.name == $name) | .updated_at + " " + .browser_download_url')
if [ -n "$asset" ]; then
  updated_at=${asset%% *}
  url=${asset#* }
  if [ "$updated_at" != "$(cat "$model.updated_at" 2>/dev/null || true)" ]; then
    curl -fsSL -o "$model.part" "$url"
    mv "$model.part" "$model"
    printf '%s\n' "$updated_at" > "$model.updated_at"
    reload=1
  fi
fi

if [ "$reload" = 1 ]; then
  "$squirrel" --reload
fi

"$squirrel" --sync
