#!/bin/bash
# created by: Sergei Nazarenko <nazares@icloud.com>

get_ostype () {
	awk -F= '$1=="ID_LIKE" { print $2 ;}' /etc/os-release
}

# Check if os type is debian-based
os_type=$(get_ostype)

if [[ ! $os_type =~ "debian" ]]; then
	printf '\e[0;31mUnsupported OS. Only debian-based systems are allowed\e[0m\n'
	exit 1
fi

# get installed php versions

mapfile -t versions < <(update-alternatives --list php | grep -oP "(\d\.\d+?)")

if [ ! $# -eq 1 ]; then
	printf 'usage: sphp <version>\n'
	printf -v joined '%s,' "${versions[@]}"
	printf '\n\e[0;33minstalled php versions: %s\e[0m\n\n' "${joined%,}"
	exit 1
else
	if [[ " $1 " =~ [0-9]\.[0-9] ]]; then
		switch_to=$1
	else
		printf '\e[0;31minvalid version number.\e[0m\n'
		exit 1
	fi
fi

if [[ !  ${versions[*]} =~  $switch_to  ]]; then
	printf "\e[0;31mPHP version %s is not installed.\e[0m\n" "$switch_to"
	exit 1
fi

printf '\n\e[0;32mSwitching to PHP %s' "$switch_to"

switch_from=`php -v | grep -oP "PHP (\d\.\d+?)" | cut -d " " -f2`

printf ' from PHP %s\e[0m\n' "$switch_from"

if [ "$switch_from" == "$switch_to" ]; then
	printf 'PHP %s has been already set\n' "$switch_to"
	exit 1;
fi

printf '\e[0;33mthis will required %s privileges\e[0m\n\n' "\`sudo\`"
printf '\e[0;32mSwitching CLI\e[0m\n'

sudo update-alternatives --set php /usr/bin/php"$switch_to" &&
sudo update-alternatives --set phar /usr/bin/phar"$switch_to" &&
sudo update-alternatives --set phar.phar /usr/bin/phar.phar"$switch_to"

printf "\e[0;32mSwitching Apache\e[0m\n"

sudo a2dismod php"$switch_from"
sudo a2enmod php"$switch_to"

read -r -p $'\e[0;32mActivate new config \'sudo systemctl restart apache2\' (y/N)?: \e[0m' yn

case $yn in
	[Yy]* ) sudo systemctl restart apache2;;
	[Nn]* ) exit;;
	*) exit;;
esac

printf '\n\e[0;32mphp switch to PHP %s is now complete!\e[0m\n\n' "$switch_to"

php -v