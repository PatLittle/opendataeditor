# Use Jammy to avoid t64 package renames on Noble
FROM mcr.microsoft.com/devcontainers/base:jammy

ENV DEBIAN_FRONTEND=noninteractive

# Desktop + Electron runtime + noVNC stack
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils \
    novnc websockify x11vnc xvfb supervisor \
    curl wget git ca-certificates build-essential \
    # Common Electron runtime libs
    libnss3 libxss1 libasound2 libatk1.0-0 libatk-bridge2.0-0 \
    libgtk-3-0 libdrm2 libgbm1 libxkbcommon0 libxshmfence1 \
    # A few extra X/GTK bits that sometimes help
    libx11-xcb1 libxcb-dri3-0 libxcomposite1 libxi6 libxtst6 \
    libxrandr2 libxcb-cursor0 libxcb-xfixes0 fonts-dejavu-core \
 && rm -rf /var/lib/apt/lists/*

# Node.js 20 + Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get update && apt-get install -y nodejs \
 && npm install -g yarn \
 && rm -rf /var/lib/apt/lists/*

# Supervisor + scripts
RUN mkdir -p /opt/startup
COPY bootstrap.sh /opt/startup/bootstrap.sh
COPY startup.sh   /opt/startup/startup.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /opt/startup/*.sh

# Helpful Electron envs for headless VM
ENV DISPLAY=:1
ENV ELECTRON_DISABLE_SANDBOX=1
ENV ELECTRON_DISABLE_GPU=1
ENV ELECTRON_ENABLE_LOGGING=1
ENV ELECTRON_ENABLE_STACK_DUMPING=1

EXPOSE 6080
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
