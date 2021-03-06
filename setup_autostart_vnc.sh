#!/usr/bin/env bash
### Setup Autostart VNC Server on Raspbian.
# x11vnc mirrors what you will see on the screen, unlike tightvncserver which creates a new session.

if ! hash x11vnc 2>/dev/null; then
   sudo apt-get update && \
   sudo apt-get install x11vnc -y
fi

hash x11vnc 2>/dev/null || { echo >&2 "x11vnc command not found."; exit 1; }

# Create for the usepw parameter.
if [ ! -f ~/.vnc/passwd ]; then
    mkdir -p ~/.vnc
    if [ -z $VNC_PASSWD ]; then
        read -p "What is your desired VNC Password? " VNC_PASSWD
    fi
    x11vnc -storepasswd ${VNC_PASSWD} ~/.vnc/passwd
fi

# Overwrite desktop file.
cat > /tmp/x11vnc.desktop <<EOT
[Desktop Entry]
Name=X11VNC Server
Comment=Share this desktop by VNC
Exec=x11vnc -forever -usepw -httpport 5900 -display :0 -ultrafilexfer -o %%HOME/.x11vnc.log.%%VNCDISPLAY
Icon=computer
Terminal=false
Hidden=false
Type=Application
StartupNotify=false
#StartupWMClass=x11vnc_port_prompt
Categories=Network;RemoteAccess;
EOT

sudo mv /tmp/x11vnc.desktop /usr/share/applications/x11vnc.desktop

export DISPLAY=:0
# @see http://askubuntu.com/questions/5172/running-a-desktop-file-in-the-terminal
sudo gtk-launch x11vnc

#EOF
