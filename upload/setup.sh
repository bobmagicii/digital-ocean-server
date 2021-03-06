#!/bin/bash

set -e

InstallUserAccounts() {
	# create me a new user account and copy over the ssh key that was used when
	# the droplet was created.
	adduser --disabled-password -gecos "" -q bob
	usermod bob -G sudo
	cp -r ~/.ssh /home/bob/
	chown -R bob.bob /home/bob/.ssh

	# add my sudo group override since users use keys.
	echo "%sudo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/10-sudo-group

	# add my network key to the master control program
	# requires you put an id_rsa and id_rsa.pub into setup/bob/sshkey.
	if [ -d "setup/bob/sshkey" ]
	then
		cp setup/bob/sshkey/* /home/bob/.ssh
		chown -R bob.bob /home/bob/.ssh
		chmod 600 /home/bob/.ssh/id_rsa
	fi
}

InstallOptDirectory() {
	OWD=`pwd`

	# where i keep the git repos.
	mkdir /opt/git

	# where i keep letsencrypt setup.
	mkdir /opt/ssl
	cp setup/acmephp* /opt/ssl

	# where i keep the web projects.
	mkdir /opt/web-dev
	mkdir /opt/web-prod

	# mcp support things.
	#git clone bob@mcp.techvip.net:/opt/git/mcp.git /opt/mcp
	#cd /opt/mcp
	#composer install

	cd $OWD
	echo "source /opt/mcp/usr/bashrc-aliases.sh" >> .bashrc
	echo "source /opt/mcp/usr/bashrc-append.sh" >> .bashrc
	echo "source /opt/mcp/data/bashrc/*.sh" >> .bashrc
	echo "source /opt/mcp/usr/bashrc-aliases.sh" >> /home/bob/.bashrc
	echo "source /opt/mcp/usr/bashrc-append.sh" >> /home/bob/.bashrc
	echo "source /opt/mcp/data/bashrc/*.sh" >> /home/bob/.bashrc

	chmod -R 777 /opt
}

InstallCorePackages() {
	# install things i need just to be productive.
	apt-get update
	apt-get -y install joe unzip mlocate net-tools
}

InstallLAMP() {
	# install apache, php 8, and mariadb.
	add-apt-repository -y ppa:ondrej/php
	apt-get update
	apt-get -y install libapache2-mod-php8.0 php-common php8.0-cli php8.0-common php8.0-curl php8.0-gd php8.0-igbinary php8.0-imagick php8.0-mbstring php8.0-memcached php8.0-msgpack php8.0-mysql php8.0-opcache php8.0-readline php8.0-snmp php8.0-xml php8.0-zip php8.0
	apt-get -y install mariadb-client-10.3 mariadb-client-core-10.3 mariadb-common mariadb-server-10.3 mariadb-server-core-10.3 mariadb-server

	# install php composer.
	curl -sS https://getcomposer.org/installer -o composer-setup.php
	php composer-setup.php
	mv composer.phar /usr/local/bin/composer
	chmod 775 /usr/local/bin/composer
}

ConfigureSSH() {

	# require keys.
	echo "PermitRootLogin no" > /etc/ssh/sshd_config.d/10-moar-secure.conf
	echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config.d/10-moar-secure.conf
	echo "PasswordAuthentication no" >> /etc/ssh/sshd_config.d/10-moar-secure.conf

	# make my magic management system work
	echo "AuthorizedKeysFile /opt/mcp/usr/ssh-keys.txt /home/%u/.ssh/authorized_keys" >> /etc/ssh/sshd_config.d/10-moar-secure.conf
	echo "StrictModes no" >> /etc/ssh/sshd_config.d/10-moar-secure.conf

	# restart service
	service ssh restart
}

ConfigureApache() {
	# overwrite with my server config.
	cp setup/apache2.conf /etc/apache2/apache2.conf

	# enable apache modules
	ln -s /etc/apache2/mods-available/macro.load /etc/apache2/mods-enabled/
	ln -s /etc/apache2/mods-available/ssl.load /etc/apache2/mods-enabled/
	ln -s /etc/apache2/mods-available/ssl.conf /etc/apache2/mods-enabled/
	ln -s /etc/apache2/mods-available/socache_shmcb.load /etc/apache2/mods-enabled/
	ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/

	# restart service
	apachectl restart
}

ConfigurePHP() {
	echo "[Date]" > /etc/php/8.0/apache2/conf.d/999-php.ini
	echo "date.timezone = 'America/Chicago';" >> /etc/php/8.0/apache2/conf.d/999-php.ini
}

ConfigureMariaDB() {

	# this particular setting, dropping STRICT_TRANS_TABLES mainly is to fight the
	# war where exactly zero applications ever check that the data they want to store
	# will even fit in the field they are storing it. this stops the "Data Too Long"
	# errors.
	echo "[mysqld]" > /etc/mysql/conf.d/10-sane-sql-mode.cnf
	echo "sql-mode=\"NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION\"" >> /etc/mysql/conf.d/10-sane-sql-mode.cnf

	# restart service
	service mysql restart
}

InstallUserAccounts
InstallCorePackages
InstallLAMP
InstallOptDirectory
ConfigureSSH
ConfigureApache
ConfigurePHP
ConfigureMariaDB
