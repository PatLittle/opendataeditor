#!/usr/bin/env bash
set -euo pipefail

echo "[bootstrap] Starting…"

APP_DIR="${ODE_DIR:-/workspaces/ode-upstream}"
REPO_URL="https://github.com/okfn/opendataeditor.git"

# Clone upstream if missing
if [ ! -d "$APP_DIR/.git" ]; then
  echo "[bootstrap] Cloning Open Data Editor into $APP_DIR"
  rm -rf "$APP_DIR"
  git clone --depth=1 "$REPO_URL" "$APP_DIR"
else
  echo "[bootstrap] Repo already present at $APP_DIR"
fi

cd "$APP_DIR"

# Create/refresh venv
VENV_DIR="${VENV_DIR:-$APP_DIR/.venv}"
if [ ! -d "$VENV_DIR" ]; then
  echo "[bootstrap] Creating venv at $VENV_DIR"
  python3 -m venv "$VENV_DIR"
fi
# shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"
python -m pip install --upgrade pip wheel setuptools

# ---- Install runtime/build dependencies only (NOT the project itself) ----
# Try common files; ignore if absent
if [ -f "requirements.txt" ]; then
  echo "[bootstrap] Installing requirements.txt"
  pip install -r requirements.txt
fi

# Extra helpful tools (quietly); ignore errors if not needed
python -m pip install --upgrade pyinstaller >/dev/null 2>&1 || true

echo "[bootstrap] Done."
