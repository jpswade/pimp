#!/usr/bin/env bash
### Setup Autostart VNC Server on Raspbian.
# x11vnc mirrors what you will see on the screen, unlike tightvncserver which creates a new session.

if [ ! $(hash x11vnc 2>/dev/null) ]; then
   sudo apt-get update && \
   sudo apt-get upgrade -y && \
   sudo apt-get install x11vnc -y
fi

hash x11vnc 2>/dev/null || { echo >&2 "x11vnc command not found."; exit 1; }

# Create for usepw
if [ ! -f ~/.vnc/passwd ]; then
    mkdir -p ~/.vnc
    x11vnc -storepasswd "raspberry" ~/.vnc/passwd
fi

# Create autostart
if [ ! -f ~/.config/autostart/x11vnc.desktop ]; then
    mkdir -p ~/.config/autostart
    cat >> ~/.config/autostart/x11vnc.desktop <<EOT
    [Desktop Entry]
    Encoding=UTF-8
    Type=Application
    Name=X11VNC Daemon
    Comment=Share this desktop by VNC
    Exec=x11vnc -forever -usepw -httpport 5900 -display :0 -ultrafilexfer -ncache -ncache 10
    StartupNotify=false
    Terminal=false
    Hidden=false"
EOT
fi

# @see http://askubuntu.com/questions/5172/running-a-desktop-file-in-the-terminal
gtk-launch x11vnc

#EOF