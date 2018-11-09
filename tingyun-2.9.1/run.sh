#!/bin/bash
tingyunappname=${appname}
tingyunkey=key
sed -i "3a nb_license=${tingyunkey}" /usr/lib/networkbench/networkbench-install.sh
sed -i "4a nb_appname=${tingyunappname}" /usr/lib/networkbench/networkbench-install.sh
sh /usr/bin/networkbench-install.sh install

/usr/local/bin/docker-php-entrypoint php-fpm
