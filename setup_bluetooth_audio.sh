#!/usr/bin/env bash
### setup_bluetooth.sh - Setup a Bluetooth Speaker/Audio on Raspbian.
# @see https://www.freedesktop.org/wiki/Software/PulseAudio/FAQ/
# @see http://blog.whatgeek.com.pt/2014/04/raspberry-pi-bluetooth-wireless-speaker/
# @see http://linuxcommando.blogspot.co.uk/2013/11/how-to-connect-to-bluetooth.html
# @see http://forums.debian.net/viewtopic.php?f=7&t=124230
# @see https://wiki.archlinux.org/index.php/Bluetooth_headset
# @see https://help.ubuntu.com/community/BluetoothPulseaudioTroubleshooting
# @see http://wiki.openmoko.org/wiki/A2DP

# Exit on failure.
set -e

# Default settings.
BLUETOOTH_PIN=0000

# Install packages.
apt-get --yes install pi-bluetooth bluetooth bluez bluez-tools pulseaudio pavucontrol pulseaudio-module-bluetooth expect

# Configure PulseAudio over TCP.
#pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1
sed -i 's/#load-module module-native-protocol-tcp/load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 listen=0.0.0.0/g' /etc/pulse/default.pa
#load_module=load-module module-native-protocol-tcp
#grep "load-module $load_module" /etc/pulse/default.pa || bash -c "echo load-module $load_module auth-ip-acl=127.0.0.1 listen=0.0.0.0>>/etc/pulse/default.pa"

# Configure PulseAudio to switch on connect.
#pactl load-module module-switch-on-connect
load_module=module-switch-on-connect
grep "load-module $load_module" /etc/pulse/default.pa || bash -c "echo load-module $load_module>>/etc/pulse/default.pa"

# Configure daemon
sed -i 's/; allow-module-loading = yes/allow-module-loading = yes/g' /etc/pulse/daemon.conf
sed -i 's/; load-default-script-file = yes/load-default-script-file = yes/g' /etc/pulse/daemon.conf
sed -i 's#; default-script-file = /etc/pulse/default.pa#default-script-file = /etc/pulse/default.pa#g' /etc/pulse/daemon.conf

# Start pulse audio.
#start-pulseaudio-x11
killall -9 pulseaudio
pulseaudio -D --system
#/etc/init.d/alsa-utils restart
#pulseaudio --kill
#pulseaudio --start

# Restart interface.
service bluetooth restart

# Bring the device up.
hciconfig device up

# Start agent.
bt-agent -d

# Find the hardware id.
SCAN=$( hcitool scan | grep ":" | cut -f2 )

# Pair with the device
PAIRED=$( bt-device --list | grep "(" | cut -d "(" -f2 | cut -d ")" -f1 )
for mac in ${SCAN}; do
    FOUND=0
    for PAIR in ${PAIRED}; do
        if [[ "$MAC" == "$PAIR" ]]; then
            FOUND=1
        fi
    done
    if [ $FOUND -eq 0 ]; then
        echo "NEW DEVICE FOUND: $MAC"
        # Connect
        expect setup_bt_pair.exp $MAC $BLUETOOTH_PIN
    fi
    MACU=$(echo $mac |tr ":" "_")
    dbus-send --print-reply --system --dest=org.bluez /org/bluez/hci0/dev_${MACU} org.bluez.Device1.Connect
    echo pcm.speaker {\
        type bluetooth\
        device $mac\
        profile "a2dp"\
} > ~/.asoundrc
    if [ $? -eq 0 ]; then
        echo "Connected to $mac."
    fi
done

# Give root/pi users PulseAudio access (Fixes: Connection failure: Access denied)
adduser root pulse-access
adduser pi pulse-access

# Setup BlueTooth Discovery.
pactl unload-module module-bluetooth-discover
pactl load-module module-bluetooth-discover

# Set PulseAudio to use the BlueTooth audio by default.
SINK_NAME=`pactl list sinks | grep bluez.sink | cut -f2 -d '<' | cut -f1 -d '>'`
SINK_CARD=`pactl list sinks | grep bluez.card | cut -f2 -d '<' | cut -f1 -d '>'`
pactl set-card-profile ${SINK_CARD} a2dp
pactl set-default-sink ${SINK_NAME}

# Set volume.
pactl -- set-sink-volume ${SINK_NAME} 0
pactl -- set-sink-volume ${SINK_NAME} +75%

# Switch input to sink.
INPUT_INDEX=$(pcctl list sink-inputs | awk '$1 == "index:" {print $2}')
SINK_INDEX=$(pactl list sinks | awk '$1 == "*" && $2 == "index:" {print $3}')
pactl move-sink-input ${INPUT_INDEX} ${SINK_INDEX}

# Configure Audio output for PulseAudio sink server.
grep '\[audio\]' /etc/mopidy/mopidy.conf || bash -c 'cat >> /etc/mopidy/mopidy.conf <<EOT

[audio]
output = pulsesink server=127.0.0.1
EOT'

# Restart mopidy.
service mopidy restart

# Done.
echo Done!

#EOF
