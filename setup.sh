#!/usr/bin/env bash
### setup.sh - Common setup.
# @see https://google.github.io/styleguide/shell.xml
# @see http://www.davidpashley.com/articles/writing-robust-shell-scripts/

# Exit on error.
set -e

# Current Working Directory.
readonly CWD=$(cd $(dirname $0); pwd)

# Setup System.
sh setup_system.sh

# Setup Wifi.
sh setup_wifi.sh

# Setup VNC.
sh setup_autostart_vnc.sh

# Setup Music Player.
sh setup_music_player.sh

# Setup BlueTooth Audio.
sh setup_bluetooth_audio.sh

# Start.
sh startup.sh

#EOF