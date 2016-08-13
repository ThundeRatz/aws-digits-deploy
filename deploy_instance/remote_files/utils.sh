#!/bin/bash
download_and_install_deb() {
	echo "Downloading $1..."
	wget "$1" -O package.deb
	echo "Installing $1..."
	sudo dpkg -i package.deb
	sudo apt-get update
}
