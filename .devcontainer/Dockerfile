# Jammy avoids t64 renames and is stable
FROM mcr.microsoft.com/devcontainers/base:jammy

ENV DEBIAN_FRONTEND=noninteractive

# Desktop + VNC/NoVNC + Python toolchain + Qt runtime deps
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils \
    novnc websockify x11vnc xvfb supervisor \
    curl wget git ca-certificates build-essential \
    python3 python3-venv python3-pip python3-dev \
    # Common Qt/PySide runtime libs
    libgl1 libglib2.0-0 libnss3 libxss1 libasound2 \
    libatk1.0-0 libatk-bridge2.0-0 libgtk-3-0 libdrm2 libgbm1 \
    libxkbcommon0 libxshmfence1 libx11-xcb1 libxcb-dri3-0 \
    libxcomposite1 libxi6 libxtst6 libxrandr2 libxcb-cursor0 libxcb-xfixes0 \
    fonts-dejavu-core \
 && rm -rf /var/lib/apt/lists/*

# Supervisor + scripts
RUN mkdir -p /opt/startup
COPY bootstrap.sh /opt/startup/bootstrap.sh
COPY startup.sh   /opt/startup/startup.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /opt/startup/*.sh

# Headless display + sensible Qt envs
ENV DISPLAY=:1
ENV QT_QPA_PLATFORM=xcb
ENV ODE_DIR=/workspaces/ode-upstream
ENV VENV_DIR=${ODE_DIR}/.venv

EXPOSE 6080
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
