#!/usr/bin/env bash

set -ex

mysql -u root --password=wp -e "CREATE DATABASE IF NOT EXISTS wordpress_develop"
mysql -u root --password=wp -e "GRANT ALL PRIVILEGES ON wordpress_develop.* TO wp@localhost IDENTIFIED BY 'wp';"
mysql -u root --password=wp -e "CREATE DATABASE IF NOT EXISTS wordpress_unit_tests"
mysql -u root --password=wp -e "GRANT ALL PRIVILEGES ON wordpress_unit_tests.* TO wp@localhost IDENTIFIED BY 'wp';"

cd /home/user/wordpress/src/
# Create WordPress config.
if ! [ -f ./wp-config.php ]; then
  wp core config --dbname=wordpress_develop --dbuser=root --dbpass=wp --quiet
  wp config set WP_DEBUG true
  wp core install --url=localhost:3000 --quiet --title="WordPress Develop" --admin_name=admin --admin_email="admin@local.test" --admin_password="password"
fi

mkdir -p ./wp-content/uploads
chown -R www-data ./wp-content
chmod -R 775 ./
