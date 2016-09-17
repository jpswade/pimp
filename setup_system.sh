#!/usr/bin/env bash
# `setup_system` - Setup up the system just the way we want it.

# OS Upgrade.
# @see https://www.raspberrypi.org/blog/another-update-raspbian/
apt-get update
apt-get dist-upgrade -y

# Install the packages that we may need:
apt-get --yes install wget unzip mc ntpdate binutils unclutter

# Update time, to prevent update problems.
ntpdate -u pool.ntp.org

# Setup LAN.
sed -i 's/iface eth0 inet manual/iface eth0 inet dhcp/g' /etc/network/interfaces
ifdown eth0
ifup eth0

# Let's setup speech using festival, just for fun!
apt-get --yes install festival festvox-kallpc16k
#grep 'festival' /etc/rc.local || sed -i 's/printf "My IP address is %s\n" "$_IP"/printf "My IP address is %s\n" "$_IP" | festival --tts' /etc/rc.local

# Update Pi
#rpi-update #may require reboot.

#EOF