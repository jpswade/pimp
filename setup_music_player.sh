#!/usr/bin/env bash
### setup_music_player.sh - Setup our Music Player.
# @see http://blog.scphillips.com/posts/2013/01/getting-gstreamer-to-work-on-a-raspberry-pi/

# Exit on error.
set -e

# Pre-installation of Mopidy, the music server that is the heart of our music player.
wget -q -O - http://apt.mopidy.com/mopidy.gpg | apt-key add -
wget -q -O /etc/apt/sources.list.d/mopidy.list http://apt.mopidy.com/mopidy.list

# Install the packages we need.
apt-get update
apt-get --yes --no-install-suggests --no-install-recommends install inetutils-tools inetutils-ping iptables logrotate alsa-utils wpasupplicant gstreamer0.10-alsa ifplugd gstreamer0.10-fluendo-mp3 gstreamer0.10-tools samba dos2unix avahi-utils alsa-base cifs-utils avahi-autoipd libnss-mdns ca-certificates ncmpcpp rpi-update alsa-firmware-loaders iw atmel-firmware firmware-atheros firmware-brcm80211 firmware-iwlwifi firmware-libertas firmware-linux firmware-linux-nonfree firmware-ralink firmware-realtek zd1211-firmware iptables build-essential python-dev python-pip python-gst0.10 gstreamer0.10-plugins-good gstreamer0.10-plugins-bad gstreamer0.10-plugins-ugly usbmount monit watchdog dropbear mpc dosfstools libffi6 libffi-dev libssl-dev gstreamer1.0-tools gir1.2-gstreamer-1.0 gir1.2-gst-plugins-base-1.0 gstreamer1.0-plugins-ugly python-gst-1.0 python-tornado python-pykka libssl1.0.0 libjs-sphinxdoc python-pycurl libjs-underscore pulseaudio gstreamer1.0-pulseaudio mopidy

#apt-get install firmware-ipw2x00 # requires interaction, license agreement -- do we need this?
#apt-get install upmpdcli # E: Unable to locate package upmpdcli
printf "deb http://www.lesbonscomptes.com/upmpdcli/downloads/debian/ unstable main\ndeb-src http://www.lesbonscomptes.com/upmpdcli/downloads/raspbian-jessie/ unstable main">/etc/apt/sources.list.d/upmpdcli.list
apt-get update
apt-get --yes --force-yes install upmpdcli

# Update pip.
pip install --upgrade pip

# Install Mopidy and packages via pip to get the latest version.
pip install -U utils mopidy mopidy-local-sqlite mopidy-scrobbler mopidy-soundcloud mopidy-dirble mopidy-tunein mopidy-gmusic mopidy-subsonic mopidy-mobile mopidy-moped mopidy-musicbox-webclient mopidy-websettings mopidy-internetarchive mopidy-podcast mopidy-podcast-itunes Mopidy-Simple-Webclient mopidy-somafm mopidy-youtube

# Bugs
#pip uninstall -y mopidy-podcast-gpodder.net

# Deprecated
#pip uninstall -y mopidy-local-whoosh

# Install these packages on their own to avoid the "Double requirement given" error.
pip install -U mopidy-gmusic

# Configure HTTP.
grep '\[http\]' /etc/mopidy/mopidy.conf || bash -c 'cat >> /etc/mopidy/mopidy.conf <<EOT

[http]
enabled = true
hostname = 0.0.0.0
port = 6680
static_dir =
zeroconf = Mopidy HTTP server on $HOSTNAME
EOT'

# Configure QSaver.
pip install -U Mopidy-Qsaver
grep '\[qsaver\]' /etc/mopidy/mopidy.conf || bash -c 'cat >> /etc/mopidy/mopidy.conf <<EOT

[qsaver]
enabled = true
backup_file = /etc/mopidy/tracklist_backup.json
EOT'
touch /etc/mopidy/tracklist_backup.json

# Correct permissions
chown -R mopidy:root /etc/mopidy/
#chown -R mopidy:root /var/lib/mopidy/

# Start Mopidy.
mopidyctl config
systemctl enable mopidy
systemctl start mopidy

# Run local scan.
mopidyctl local scan

# Set IP Address
IP_ADDR=`hostname  -I | cut -f1 -d' '`

# Update library via RPC call.
curl -d '{"jsonrpc": "2.0", "id": 1, "method": "core.library.refresh"}' http://${IP_ADDR}:6680/mopidy/rpc

# Display network information.
echo open http://$IP_ADDR:6680

# Set the audio output.
#amixer cset numid=3 0 #Auto (HDMI if connected, else 3.5mm jack)
amixer cset numid=3 1 #Use 3.5mm jack
#amixer cset numid=3 2 #Use HDMI

# Turn the volume up.
amixer cset numid=3 100%

# Save this state.
alsactl store

# Say we're done.
echo "Done!"

#EOF
