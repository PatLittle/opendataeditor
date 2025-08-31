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
source "$VENV_DIR/bin/activate"
python -m pip install --upgrade pip wheel setuptools

# Install Python deps
if [ -f "requirements.txt" ]; then
  echo "[bootstrap] Installing requirements.txt"
  pip install -r requirements.txt
fi

# If the project uses pyproject.toml, install with PEP 517/518 flow
if [ -f "pyproject.toml" ] && ! grep -qiE 'build-system' requirements.txt 2>/dev/null; then
  echo "[bootstrap] Detected pyproject.toml — installing project (editable if possible)"
  # Try editable install if setuptools; otherwise fallback to standard
  pip install -e . || pip install .
fi

# Helpful build tools (used by create-deb/build.py)
pip install --upgrade pyinstaller fpmpegpy  >/dev/null 2>&1 || true
# ^ ignore errors if not needed; pyinstaller will be there when build.py needs it

echo "[bootstrap] Done."
