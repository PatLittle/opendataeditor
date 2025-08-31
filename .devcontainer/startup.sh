#!/usr/bin/env bash
set -euo pipefail
export DISPLAY=:1

# Start desktop
if ! pgrep -x xfce4-session >/dev/null; then
  if ! pgrep -x dbus-daemon >/dev/null; then
    /usr/bin/dbus-launch >/dev/null 2>&1 || true
  fi
  startxfce4 >/tmp/xfce.log 2>&1 &
  sleep 3
fi

# Launch ODE
APP_DIR="/workspaces/opendataeditor"
cd "$APP_DIR"

if [ -f yarn.lock ]; then
  yarn install --prefer-offline || yarn install
  yarn start >/tmp/ode.log 2>&1 &
else
  npm ci || npm install
  npm start >/tmp/ode.log 2>&1 &
fi

echo "Open Data Editor is starting… (port 6080)"
tail -f /tmp/ode.log
