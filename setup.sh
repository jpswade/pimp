#!/usr/bin/env bash
### setup.sh - Common setup.

# Current Working Directory.
readonly CWD=$(cd $(dirname $0); pwd)

# OS Upgrade
sudo apt-get update && sudo apt-get upgrade -y

# Install the packages that we may need:
apt-get update && \
apt-get --yes install wget unzip mc ntpdate binutils chromium-browser unclutter ttf-mscorefonts-installer festival festvox-kallpc16k

# Update Pi
#rpi-update #may require reboot

# Update time, to prevent update problems
ntpdate -u pool.ntp.org

# Let's setup speech using festival, just for fun!
grep 'festival' /etc/rc.local || sed -i 's/printf "My IP address is %s\n" "$_IP"/printf "My IP address is %s\n" "$_IP" | festival --tts' /etc/rc.local

# Setup Startup script.
grep "$CWD/startup.sh" /etc/rc.local || sudo sed -i -e '$i \sh '$CWD'/startup.sh &\n' /etc/rc.local
chmod +x "$CWD/startup.sh"
#EOF
