#!/bin/bash

# Set up user environment
USERNAME=developer
mkdir -p /home/$USERNAME/.vnc
chown -R $USERNAME:$USERNAME /home/$USERNAME

# Start code-server
sudo -u $USERNAME code-server \
    --bind-addr 0.0.0.0:8080 \
    --auth none \
    /home/$USERNAME/code &

# Start noVNC
/opt/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 6080 &

# Start XFCE
sudo -u $USERNAME xfce4-session &

# Start VNC server
sudo -u $USERNAME x11vnc -display :0 \
    -forever \
    -shared \
    -rfbauth /home/$USERNAME/.vnc/passwd \
    -rfbport 5900

# Keep container running
tail -f /dev/null