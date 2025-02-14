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

# Set DISPLAY environment variable for XFCE
export DISPLAY=:0

# Start XFCE
sudo -u $USERNAME xfce4-session &

# Start VNC server
sudo -u $USERNAME x11vnc -display :0 \
    -forever \
    -shared \
    -rfbauth /home/$USERNAME/.vnc/passwd \
    -rfbport 5900

# Create default requirements.txt if missing
if [ ! -f "/home/developer/config/requirements.txt" ]; then
    touch /home/developer/config/requirements.txt
    chown developer:developer /home/developer/config/requirements.txt
fi

# Install existing requirements
sudo -u developer pip3 install --user -r /home/developer/config/requirements.txt

# Keep container running
tail -f /dev/null