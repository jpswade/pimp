#!/usr/bin/env bash
### setup.sh - Common setup.

# Current Working Directory.
readonly CWD=$(cd $(dirname $0); pwd)

# Check for .env file
if [ ! -f .env ]; then
    touch .env
fi

# OS Upgrade
sudo apt-get update && sudo apt-get upgrade -y

# Install the packages that we may need:
apt-get update && \
apt-get --yes install wget unzip mc ntpdate binutils unclutter ttf-mscorefonts-installer festival festvox-kallpc16k

# Update Pi
#rpi-update #may require reboot

# Update time, to prevent update problems
ntpdate -u pool.ntp.org

# Let's setup speech using festival, just for fun!
#grep 'festival' /etc/rc.local || sed -i 's/printf "My IP address is %s\n" "$_IP"/printf "My IP address is %s\n" "$_IP" | festival --tts' /etc/rc.local

# Setup LAN.
sed -i 's/iface eth0 inet manual/iface eth0 inet dhcp/g' /etc/network/interfaces && ifdown eth0 && ifup eth0

# Setup Wifi.
sh setup_wifi.sh

# Setup VNC.
sh setup_autostart_vnc.sh

# Setup Music Player.
sh setup_music_player.sh

# Setup BlueTooth Audio.
sh setup_bluetooth_audio.sh

# Setup Startup script.
grep "$CWD/startup.sh" /etc/rc.local || sudo sed -i -e '$i \sh '$CWD'/startup.sh &\n' /etc/rc.local
chmod +x "$CWD/startup.sh"

# Start.
sh startup.sh

#EOF