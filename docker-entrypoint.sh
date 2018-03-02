#!/usr/bin/env bash

set -ex

sudo chown -R mysql:mysql /var/lib/mysql
sudo service mysql start

cd /home/user/wordpress/
git pull

cd /home/user/wordpress/src/
# Create WordPress config.
if ! [ -f ./wp-config.php ]; then
    mysql -u root --password=wp -e "CREATE DATABASE IF NOT EXISTS wordpress_develop"
    mysql -u root --password=wp -e "GRANT ALL PRIVILEGES ON wordpress_develop.* TO wp@localhost IDENTIFIED BY 'wp';"
    mysql -u root --password=wp -e "CREATE DATABASE IF NOT EXISTS wordpress_unit_tests"
    mysql -u root --password=wp -e "GRANT ALL PRIVILEGES ON wordpress_unit_tests.* TO wp@localhost IDENTIFIED BY 'wp';"
    wp core config --dbname=wordpress_develop --dbuser=root --dbpass=wp --quiet --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_DISPLAY', false );
define( 'WP_DEBUG_LOG', true );
PHP
    wp core install --url=localhost:3000 --quiet --title="WordPress Develop" --admin_name=admin --admin_email="admin@local.test" --admin_password="password"

    mkdir -p ./wp-content/uploads
    sudo chown -R www-data ./wp-content
    sudo chmod -R 775 ./wp-content
fi
