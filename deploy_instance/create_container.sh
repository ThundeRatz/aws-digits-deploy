#!/bin/bash
# Useful links:
# https://wiki.archlinux.org/index.php/Systemd-networkd#Usage_with_containers
# https://wiki.archlinux.org/index.php/Systemd-nspawn
# https://www.ianweatherhogg.com/tech/2015-09-25-systemd-nspawn-archlinux-containers.html
set -e

if [ "$(id -u)" != 0 ]; then
    echo 'This script must be run as root' 1>&2
    exit 1
fi

# byobu - assumed to be installed at EC2
# dbus - required for connecting additional shells to the container
# openssh-server - SSH login
# wget - required for aws_digits_setup.sh
ADDITIONAL_PACKAGES=byobu,dbus,openssh-server,wget
CONTAINER=digits
ROOT="/var/lib/machines/$CONTAINER"

echo ============================================================
echo Create container with debootstrap
debootstrap --include "$ADDITIONAL_PACKAGES" xenial "$ROOT" http://archive.ubuntu.com/ubuntu/

echo ============================================================
echo Start container
systemctl start "systemd-nspawn@$CONTAINER.service"

shell() {
    machinectl shell "$CONTAINER" "$@"
}
echo ============================================================
echo 'Set up networking (will also enable forwarding on the host system)'
echo 1 > /proc/sys/net/ipv4/ip_forward
echo -e "127.0.0.1\t$(hostname)" >> "$ROOT/etc/hosts"
echo 'nameserver 8.8.8.8' >> "$ROOT/etc/resolv.conf"
shell /bin/systemctl enable systemd-networkd.service

echo ============================================================
echo Add ubuntu user
shell /usr/sbin/useradd -mG sudo ubuntu
echo '%sudo   ALL=(ALL:ALL) NOPASSWD: ALL' > "$ROOT/etc/sudoers.d/sudo_nopasswd"

echo ============================================================
echo Add SSH keys
mkdir "$ROOT/home/ubuntu/.ssh"
chmod 700 "$ROOT/home/ubuntu/.ssh"
cp ~/.ssh/id_rsa.pub "$ROOT/home/ubuntu/.ssh/authorized_keys"
shell /bin/chown -R ubuntu:ubuntu /home/ubuntu/.ssh

echo ============================================================
echo Stop container
systemctl stop "systemd-nspawn@$CONTAINER.service"

echo ============================================================
echo Done!
echo If you need help, the man pages for systemd-nspawn, machinectl and networkctl
echo are good resources.
echo To boot this container with networking:
echo "systemd-nspawn -bnM $CONTAINER"
echo "It can be used as service 'systemd-nspawn@$CONTAINER.service'"
