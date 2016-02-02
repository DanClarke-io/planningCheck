#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

function isinstalled {
	if dpkg --get-selections | grep -q "^$@[[:space:]]*install$" >/dev/null
		then
			true
	else
		false
	fi
}

echo "Beginning start up..."
echo "Updating package list..."
apt-get update > /dev/null
apt-get -y upgrade > /dev/null 2>&1

if ! grep -q 'cd /vagrant/www/public' "/home/vagrant/.profile"
	then
		echo "Installing link to LAMP environment..."
		echo "cd /vagrant/www/public" >> /home/vagrant/.profile
fi

echo "Installing LAMP..."
echo "LAMP (1/5)..."
if ! isinstalled php5
	then
		add-apt-repository -y ppa:ondrej/php5-5.6 > /dev/null 2>&1
		apt-get -y update > /dev/null
		apt-get -y upgrade > /dev/null 2>&1
		apt-get -y install php5 php5-mcrypt > /dev/null 2>&1
		echo "ServerName dev.io:80" >> /etc/apache2/apache2.conf
fi

echo "LAMP (2/5)..."
if ! isinstalled mysql-server
	then
		debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password root'
		debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password root'
		apt-get -y install mysql-server > /dev/null 2>&1
		sed -i -e 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/mysql/my.cnf
fi

echo "LAMP (3/5)..."
if ! isinstalled php5-mysql
	then
		apt-get install -y php5-mysql php5-gd > /dev/null 2>&1
fi

echo "LAMP (4/5)..."
if ! isinstalled libapache2-mod-suphp
	then
		apt-get -y install libapache2-mod-suphp > /dev/null 2>&1
		sed -i -e 's/docroot=\/var/docroot=\/vagrant\:\/var/g' /etc/suphp/suphp.conf
fi

echo "LAMP (5/5)..."
if ! isinstalled php5-curl
	then
		apt-get install php5-curl > /dev/null 2>&1
fi

echo "Installing our site..."
rm -Rf /etc/apache2/sites-enabled/* /etc/apache2/sites-available/*
mkdir -p /etc/apache2/sites-available
cp /vagrant/data/httpd.conf /etc/apache2/sites-available/000-default.conf

echo "Installing our environment...."
if ! isinstalled git
	then
		apt-get -y install htop wget git drush > /dev/null
fi

echo "Installing Mailcatcher..."
# echo "You may see some output relating to templates, please ignore it."
echo "Mailcatcher (1/4)..."
apt-get install -y curl python-software-properties nginx > /dev/null
echo "Mailcatcher (2/4)..."
apt-get install -y php5-fpm php5-memcache memcached php-apc > /dev/null 2>&1
echo "Mailcatcher (3/4)..."
apt-get install -y build-essential libsqlite3-dev ruby1.9.3 > /dev/null
echo "Mailcatcher (4/4) (this one takes a while)..."
gem install --no-ri --no-rdoc mailcatcher > /dev/null
mailcatcher --http-ip 0.0.0.0 > /dev/null
sed -i -e 's/\;sendmail_path =/sendmail_path = \/usr\/local\/bin\/catchmail/g' /etc/php5/cgi/php.ini

if isinstalled nginx
	then
		echo "Fixing nginx takeover of port 80..."
		sed -i -e 's/80 default_server/8012 default_server/g' /etc/nginx/sites-available/default
		service nginx restart > /dev/null
fi

echo "Updating LAMP to run our site..."

a2ensite 000-default > /dev/null
a2enmod rewrite > /dev/null
a2enmod headers > /dev/null
service apache2 restart > /dev/null

echo "Setting up MySQL Access..."
Q1="GRANT ALL ON *.* TO 'root'@'10.0.2.2' IDENTIFIED BY 'root';"

Q2="DROP DATABASE IF EXISTS vagrant_database ; CREATE DATABASE IF NOT EXISTS vagrant_database;"
Q3="GRANT ALL ON *.* TO 'vagrant_user'@'localhost' IDENTIFIED BY 'vagrant_pass';"
Q4="GRANT ALL ON *.* TO 'vagrant_user'@'10.0.2.2' IDENTIFIED BY 'vagrant_pass';"
Q5="FLUSH PRIVILEGES;"

SQL1="${Q0}${Q1}${Q2}${Q3}${Q4}"
SQL2="${Q2}${Q3}${Q4}${Q5}"

mysql -u root -p"root" -e "$SQL1"
mysql -u root -p"root" -e "$SQL2"


echo "Restarting Apache to enable Mailcatcher"
service apache2 restart > /dev/null
