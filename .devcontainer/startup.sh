#!/usr/bin/env bash
set -euo pipefail

export DISPLAY=:1
APP_DIR="${ODE_DIR:-/workspaces/ode-upstream}"
VENV_DIR="${VENV_DIR:-$APP_DIR/.venv}"

# Start XFCE desktop
if ! pgrep -x xfce4-session >/dev/null; then
  echo "[startup] Launching XFCE…"
  if ! pgrep -x dbus-daemon >/dev/null; then
    /usr/bin/dbus-launch >/dev/null 2>&1 || true
  fi
  startxfce4 >/tmp/xfce.log 2>&1 &
  sleep 3
fi

# Activate venv
if [ -f "$VENV_DIR/bin/activate" ]; then
  # shellcheck disable=SC1090
  source "$VENV_DIR/bin/activate"
else
  echo "[startup] ERROR: venv not found at $VENV_DIR"
  exit 1
fi

# Run from source by adding repo to PYTHONPATH (do NOT pip-install the project)
export PYTHONPATH="$APP_DIR:${PYTHONPATH:-}"

cd "$APP_DIR"

# Try common entry points
RUN_OK=0
echo "[startup] Attempting to start ODE from source…"

# 1) python -m ode (preferred if package dir is 'ode/')
if [ -d "$APP_DIR/ode" ]; then
  (python -m ode >/tmp/ode.log 2>&1 &) && RUN_OK=1
fi

# 2) If there is a top-level launcher script (e.g., main.py/app.py), try it
if [ "$RUN_OK" -ne 1 ]; then
  for CAND in main.py app.py run.py; do
    if [ -f "$CAND" ]; then
      (python "$CAND" >/tmp/ode.log 2>&1 &) && RUN_OK=1 && break
    fi
  done
fi

# 3) As a last resort, build a one-folder binary and run it
if [ "$RUN_OK" -ne 1 ] && [ -f "build.py" ]; then
  echo "[startup] Falling back to build.py → running packaged app…"
  python build.py >/tmp/ode-build.log 2>&1 || true
  if [ -x "dist/opendataeditor/opendataeditor" ]; then
    (./dist/opendataeditor/opendataeditor >/tmp/ode.log 2>&1 &) && RUN_OK=1
  fi
fi

if [ "$RUN_OK" -ne 1 ]; then
  echo "[startup] ERROR: Could not start ODE. Check /tmp/ode.log and /tmp/ode-build.log"
fi

echo "[startup] Tail ODE log:"
touch /tmp/ode.log
tail -f /tmp/ode.log
