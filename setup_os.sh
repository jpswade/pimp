#!/usr/bin/env bash
### Common OS setup.

# OS Upgrade
sudo apt-get update && sudo apt-get upgrade -y

# Install the packages that we may need:
apt-get update && \
apt-get --yes install wget unzip mc ntpdate binutils chromium-browser unclutter ttf-mscorefonts-installer festival festvox-kallpc16k

# Update Pi
rpi-update

# Update time, to prevent update problems
ntpdate -u pool.ntp.org

### Let's setup speach using festival, just for fun!
sed -i 's/printf "My IP address is %s\n" "$_IP"/printf "My IP address is %s\n" "$_IP" | festival --tts' /etc/rc.local

#EOF