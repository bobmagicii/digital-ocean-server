# DigitalOcean Ubuntu 20 Setup

Sets up a small server ready to get PHP 8 work done. More for use for tiny projects that get no traffic or small dev instances. Actual production servers should be managed better by proper system admins.

* Slightly better SSHD settings.
* PHP 8
* MariaDB 10
* Apache 2.4


# Process

## Create The Droplet.

Start by creating a new Droplet on DigitalOcean using the Ubuntu 20 image using a key file for root login.

## Upload files to the new Droplet.

If you are already shelled into the Droplet you could just `git clone` this project.

If you are staring at this project on a Windows machine you can use `push.bat <hostname>` to push it to the Droplet. This will automatically open a PuTTY terminal to the root.

## Run Script

`sh setup.sh`

## Done

After it finishes you can close that root window.

If you are staring at this project on a Windows machine you can use `shell.bat <hostname>` to open a new shell with the user the setup script created. Or you can just set up whatever terminal you want how you want.


# What It Does

* Sets up a new user named `bob`
* Gives `bob` access to `sudo`
* Sets `sudo` group to NOPASSWD
* Copies the SSH Key that DO setup for root to `bob` so they can log in.
* Adds a Git branch prompt to PS1 for `bob` and `root`
* Adds some Bash aliases `webdev` and `webprod`
* Installs `joe`
* Installs `unzip`
* Configure SSHD to not allow `root` login after this.
* Configure SSHD to require pubkey auth, deny password auth.
* Setup `ondrej/php` repository.
* Installs PHP 8, MariaDB 10, Apache 2.4
* Enables CURL, GD, Imagick, memcached, mysql for PHP 8
* Enables Macro, SSL, Socache, and Rewrite for Apache 2.4
* Installs Composer for PHP system wide.
* Creates `/opt/git` for storing bare repos.
* Creates `/opt/ssl` and installs AcmePHP to store SSL from LE.
* Creates `/opt/wev-dev` for test versions of the project.
* Creates `/opt/web-prod` for the production version of the project.


# What It Does Not Do

* Install your project.
* Install your database.
* Configure Apache for your project.

