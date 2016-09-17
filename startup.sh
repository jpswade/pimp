#!/usr/bin/env bash

# Add Startup script to run at startup.
grep "$CWD/startup.sh" /etc/rc.local || sudo sed -i -e '$i \sh '$CWD'/startup.sh &\n' /etc/rc.local
chmod +x "$CWD/startup.sh"

# @see https://github.com/pimusicbox/pimusicbox/blob/develop/filechanges/opt/musicbox/startup.sh
paired=$( bt-device --list | grep "(" | cut -d "(" -f2 | cut -d ")" -f1 )
for mac in $paired; do
    macu=$(echo $mac |tr ":" "_")
    dbus-send --print-reply --system --dest=org.bluez /org/bluez/hci0/dev_$macu org.bluez.Device1.Connect
done

_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "My IP address is %s\n" "$_IP" | festival --tts
fi

# Start playing!
# @see https://docs.mopidy.com/en/latest/clients/mpd/
# @see https://github.com/HeadspringLabs/mopidy-qsaver/issues/4
if [ -z ${PLAY_LIST} ]; then
    PLAY_LIST=`mpc lsplaylists | head -n 1`
fi
mpc load "${PLAY_LIST}"
mpc play

#EOF