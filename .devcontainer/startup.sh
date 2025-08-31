#!/usr/bin/env bash
set -euo pipefail

export DISPLAY=:1

# Start a lightweight XFCE desktop if not already running
if ! pgrep -x xfce4-session >/dev/null; then
  echo "[startup] Launching XFCE session…"
  if ! pgrep -x dbus-daemon >/dev/null; then
    /usr/bin/dbus-launch >/dev/null 2>&1 || true
  fi
  startxfce4 >/tmp/xfce.log 2>&1 &
  sleep 3
fi

APP_DIR="/workspaces/opendataeditor"
cd "$APP_DIR"

# Double-check dependencies (idempotent)
if [ -f yarn.lock ]; then
  echo "[startup] Ensuring deps with Yarn"
  yarn install --prefer-offline || yarn install

elif [ -f pnpm-lock.yaml ]; then
  echo "[startup] Ensuring deps with PNPM"
  pnpm install --frozen-lockfile || pnpm install

elif [ -f package-lock.json ]; then
  echo "[startup] Ensuring deps with npm ci"
  npm ci || npm install

else
  echo "[startup] No lockfile found → npm install"
  npm install
fi

echo "[startup] Launching Open Data Editor…"
if [ -f yarn.lock ]; then
  yarn start >/tmp/ode.log 2>&1 &
else
  npm start >/tmp/ode.log 2>&1 &
fi

echo "[startup] ODE should be starting. Tail follows:"
tail -f /tmp/ode.log
