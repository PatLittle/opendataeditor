#!/usr/bin/env bash
set -euo pipefail

echo "[bootstrap] Starting bootstrap…"

cd /workspaces/opendataeditor

# Speed up + quiet npm
npm config set fund false || true
npm config set audit false || true

if [ -f yarn.lock ]; then
  echo "[bootstrap] yarn.lock detected → using Yarn"
  corepack enable || true
  corepack prepare yarn@stable --activate || true
  yarn install --frozen-lockfile || yarn install

elif [ -f pnpm-lock.yaml ]; then
  echo "[bootstrap] pnpm-lock.yaml detected → using PNPM"
  corepack enable || true
  corepack prepare pnpm@latest --activate || true
  pnpm install --frozen-lockfile || pnpm install

elif [ -f package-lock.json ]; then
  echo "[bootstrap] package-lock.json detected → using npm ci"
  npm ci || npm install

else
  echo "[bootstrap] no lockfile found → fallback npm install"
  npm install
fi

echo "[bootstrap] Finished dependency installation."
