#!/usr/bin/env bash

set -xeuo pipefail

# uninstall classic networking
sudo systemctl daemon-reload
for u in ifupdown dhcpcd dhcpcd5 isc-dhcp-client isc-dhcp-common rsyslog
do systemctl list-units | grep -q "$u.service" && systemctl is-enabled "$u" && sudo systemctl disable --now "$u"
done
sudo apt --autoremove purge -y ifupdown dhcpcd dhcpcd5 isc-dhcp-client isc-dhcp-common rsyslog
sudo rm -rf /etc/network /etc/dhcp

# setup/enable systemd-resolved and systemd-networkd
for u in avahi-daemon libnss-mdns
do systemctl list-units | grep -q "$u.service" && systemctl is-enabled "$u" && sudo systemctl disable --now "$u"
done
sudo apt install -y libnss-resolve
sudo apt purge -y avahi-daemon libnss-mdns
[ -f /etc/resolv.conf ] && rm /etc/resolv.conf
sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl enable systemd-networkd.service systemd-resolved.service

# mark these so APT don't reinstall them
sudo apt-mark hold avahi-daemon dhcpcd dhcpcd5 ifupdown isc-dhcp-client isc-dhcp-common libnss-mdns openresolv raspberrypi-net-mods rsyslog

# describe wired network
sudo tee /etc/systemd/network/04-wired.network <<HERE
[Match]
Name=e*

[Network]
LLMNR=no
LinkLocalAddressing=no
MulticastDNS=yes
DHCP=ipv4
HERE

# initialize wpa_supplicant
for i in $(iw dev | grep -Eo "Interface [a-zA-Z0-0_-]+" | cut -c11-)
do sudo tee /etc/wpa_supplicant/wpa_supplicant-$i.conf <<HERE
country=GI
ctrl_interface=DIR=/run/wpa_supplicant GROUP=netdev
update_config=1
p2p_disabled=1
HERE
   sudo chmod 600 /etc/wpa_supplicant/wpa_supplicant-$i.conf
done
sudo systemctl disable wpa_supplicant.service
sudo systemctl enable wpa_supplicant@wlan0.service
sudo rfkill unblock wlan

# describe wireless networks
sudo tee /etc/systemd/network/08-wifi.network <<HERE
[Match]
Name=wl*

[Network]
LLMNR=no
LinkLocalAddressing=no
MulticastDNS=yes
DHCP=ipv4
HERE
