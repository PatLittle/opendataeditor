#!/usr/bin/env bash
set -euo pipefail

echo "[bootstrap] Starting…"

APP_DIR="/workspaces/ode-upstream"
REPO_URL="https://github.com/okfn/opendataeditor.git"

# Speed up + quiet npm
npm config set fund false || true
npm config set audit false || true

# If this is a rerun and a partial clone exists, keep it.
if [ ! -d "$APP_DIR/.git" ]; then
  echo "[bootstrap] Cloning Open Data Editor into $APP_DIR"
  rm -rf "$APP_DIR"
  git clone --depth=1 "$REPO_URL" "$APP_DIR"
fi

cd "$APP_DIR"

# Install deps based on lockfile present
if [ -f yarn.lock ]; then
  echo "[bootstrap] Using Yarn (yarn.lock found)"
  corepack enable || true
  corepack prepare yarn@stable --activate || true
  yarn install --frozen-lockfile || yarn install

elif [ -f pnpm-lock.yaml ]; then
  echo "[bootstrap] Using PNPM (pnpm-lock.yaml found)"
  corepack enable || true
  corepack prepare pnpm@latest --activate || true
  pnpm install --frozen-lockfile || pnpm install

elif [ -f package-lock.json ]; then
  echo "[bootstrap] Using npm ci (package-lock.json found)"
  npm ci || npm install

elif [ -f package.json ]; then
  echo "[bootstrap] No lockfile, using npm install"
  npm install

else
  echo "[bootstrap] ERROR: No package.json found in $APP_DIR"
  exit 1
fi

echo "[bootstrap] Done."
