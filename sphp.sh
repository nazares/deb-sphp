#!/bin/bash
# created by: Sergei Nazarenko <nazares@icloud.com>

RED='\e[0;31m'
GREEN='\e[0;32m'
YELLOW='\e[0;33m'
NC='\e[0m'

# function to get lsb_release to check deb-based distro
get_distr () {
    lsb_release -is
}

os_distr=$(get_distr)

# TODO make os check function

#echo $os_distr;

case $os_distr in
    Elementary) echo "Elementary OS";;
    Ubuntu) echo "Ubuntu";;
    Debian) echo "Debian";;
    *) echo "Unsupported OS"; exit 1;;
esac

versions=(`update-alternatives --list php | grep -oP "(\d\.\d+?)"`)

if [ ! -e /usr/bin/lsb_release ]; then
    echo "Unable to find lsb_release to check for debian based system. Only use this on Debian based linux."
    exit 1
fi

if [ ! $# -eq 1 ]; then
    echo "Please specify a php version to switch to:"
    # echo "valid choice are:"

    echo ${versions[*]}
    exit 1
else
    if [[ $1 =~ [0-9]\.[0-9]+? ]]; then
        switch_to=$1
    else
        echo "Invalid version number"
        exit 1
    fi
fi

if [[ ! " ${versions[*]} " =~ " ${switch_to} " ]]; then
    echo "invalid version"
    exit 1
fi

echo "Switching to PHP $switch_to"

switch_from=`php --version | grep -oP "PHP (\d\.\d+?)" | cut -d " " -f2`

echo "from PHP $switch_from"
echo "this will require sudo privileges"

echo "switchng CLI"
sudo update-alternatives --set php /usr/bin/php$switch_to &&
sudo update-alternatives --set phar /usr/bin/phar$switch_to &&
sudo update-alternatives --set phar.phar /usr/bin/phar.phar$switch_to

echo "switching Apache"
sudo a2dismod php$switch_from;
sudo a2enmod php$switch_to;

read -p "Activate new config 'sudo systemctl restart apache2' (y/N)?: " yn
case $yn in
    [Yy]* ) sudo systemctl restart apache2;;
    [nN]* ) exit;;
    *) echo exit;;
esac

echo "php switch to $switch_to is now complete"
php --version