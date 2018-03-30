#!/bin/bash

sudo apt-get update
sudo apt-get install dnsmasq hostapd
sudo service hostapd stop
sudo service dnsmasq stop

sudo cat >> /etc/dhcpcd.conf << EOF
denyinterfaces wlan0
EOF
echo "dhcpcd.conf ok"

sudo cat > /etc/network/interfaces.d/wlan0 << EOF
allow-hotplug wlan0
iface wlan0 inet static
  address 192.168.20.1
  netmask 255.255.255.0
  network 192.168.20.0
  broadcast 192.168.20.255
EOF
echo "interface wlan0 ok"

sudo service dhcpcd restart
sudo ifdown wlan0
sudo ifup wlan0

sudo cat > /etc/hostapd/hostapd.conf << EOF
# WiFi interface
interface=wlan0
# Use the nl80211 driver with the brcmfmac driver
driver=nl80211
# Name of the network
ssid=CalambrePi
# 2.4GHz band
hw_mode=g
# Channel
channel=6
# Enable 802.11n
ieee80211n=1
# Enable WMM
wmm_enabled=1
# Enable 40MHz channels with 20ns guard interval
ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]

# Accept all MAC addresses
macaddr_acl=0
# Require clients to know the network name
ignore_broadcast_ssid=0

# Use WPA authentication
auth_algs=1
# Use WPA2
wpa=2
# Use a pre-shared key
wpa_key_mgmt=WPA-PSK
# The network passphrase
wpa_passphrase=C@l@mbr3P1
# Use AES, instead of TKIP
rsn_pairwise=CCMP
#wpa_pairwise=CCMP
EOF

sudo sed -i=back 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd

sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig 
sudo cat > /etc/dnsmasq.conf << EOF
interface=wlan0
listen-address=192.168.20.1
bind-interfaces
server=8.8.8.8
server=8.8.4.4
bogus-priv
dhcp-range=192.168.20.10,192.168.20.20,255.255.255.0,12h
EOF

sudo service hostapd start
sudo service dnsmasq start
