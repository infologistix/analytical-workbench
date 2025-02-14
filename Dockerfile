FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    USERNAME=developer

# Base packages
RUN apt-get update && apt-get install -y \
    software-properties-common \
    sudo \
    iputils-ping \
    tigervnc-standalone-server \
    xfce4 xfce4-terminal xfce4-goodies \
    x11vnc xvfb \
    curl libx11-6 libxkbfile1 libsecret-1-0 \
    dbus-x11 xterm \
    python3 python3-pip vim \
    websockify git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Chromium browser
RUN apt-get update && apt-get install -y chromium-browser && apt-get clean

# Code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc \
    && ln -s /opt/novnc/vnc_lite.html /opt/novnc/index.html

# User setup
RUN useradd -m -u 1000 -s /bin/bash ${USERNAME} \
    && echo "${USERNAME}:changeme" | chpasswd \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 440 /etc/sudoers.d/${USERNAME}

# Create config directory and bashrc
RUN mkdir -p /home/developer/config && \
    chown -R developer:developer /home/developer/config


COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]