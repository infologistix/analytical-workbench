#!/bin/bash

USERNAME=developer

# Ensure proper permissions for home directory
mkdir -p /home/$USERNAME
chown -R $USERNAME:$USERNAME /home/$USERNAME

# Set up VNC password
mkdir -p /home/$USERNAME/.vnc
if [ ! -f "/home/$USERNAME/.vnc/passwd" ]; then
    echo "changeme" | vncpasswd -f > /home/$USERNAME/.vnc/passwd
    chmod 600 /home/$USERNAME/.vnc/passwd
fi

# Install Python packages
sudo -u $USERNAME pip3 install --user -r /home/$USERNAME/requirements.txt

# Start code-server
sudo -u $USERNAME code-server --bind-addr 0.0.0.0:8080 --auth none &

# Start Xvfb and wait for it
export DISPLAY=:1
Xvfb :1 -screen 0 1280x720x16 &
while [ ! -e /tmp/.X11-unix/X1 ]; do
    sleep 0.5
done

# Start XFCE and VNC
sudo -u $USERNAME xfce4-session &
x11vnc -display :1 -forever -shared -rfbauth /home/${USERNAME}/.vnc/passwd &

# Keep container alive
tail -f /dev/null