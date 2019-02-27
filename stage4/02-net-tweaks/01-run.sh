#!/bin/bash -e

apt-get update
apt-get install --yes network-manager hostapd dnsmasq
systemctl disable hostapd
systemctl disable dnsmasq

if [ -f /etc/network/interfaces ]; then
  mv /etc/network/interfaces /etc/network/interfaces.old
fi
cp etc/network/interfaces /etc/network/interfaces

if [ -f /etc/default/hostapd ]; then
  mv /etc/default/hostapd /etc/default/hostapd.old
fi
cp etc/default/hostapd /etc/default/hostapd

if [ -f /etc/hostapd/hostapd.conf ]; then
  mv /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.old
fi
cp etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf

cp etc/dnsmasq.d/rpi-access-point.conf /etc/dnsmasq.d/rpi-access-point.conf

cp etc/systemd/system/rpi-access-point.service /etc/systemd/system/rpi-access-point.service
cp stage4/02-net-tweaks/files/rpi-access-point /stage4/02-net-tweaks/files/rpi-access-point

systemctl enable rpi-access-point.service


install -v -d					"${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d"
install -v -m 644 files/wait.conf		"${ROOTFS_DIR}/etc/systemd/system/dhcpcd.service.d/"

install -v -d					"${ROOTFS_DIR}/etc/wpa_supplicant"
install -v -m 600 files/wpa_supplicant.conf	"${ROOTFS_DIR}/etc/wpa_supplicant/"

# disable wireless
install -m 644 files/raspi-blacklist.conf "${ROOTFS_DIR}/etc/modprobe.d/"

if [ -v WPA_COUNTRY ]
then
	echo "country=${WPA_COUNTRY}" >> "${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant.conf"
fi

if [ -v WPA_ESSID -a -v WPA_PASSWORD ]
then
on_chroot <<EOF
wpa_passphrase ${WPA_ESSID} ${WPA_PASSWORD} >> "/etc/wpa_supplicant/wpa_supplicant.conf"
EOF
fi
