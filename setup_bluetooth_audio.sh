#!/usr/bin/env bash
### setup_bluetooth.sh - Setup a Bluetooth Speaker/Audio on Raspbian.
# @see https://www.freedesktop.org/wiki/Software/PulseAudio/FAQ/
# @see http://blog.whatgeek.com.pt/2014/04/raspberry-pi-bluetooth-wireless-speaker/
# @see http://linuxcommando.blogspot.co.uk/2013/11/how-to-connect-to-bluetooth.html
# @see http://forums.debian.net/viewtopic.php?f=7&t=124230
# @see https://wiki.archlinux.org/index.php/Bluetooth_headset
# @see https://help.ubuntu.com/community/BluetoothPulseaudioTroubleshooting
# @see http://wiki.openmoko.org/wiki/A2DP

# Default settings.
BLUETOOTH_PIN=0000

# Install packages.
apt-get --yes install pi-bluetooth bluetooth bluez bluez-tools pulseaudio pavucontrol pulseaudio-module-bluetooth expect

# Configure PulseAudio over TCP.
#pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1
sed -i 's/#load-module module-native-protocol-tcp/load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 listen=0.0.0.0/g' /etc/pulse/default.pa
#load_module=load-module module-native-protocol-tcp
#grep "load-module $load_module" /etc/pulse/default.pa || sudo bash -c "echo load-module $load_module auth-ip-acl=127.0.0.1 listen=0.0.0.0>>/etc/pulse/default.pa"

# Configure PulseAudio to switch on connect.
#pactl load-module module-switch-on-connect
load_module=module-switch-on-connect
grep "load-module $load_module" /etc/pulse/default.pa || sudo bash -c "echo load-module $load_module>>/etc/pulse/default.pa"

# Configure daemon
sed -i 's/; allow-module-loading = yes/allow-module-loading = yes/g' /etc/pulse/daemon.conf
sed -i 's/; load-default-script-file = yes/load-default-script-file = yes/g' /etc/pulse/daemon.conf
sed -i 's#; default-script-file = /etc/pulse/default.pa#default-script-file = /etc/pulse/default.pa#g' /etc/pulse/daemon.conf

# Start pulse audio.
#start-pulseaudio-x11
sudo killall -9 pulseaudio
sudo pulseaudio -D --system
#/etc/init.d/alsa-utils restart
#pulseaudio --kill
#pulseaudio --start

# Restart interface.
sudo service bluetooth restart

# Bring the device up.
sudo hciconfig device up

# Start agent.
bt-agent -d

# Find the hardware id.
scan=$( hcitool scan | grep ":" | cut -f2 )

# Pair with the device
paired=$( bt-device --list | grep "(" | cut -d "(" -f2 | cut -d ")" -f1 )
for mac in $scan; do
    found=0
    for pair in $paired; do
        if [[ "$mac" == "$pair" ]]; then
            found=1
        fi
    done
    if [ $found -eq 0 ]; then
        echo "NEW DEVICE FOUND: $mac"
        # Connect
        expect setup_bt_pair.exp $mac $BLUETOOTH_PIN
    fi
    macu=$(echo $mac |tr ":" "_")
    dbus-send --print-reply --system --dest=org.bluez /org/bluez/hci0/dev_$macu org.bluez.Device1.Connect
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
sudo adduser root pulse-access
sudo adduser pi pulse-access

# Setup bluetooth Discovery
sudo pactl unload-module module-bluetooth-discover
sudo pactl load-module module-bluetooth-discover

# Set PulseAudio to use the BlueTooth audio by default.
sink_name=`sudo pactl list sinks | grep bluez.sink | cut -f2 -d '<' | cut -f1 -d '>'`
sink_card=`sudo pactl list sinks | grep bluez.card | cut -f2 -d '<' | cut -f1 -d '>'`
sudo pactl set-card-profile $sink_card a2dp
sudo pactl set-default-sink $sink_name

# Set volume.
sudo pactl -- set-sink-volume $sink_name 0
sudo pactl -- set-sink-volume $sink_name +75%

# Switch input to sink.
input_index=$(sudo pcctl list sink-inputs | awk '$1 == "index:" {print $2}')
sink_index=$(sudo pactl list sinks | awk '$1 == "*" && $2 == "index:" {print $3}')
sudo pactl move-sink-input $input_index $sink_index

# Done.
echo Done!

#EOF
