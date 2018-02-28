FROM janx/ubuntu-dev

USER root
RUN apt-get install python-software-properties software-properties-common -y && \
    add-apt-repository ppa:ondrej/php && \
    echo "mysql-server mysql-server/root_password password root"       | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections && \
    echo "postfix postfix/main_mailer_type select Internet Site"       | debconf-set-selections && \
    echo "postfix postfix/mailname string janitor"                     | debconf-set-selections && \
    apt-get remove mercurial mercurial-common -y && \
    apt-get update && apt-get install -y \
        colordiff \
        dos2unix \
        graphviz \
        imagemagick \
        mysql-server \
        mysql-client \
        nginx \
        ngrep \
        ntp \
        php-imagick \
        php-pear \
        php7.1 \
        php7.1-cli \
        php7.1-common \
        php7.1-curl \
        php7.1-dev \
        php7.1-fpm \
        php7.1-gd \
        php7.1-imap \
        php7.1-json \
        php7.1-mbstring \
        php7.1-mcrypt \
        php7.1-mysql \
        php7.1-soap \
        php7.1-xml \
        php7.1-zip \
        postfix \
        ruby-dev \
        libsqlite3-dev \
        rsync && \
    service mysql restart && \
    chown -R mysql:mysql /var/lib/mysql && \
    which mysql && until mysql -u root -e "show status" &>/dev/null; do sleep 1; done && \
	mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS wordpress_develop" && \
	mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON wordpress_develop.* TO wp@localhost IDENTIFIED BY 'wp';" && \
	composer global require phpunit/phpunit ^6.5 && \
	gem install mailcatcher && \
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp && \
	chown user:user /usr/local/bin/wp && \
	curl -sS https://getcomposer.org/installer -o composer-setup.php && \
	php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /var/log/apt/* /var/log/*.log && \
	mailcatcher --smtp-ip=0.0.0.0 --http-ip=0.0.0.0 --foreground &
USER user

RUN git clone git://develop.git.wordpress.org/ wordpress
RUN set -ex; \
	cd /home/user/wordpress/src && \
	npm install --no-bin-links && \
	npm install -g grunt && \
	grunt && \
	/usr/local/bin/wp core config --dbname=wordpress_develop --dbuser=root --dbpass=root --quiet && \
	/usr/local/bin/wp config set WP_DEBUG true && \
    /usr/local/bin/wp core install --url=localhost:3000 --quiet --title="WordPress Develop" --admin_name=admin --admin_email="admin@local.test" --admin_password="password"

WORKDIR /home/user/wordpress

# Configure Cloud9 to use Wordpress's source directory as workspace (-w).
RUN sudo sed -i "s/-w \/home\/user/-w \/home\/user\/wordpress/" /etc/supervisord.conf

# Configure Janitor for Wordpress
ADD janitor.json /home/user/
RUN sudo chown user:user /home/user/janitor.json
