#!/bin/bash
sudo ssh -i kipasktps.pem ubuntu@52.87.216.5 <<EOF

sudo apt-add-repository ppa:ondrej/php -y
sudo apt update -y

sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

export DEBIAN_FRONTEND="noninteractive"
echo mysql-server mysql-server/root_password password 12345 | sudo debconf-set-selections
echo mysql-server mysql-server/root_password_again password 12345 | sudo debconf-set-selections
 
sudo apt-get install acl git curl unzip apache2 php7.4-common php7.4-cli php7.4-dev php7.4-gd php7.4-curl php7.4-json php7.4-opcache php7.4-xml php7.4-mbstring php7.4-pdo php7.4-mysql php-apcu libpcre3-dev libapache2-mod-php7.4 python3-mysqldb mysql-server python-apt python-pycurl -y

sudo chmod 777 /var/www/html/

sudo sed -i '12 a \\        <Directory /var/www/html>' /etc/apache2/sites-available/000-default.conf
sudo sed -i '13 a \\             AllowOverride All' /etc/apache2/sites-available/000-default.conf
sudo sed -i '14 a \\        </Directory>' /etc/apache2/sites-available/000-default.conf
sudo a2enmod rewrite
sudo service apache2 restart

mysql -u root -p12345 -e "CREATE DATABASE drupaldb;"
mysql -u root -p12345 -e "GRANT ALL ON drupaldb.* TO 'admin' IDENTIFIED BY '12345';"

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
sudo mv composer.phar /usr/local/bin/composer

composer global require drush/drush:8.3.3
sudo ln -s ~/.config/composer/vendor/bin/drush /usr/local/bin/drush

drush dl --destination=/var/www/html --drupal-project-rename=drupal -y
cd /var/www/html/drupal

drush si --db-url=mysql://admin:12345@localhost/drupaldb --account-name=admin --account-pass="admin12345" --site-name="A Handsome Drupal Developer" -y
drush -y config-set system.performance css.preprocess 0
drush -y config-set system.performance js.preprocess 0
sudo chmod 777 -R sites/default/files/

EOF
