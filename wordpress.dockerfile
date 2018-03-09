FROM janx/ubuntu-dev

USER root
# This is the most heavy and slow part that require compile of stuff, as first so on changes there are less issues
RUN apt-get install python-software-properties software-properties-common -y --no-install-recommends && \
    add-apt-repository ppa:ondrej/php && \
    echo "mysql-server-5.7 mysql-server/root_password password wp"       | debconf-set-selections && \
    echo "mysql-server-5.7 mysql-server/root_password_again password wp" | debconf-set-selections && \
    echo "postfix postfix/main_mailer_type select Internet Site"       | debconf-set-selections && \
    echo "postfix postfix/mailname string janitor"                     | debconf-set-selections && \
    echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true'         | debconf-set-selections && \
    echo 'phpmyadmin phpmyadmin/app-password-confirm password phpmyadmin_password ' | debconf-set-selections && \
    echo 'phpmyadmin phpmyadmin/mysql/admin-pass password mysql_pass'  | debconf-set-selections && \
    echo 'phpmyadmin phpmyadmin/mysql/app-pass password mysql_pass'    | debconf-set-selections && \
    echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections && \
    apt-get remove mercurial mercurial-common -y && \
    apt-get update && apt-get install -y --no-install-recommends \
        colordiff \
        dos2unix \
        imagemagick \
        mysql-server-5.7 \
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
    gem install mailcatcher

COPY mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf && \
    chown -R mysql:mysql /var/lib/mysql && mkdir /var/mysqld && chown -R mysql:mysql /var/mysqld && service mysql start && \
	apt-get install phpmyadmin -y --no-install-recommends && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /var/log/apt/* /var/log/*.log
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp && \
	curl -sS https://getcomposer.org/installer -o composer-setup.php && \
	php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
	composer global require phpunit/phpunit ^6.5

USER user
# Another heavy part that require a lot of time
RUN git clone git://develop.git.wordpress.org/ wordpress
RUN cd /home/user/wordpress/src && \
	npm install --no-bin-links && \
	npm install -g grunt && \
	grunt

COPY nginx.conf /etc/nginx/nginx.conf
COPY php-fpm.conf /etc/php/7.1/fpm/php-fpm.conf
RUN sudo mkdir -p /run/php && sudo touch /run/php/php7.1-fpm.sock && sudo touch /run/php/php7.1-fpm.pid

COPY supervisord-append.conf /tmp/supervisord-append.conf
RUN (cat /tmp/supervisord-append.conf | sudo tee -a /etc/supervisord.conf) && \
    sudo rm -f /tmp/supervisord-append.conf

WORKDIR /home/user/wordpress

# Configure Cloud9 to use Wordpress's source directory as workspace (-w).
RUN sudo sed -i "s/-w \/home\/user/-w \/home\/user\/wordpress/" /etc/supervisord.conf

# Configure Janitor for Wordpress
ADD janitor.json /home/user/
RUN sudo chown user:user /home/user/janitor.json

ENV WP_TESTS_DB_HOST localhost
ENV WP_TESTS_DB_USER root
ENV WP_TESTS_DB_PASSWORD wp

EXPOSE 3306
EXPOSE 1080
EXPOSE 80

COPY prepare.sh /home/user/wordpress/prepare.sh
RUN sudo chmod +x /home/user/wordpress/prepare.sh && /home/user/wordpress/prepare.sh
