#!/usr/bin/env bash
### setup_bluetooth.sh - Setup a Bluetooth Speaker/Audio on Raspbian.
# @see https://www.freedesktop.org/wiki/Software/PulseAudio/FAQ/
# @see http://blog.whatgeek.com.pt/2014/04/raspberry-pi-bluetooth-wireless-speaker/
# @see http://linuxcommando.blogspot.co.uk/2013/11/how-to-connect-to-bluetooth.html
# @see http://forums.debian.net/viewtopic.php?f=7&t=124230
# @see https://wiki.archlinux.org/index.php/Bluetooth_headset
# @see https://help.ubuntu.com/community/BluetoothPulseaudioTroubleshooting
# @see http://wiki.openmoko.org/wiki/A2DP

# Include environment settings.
source .env

# Install packages.
apt-get --yes install pi-bluetooth bluetooth bluez bluez-tools pulseaudio pavucontrol pulseaudio-module-bluetooth expect

# Configure BlueTooth to auto connect audio.
sed -i 's/AutoConnect=false/AutoConnect=true/g' /etc/bluetooth/audio.conf

# Restart interface.
sudo service bluetooth restart

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
    if [ $? -eq 0 ]; then
        echo "Connected to $mac."
    fi
done

# Configure PulseAudio over TCP.
#pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1
sed -i 's/#load-module module-native-protocol-tcp/load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 listen=0.0.0.0/g' /etc/pulse/default.pa
#load_module=load-module module-native-protocol-tcp
#grep "load-module $load_module" /etc/pulse/default.pa || sudo bash -c "echo load-module $load_module auth-ip-acl=127.0.0.1 listen=0.0.0.0>>/etc/pulse/default.pa"

# Configure PulseAudio to BlueTooth.
#pactl load-module module-alsa-sink device=bluetooth
sed -i 's/#load-module module-alsa-sink/load-module module-alsa-sink device=bluetooth/g' /etc/pulse/default.pa

# Configure PulseAudio to switch on connect.
#pactl load-module module-switch-on-connect
load_module=module-switch-on-connect
grep "load-module $load_module" /etc/pulse/default.pa || sudo bash -c "echo load-module $load_module>>/etc/pulse/default.pa"

# Start pulse audio.
#start-pulseaudio-x11
sudo killall -9 pulseaudio
sudo pulseaudio -D --system
#/etc/init.d/alsa-utils restart
#pulseaudio --kill
#pulseaudio --start

# Set PulseAudio to use the BlueTooth audio by default.
sink_name=`pactl -s 127.0.0.1 list-sinks | grep bluez.sink | cut -f2 -d '<' | cut -f1 -d '>'`
sink_card=`pactl -s 127.0.0.1 list-sinks | grep bluez.card | cut -f2 -d '<' | cut -f1 -d '>'`
pactl -s 127.0.0.1 set-card-profile $sink_card a2dp
pactl -s 127.0.0.1 set-default-sink $sink_name

# Set volume.
pactl -s 127.0.0.1 -- set-sink-volume $sink_name 0
pactl -s 127.0.0.1 -- set-sink-volume $sink_name +75%

# Switch input to sink.
input_index=$(pactl -s 127.0.0.1 list-sink-inputs | awk '$1 == "index:" {print $2}')
sink_index=$(pactl -s 127.0.0.1 list-sinks | awk '$1 == "*" && $2 == "index:" {print $3}')
pactl -s 127.0.0.1 move-sink-input $input_index $sink_index

# Done.
echo Done!

#EOF
