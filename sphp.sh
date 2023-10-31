#!/bin/bash
# created by: Sergei Nazarenko <nazares@icloud.com>

# CLI colors
RED='\e[0;31m'
GREEN='\e[0;32m'
YELLOW='\e[0;33m'
NC='\e[0m'

get_ostype () {
	awk -F= '$1=="ID_LIKE" { print $2 ;}' /etc/os-release
}

# Check if os type is debian-based
os_type=$(get_ostype)

if [[ ! $os_type =~ "debian" ]]; then
	echo -e "${RED}Unsupported OS. Only debian-based systems are allowed${NC}"
	exit 1
fi

# get installed php versions
versions=(`update-alternatives --list php | grep -oP "(\d\.\d+?)"`)

if [ ! $# -eq 1 ]; then
	printf "usage: sphp version\n"
	printf -v joined '%s,' "${versions[@]}"
	printf "\n${YELLOW}installed php versions: %s${NC}\n\n" "${joined%,}"
	exit 1
else
	if [[ " $1 " =~ [0-9]\.[0-9] ]]; then

		switch_to=$1
	else
		printf "${RED}invalid version number.${NC}\n"
		exit 1
	fi
fi

if [[ ! " ${versions[@]} " =~ " ${switch_to} " ]]; then
	printf "${RED}version ${switch_to} is not installed.${NC}\n"
	exit 1
fi

printf "\n${GREEN}Switching to PHP ${switch_to}"

switch_from=`php -v | grep -oP "PHP (\d\.\d+?)" | cut -d " " -f2`

printf " from PHP ${switch_from}${NC}\n"

if [[ $switch_from == $switch_to ]]; then
	printf "PHP ${switch_to} has been already set\n"
	exit 1;
fi

printf "${YELLOW}this will required \`sudo\` privileges${NC}\n\n"
printf "${GREEN}switching CLI${NC}\n"

sudo update-alternatives --set php /usr/bin/php$switch_to &&
sudo update-alternatives --set phar /usr/bin/phar$switch_to &&
sudo update-alternatives --set phar.phar /usr/bin/phar.phar$switch_to

printf "${GREEN}switching Apache${NC}\n"

sudo a2dismod php$switch_from
sudo a2enmod php$switch_to

read -p $'\e[0;32mActivate new config \'sudo systemctl restart apache2\' (y/N)?: \e[0m' yn

case $yn in
	[Yy]* ) sudo systemctl restart apache2;;
	[Nn]* ) exit;;
	*) exit;;
esac

printf "\n${GREEN}php switch to $switch_to is now complete!${NC}\n\n"

php -v