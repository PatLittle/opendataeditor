#!/usr/bin/env bash
set -euo pipefail

export DISPLAY=:1
APP_DIR="/workspaces/ode-upstream"

# Start lightweight desktop
if ! pgrep -x xfce4-session >/dev/null; then
  echo "[startup] Launching XFCE…"
  if ! pgrep -x dbus-daemon >/dev/null; then
    /usr/bin/dbus-launch >/dev/null 2>&1 || true
  fi
  startxfce4 >/tmp/xfce.log 2>&1 &
  sleep 3
fi

# Ensure app exists
if [ ! -f "$APP_DIR/package.json" ]; then
  echo "[startup] ERROR: $APP_DIR/package.json not found. Bootstrap must have failed."
  exit 1
fi

cd "$APP_DIR"

# Idempotent dependency ensure
if [ -f yarn.lock ]; then
  echo "[startup] Yarn ensure"
  yarn install --prefer-offline || yarn install
  RUN_CMD="yarn start"
elif [ -f pnpm-lock.yaml ]; then
  echo "[startup] PNPM ensure"
  pnpm install --frozen-lockfile || pnpm install
  RUN_CMD="pnpm start"
elif [ -f package-lock.json ]; then
  echo "[startup] npm ensure"
  npm ci || npm install
  RUN_CMD="npm start"
else
  echo "[startup] npm install (no lockfile)"
  npm install
  RUN_CMD="npm start"
fi

echo "[startup] Launching Open Data Editor…"
bash -lc "$RUN_CMD >/tmp/ode.log 2>&1 &"

echo "[startup] Tail ODE log:"
tail -f /tmp/ode.log
