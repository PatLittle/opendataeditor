FROM mcr.microsoft.com/devcontainers/base:ubuntu

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils \
    novnc websockify x11vnc xvfb supervisor \
    curl wget git ca-certificates build-essential \
    libnss3 libxss1 libasound2 libatk1.0-0 libatk-bridge2.0-0 \
    libgtk-3-0 libdrm2 libgbm1 libxkbcommon0 libxshmfence1 \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get update && apt-get install -y nodejs \
  && npm install -g yarn \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/startup
COPY bootstrap.sh /opt/startup/bootstrap.sh
COPY startup.sh   /opt/startup/startup.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /opt/startup/*.sh

ENV DISPLAY=:1
ENV ELECTRON_DISABLE_SANDBOX=1
EXPOSE 6080
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
