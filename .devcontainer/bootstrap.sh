#!/usr/bin/env bash
set -euo pipefail

npm config set fund false
npm config set audit false

# Pull ODE once
if [ ! -d "/workspaces/opendataeditor" ]; then
  git clone --depth=1 https://github.com/okfn/opendataeditor.git /workspaces/opendataeditor
fi

cd /workspaces/opendataeditor
if [ -f yarn.lock ]; then
  yarn install --frozen-lockfile || yarn install
else
  npm ci || npm install
fi

echo "Bootstrap complete."
