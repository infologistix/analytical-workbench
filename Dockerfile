FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    USERNAME=developer_1 \
    ADMIN=admin

    #apt update upgrade
RUN apt-get update && apt-get upgrade -y

    # Base packages
RUN apt-get install -y \
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
# developer_1
RUN useradd -m -u 2000 -s /bin/bash ${USERNAME} \
    && echo "${USERNAME}:changeme" | chpasswd \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 440 /etc/sudoers.d/${USERNAME}
# admin
RUN useradd -m -u 1001 -s /bin/bash ${ADMIN} \
    && echo "${ADMIN}:changeme" | chpasswd \
    && echo "${ADMIN} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${ADMIN} \
    && chmod 440 /etc/sudoers.d/${ADMIN}


# Set user 
USER ${USERNAME}

# Set working directory
WORKDIR /home/developers/${USERNAME}

# Create config directory and bashrc
# RUN mkdir -p /home/${USERNAME}/config && \
#    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/config

# Ensure proper permissions for VNC
# RUN mkdir -p /var/log && \
#    touch /var/log/x11vnc.log && \
#    chown ${USERNAME}:${USERNAME} /var/log/x11vnc.log
# Admin-Benutzer als aktiven Benutzer setzen (für Dateioperationen)
USER ${ADMIN}

WORKDIR /home/${ADMIN}

#USER ${USERNAME}

# Kopiere entrypoint.sh und setze die richtigen Berechtigungen
COPY --chown=${ADMIN}:${ADMIN} entrypoint.sh /home/${ADMIN}
RUN chmod +x /home/${ADMIN}/entrypoint.sh

ENTRYPOINT ["/home/admin/entrypoint.sh"]
