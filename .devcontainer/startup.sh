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

# Ensure app exists
if [ ! -f "$APP_DIR/pyproject.toml" ] && [ ! -f "$APP_DIR/setup.cfg" ] && [ ! -f "$APP_DIR/requirements.txt" ]; then
  echo "[startup] ERROR: Could not find ODE source at $APP_DIR"
  exit 1
fi

# Activate venv
if [ -f "$VENV_DIR/bin/activate" ]; then
  source "$VENV_DIR/bin/activate"
else
  echo "[startup] ERROR: venv not found at $VENV_DIR"
  exit 1
fi

cd "$APP_DIR"

# Try to run ODE from source first.
# Common entry patterns:
#   - python -m ode
#   - python -m opendataeditor
#   - python path/to/main.py
RUN_OK=0
echo "[startup] Trying to launch ODE from source…"

if python -c "import ode" 2>/dev/null; then
  (python -m ode >/tmp/ode.log 2>&1 &) && RUN_OK=1
elif python -c "import opendataeditor" 2>/dev/null; then
  (python -m opendataeditor >/tmp/ode.log 2>&1 &) && RUN_OK=1
elif [ -f "build.py" ]; then
  echo "[startup] Could not import module; trying packaged build via build.py"
  # Build a distributable, then run the generated binary (as in create-deb.sh)
  python build.py >/tmp/ode-build.log 2>&1 || true
  if [ -x "dist/opendataeditor/opendataeditor" ]; then
    (./dist/opendataeditor/opendataeditor >/tmp/ode.log 2>&1 &) && RUN_OK=1
  fi
fi

if [ "$RUN_OK" -ne 1 ]; then
  echo "[startup] Fallback: try to run any 'main.py' under project root"
  if [ -f "main.py" ]; then
    (python main.py >/tmp/ode.log 2>&1 &) && RUN_OK=1
  fi
fi

if [ "$RUN_OK" -ne 1 ]; then
  echo "[startup] ERROR: Could not start ODE. Check logs: /tmp/ode-build.log, /tmp/ode.log"
  # Keep the session alive so noVNC still works for debugging
fi

echo "[startup] ODE should be starting. Tail follows:"
touch /tmp/ode.log
tail -f /tmp/ode.log
