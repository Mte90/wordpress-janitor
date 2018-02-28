FROM ubuntu:16.04

RUN rm -f /etc/service/sshd/down

RUN echo "mysql-server mysql-server/root_password password root"       | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections && \
    echo "postfix postfix/main_mailer_type select Internet Site"       | debconf-set-selections && \
    echo "postfix postfix/mailname string vvv"                         | debconf-set-selections && \
    apt-get update && apt-get install -y \
        colordiff \
        dos2unix \
        gettext \
        git \
        graphviz \
        imagemagick \
        memcached \
        mysql-server \
        nginx \
        ngrep \
        ntp \
        php-imagick \
        php-memcache \
        php-pear \
        php7.0-cli \
        php7.0-common \
        php7.0-curl \
        php7.0-dev \
        php7.0-fpm \
        php7.0-gd \
        php7.0-imap \
        php7.0-json \
        php7.0-mbstring \
        php7.0-mcrypt \
        php7.0-mysql \
        php7.0-soap \
        php7.0-xml \
        php7.0-zip \
        postfix \
        rsync \
        nodejs \
        sudo \
        unzip \
        vim \
        wget \
        zip

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini
%%VARIANT_EXTRAS%%
VOLUME /var/www/html

RUN set -ex; \
	mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS wordpress_develop" \
	mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON wordpress_develop.* TO wp@localhost IDENTIFIED BY 'wp';" \
	git clone git@github.com:WordPress/WordPress.git \
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	chmod +x wp-cli.phar \
	mv wp-cli.phar /usr/local/bin/wp \
	cd /var/www/html/wordpress/src \
	npm install --no-bin-links \
	grunt \
	wp core config --dbname=wordpress_develop --dbuser=wp --dbpass=wp --quiet --extra-php <<PHP
    define( 'WP_DEBUG', true ); PHP \
    wp core install --url=src.wordpress-develop.test --quiet --title="WordPress Develop" --admin_name=admin --admin_email="admin@local.test" --admin_password="password" \
