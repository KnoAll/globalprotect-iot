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
	pi)
	;;
	*)
		printerror "Uh-oh. You are not logged in as the cacti user. Exiting..."
		exit 1
	;;
esac

welcomeMessage() {
  echo -n "${tan}"
  echo -n "${reset}"
  echo "Welcome to the Kevin's GlobalProtect IoT setup script!"
  echo
}

branch=master

welcomeLooper() {
case $1 in
	dev)
		printwarn "Switching to DEV script"
		bash <(curl -s https://raw.githubusercontent.com/KnoAll/cacti-template/dev/upgrade-cacti.sh) $1 $2
	;;
	--fix-permissions)
		welcomeMessage
		counter=$( curl -s http://www.kevinnoall.com/cgi-bin/counter/unicounter.pl?name=update-permissions&write=0 )
		bash <(curl -s https://raw.githubusercontent.com/KnoAll/cacti-template/$branch/update-permissions.sh) $1 $2
	;;
	--backup-data)
		welcomeMessage
		counter=$( curl -s http://www.kevinnoall.com/cgi-bin/counter/unicounter.pl?name=backup-data&write=0 )
		bash <(curl -s https://raw.githubusercontent.com/KnoAll/cacti-template/$branch/backup-cacti.sh) $1 $2
	;;
	--restore-data)
		welcomeMessage
		bash <(curl -s https://raw.githubusercontent.com/KnoAll/cacti-template/$branch/restore-cacti.sh) $1 $2
	;;
	--switch-dev)
		printwarn "Switching to DEV branch"
		branch=dev
		welcomeLooper $2
	;;
	--help | --h | --H | help | -? | --? )
		printinfo "Switches available in this script:"
		printinfo "--backup-data	Backup Cacti data (only) and compress to home directory"
		printinfo "--fix-permissions	Fix file permissions if graphs not created properly"
		printinfo "--restore-data	Restore Cacti from previous backup"
	;;
	*)
		welcomeMessage
#		bash <(curl -s https://raw.githubusercontent.com/KnoAll/cacti-template/$branch/upgrade-cacti.sh) $1 $2
	;;
esac
}

welcomeLooper $1 $2
