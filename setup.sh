#!/bin/bash

#  bash <(curl -s https://raw.githubusercontent.com/KnoAll/globalprotect-iot/master/setup.sh)
scriptver=v0.1
green=$(tput setaf 2)
red=$(tput setaf 1)
tan=$(tput setaf 3)
reset=$(tput sgr0)

printinfo() {
	printf "${tan}::: ${green}%s${reset}\n" "$@"
}
printwarn() {
	printf "${tan}*** WARNING: %s${reset}\n" "$@"
}
printerror() {
	printf "${red}!!! ERROR: %s${reset}\n" "$@"
}

case $(whoami) in
	root)
		printerror "You ran me as root! Do not run me as root!"
		exit 1
	;;
	*)
	;;
esac

welcomeMessage() {
  echo -n "${tan}"
  echo -n "${reset}"
  printinfo "Welcome to Kevin's GlobalProtect IoT setup script!"
}

branch=master
#gpPackage=GlobalProtect_deb_arm-5.1.2.0-26.deb
gpPackage=GlobalProtect_deb_arm-5.0.1.0-10.deb
gpCACert=cert_GP-DuckDNS-CA.crt
gpCert=cert_GP-DuckDNS.crt
gpConfig=pangps.xml

getFiles() {
	mkdir ~/gp
	cd ~/gp
	wget -q https://raw.githubusercontent.com/KnoAll/globalprotect-iot/$branch/$gpPackage
	wget -q https://raw.githubusercontent.com/KnoAll/globalprotect-iot/$branch/$gpCACert
	wget -q https://raw.githubusercontent.com/KnoAll/globalprotect-iot/$branch/$gpCert
	wget -q https://raw.githubusercontent.com/KnoAll/globalprotect-iot/$branch/$gpConfig
}

setupInstall() {
	sudo dpkg -i *.deb
	sudo cp pangps.xml /opt/paloaltonetworks/globalprotect/
}

setupRemove() {
	sudo dpkg -P globalprotect
}

setupCerts() {
	sudo cp *.crt /usr/local/share/ca-certificates/
	sudo dpkg-reconfigure ca-certificates
}

cleanupAfter() {
	cd
	rm -rf ~/gp
}

showStatus() {
	printinfo "GP Status: "
	globalprotect show --status
}

welcomeLooper() {
case $1 in
	dev)
		printwarn "Switching to DEV script"
		bash <(curl -s https://raw.githubusercontent.com/KnoAll/globalprotect-iot/dev/setup.sh) $1 $2
	;;
	--switch-dev)
		printwarn "Switching to DEV branch"
		branch=dev
		welcomeLooper $2
	;;
	--help | --h | --H | help | -? | --? )
		printinfo "Switches available in this script:"
	;;
	*)
		welcomeMessage
		getFiles
		setupInstall
		setupCerts
		cleanupAfter
		showStatus
	;;
esac
}

welcomeLooper $1 $2
