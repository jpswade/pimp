#!/usr/bin/env bash
### setup_wifi.sh - Setup WIFI on Raspbian

### Import environment settings.
# $ cat .env
#SSID=<SSID>
#WKEY=<wifi-password-key>
source .env

if [ -z $SSID ]; then
    read -p "What is your Wifi SSID?" SSID
    echo "SSID=$SSID">>.env
fi

if [ -z $WKEY ]; then
    read -p "What is your Wifi WKEY?" WKEY
    echo "WKEY=$WKEY">>.env
fi

### Wireless Setup
if ! grep -q "$SSID" /etc/wpa_supplicant/wpa_supplicant.conf ; then
    sudo sh -c "wpa_passphrase $SSID $WKEY>>/etc/wpa_supplicant/wpa_supplicant.conf"
    cp /etc/network/interfaces /etc/network/interfaces.bak
    sed -i 's/manual/dhcp/g' /etc/network/interfaces
    ifdown wlan0 && ifup wlan0
    ping -c 1 google.com &> /dev/null
    if [ $? -eq 0 ]; then
        ifdown wlan0 && ifup wlan0
    fi
fi

### Add Wireless Check
cat >> checkwifi.sh <<EOT
#!/usr/bin/env bash
ping -c4 8.8.8.8 > /dev/null
if [ $? != 0 ]; then
  logger 'No network connection, restarting wlan0'
  /sbin/ifdown 'wlan0'
  sleep 5
  /sbin/ifup --force 'wlan0'
fi
EOT
sudo mv -f checkwifi.sh /usr/local/bin/checkwifi.sh
sudo crontab -l | sudo tee /root/root.cron
echo "*/5 * * * * /usr/bin/sudo -H /usr/bin/env bash /usr/local/bin/checkwifi.sh >> /dev/null 2>&1" | sudo tee -a /root/root.cron
sudo crontab /root/root.cron
sudo rm -fr /root/root.cron

#EOF