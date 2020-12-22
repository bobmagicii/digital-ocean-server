set -e

InstallUserAccounts() {
	# create me a new user account and copy over the ssh key that was used when
	# the droplet was created.
	adduser --disabled-password -gecos "" -q bob
	usermod bob -G sudo
	cp -r ~/.ssh /home/bob/
	chown -R bob.bob /home/bob/.ssh

	# add my bash configurations.
	cat setup/bashrc-append.txt >> .bashrc
	cat setup/bashrc-append.txt >> /home/bob/.bashrc
	cp setup/bash_aliases.txt .bash_aliases
	cp setup/bash_aliases.txt /home/bob/.bash_aliases

	# add my sudo group override since users use keys.
	echo "%sudo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/10-sudo-group
}

InstallOptDirectory() {
	# where i keep the git repos.
	mkdir /opt/git

	# where i keep letsencrypt setup.
	mkdir /opt/ssl
	cp setup/acmephp* /opt/ssl

	# where i keep the web projects.
	mkdir /opt/web-dev
	mkdir /opt/web-prod

	chmod -R 777 /opt
}

InstallCorePackages() {
	# install things i need just to be productive.
	apt-get update
	apt-get -y install joe unzip
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
	echo "PermitRootLogin no" > /etc/ssh/sshd_config.d/10-moar-secure.conf
	echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config.d/10-moar-secure.conf
	echo "PasswordAuthentication no" >> /etc/ssh/sshd_config.d/10-moar-secure.conf
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
}

InstallUserAccounts
InstallCorePackages
InstallLAMP
InstallOptDirectory
ConfigureSSH
ConfigureApache
