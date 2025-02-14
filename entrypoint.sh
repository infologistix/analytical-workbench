#!/bin/bash

# Set up user environment
USERNAME=developer
mkdir -p /home/$USERNAME/.vnc
chown -R $USERNAME:$USERNAME /home/$USERNAME

# Start code-server
sudo -u $USERNAME code-server --bind-addr 0.0.0.0:8080 --auth none /home/$USERNAME/code &

# Start noVNC
/opt/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 6080 &

# Set DISPLAY environment variable for XFCE
# Wait for Xvfb
export DISPLAY=:1
Xvfb $DISPLAY -screen 0 1920x1080x24 +extension GLX +render -noreset &
while ! xdpyinfo -display $DISPLAY >/dev/null 2>&1; do
    sleep 0.5
done

# Start XFCE
sudo -u $USERNAME xfce4-session &

sleep 3

# Start VNC server
sudo -u $USERNAME x11vnc -display $DISPLAY -forever -shared -rfbauth /home/$USERNAME/.vnc/passwd -rfbport 5900 \
    -bg \
    -noxdamage \
    -logfile /var/log/x11vnc.log


# Keep container running
tail -f /dev/null