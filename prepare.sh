#!/bin/bash

sudo chown -R mysql:mysql /var/lib/mysql /var/run/mysqld && sudo touch /var/run/mysqld/mysqld.sock && sudo touch /var/run/mysqld/mysqld.pid && sudo service mysql start

cd /home/user/wordpress/src/
# Create WordPress config.
if ! [ -f ./wp-config.php ]; then
    echo "WordPress Installing in progress"
    mysql -u root --password=wp -e "CREATE DATABASE IF NOT EXISTS wordpress_develop" 2>/dev/null
    mysql -u root --password=wp -e "GRANT ALL PRIVILEGES ON wordpress_develop.* TO wp@localhost IDENTIFIED BY 'wp';" 2>/dev/null
    mysql -u root --password=wp -e "CREATE DATABASE IF NOT EXISTS wordpress_unit_tests" 2>/dev/null
    mysql -u root --password=wp -e "GRANT ALL PRIVILEGES ON wordpress_unit_tests.* TO wp@localhost IDENTIFIED BY 'wp';" 2>/dev/null
    wp core config --dbname=wordpress_develop --dbuser=root --dbpass=wp --quiet --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_DISPLAY', false );
define( 'WP_DEBUG_LOG', true );
PHP
    wp core install --url=localhost:80 --quiet --title="WordPress Develop" --admin_name=admin --admin_email="admin@local.test" --admin_password="password" 2>/dev/null

    mkdir -p ./wp-content/uploads
    sudo chown -R www-data ./wp-content
    sudo chmod -R 775 ./wp-content
    echo "WordPress Installed"
fi
