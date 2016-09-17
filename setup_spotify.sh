#!/usr/bin/env bash
# `setup_spotify` - Setup Spotify for Mopidy.

# Install the packages we need.
apt-get --yes install python-spotify libspotify-dev mopidy-spotify

# @see https://github.com/mopidy/libspotify-deb/issues/2
#pip install -U pyspotify Mopidy-Spotify mopidy-spotify-tunigo

# Import environment settings.
source .env

if [ -z $SPOTIFY_USER ]; then
    read -p "What is your Spotify Username?" SPOTIFY_USER
fi

if [ -z $SPOTIFY_PASS ]; then
    read -p "What is your Spotify Password?" SPOTIFY_PASS
fi

grep '\[spotify\]' /etc/mopidy/mopidy.conf || bash -c "cat >> /etc/mopidy/mopidy.conf <<EOT

[spotify]
username = ${SPOTIFY_USER}
password = ${SPOTIFY_PASS}
EOT"

# Restart mopidy
systemctl restart mopidy