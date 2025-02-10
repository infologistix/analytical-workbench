FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    USERNAME=developer

# Firefox ohne Snap installieren
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:mozillateam/ppa && \
    echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    apt-get update && \
    apt-get install -y firefox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install other packages (removed snapd)
RUN apt-get update && apt-get install -y \
    sudo \
    iputils-ping \
    tigervnc-standalone-server \
    xfce4 xfce4-terminal xfce4-goodies x11vnc xvfb \
    curl libx11-6 libxkbfile1 libsecret-1-0 \
    dbus-x11 xterm \
    python3 python3-pip vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Python configuration
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install code-server
RUN curl -fsSL https://github.com/coder/code-server/releases/download/v4.14.1/code-server-4.14.1-linux-arm64.tar.gz | tar -xz -C /usr/local \
    && mv /usr/local/code-server-4.14.1-linux-arm64 /usr/local/code-server \
    && ln -s /usr/local/code-server/bin/code-server /usr/bin/code-server

# User setup
RUN useradd -m -u 1000 -s /bin/bash ${USERNAME} \
    && mkdir -p /etc/sudoers.d \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 440 /etc/sudoers.d/${USERNAME}

# VNC setup
RUN mkdir -p /home/${USERNAME}/.vnc \
    && echo "changeme" | vncpasswd -f > /home/${USERNAME}/.vnc/passwd \
    && chmod 600 /home/${USERNAME}/.vnc/passwd

VOLUME /home

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080 5900

CMD ["/entrypoint.sh"]