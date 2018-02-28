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
        subversion \
        sudo \
        unzip \
        vim \
        wget \
        zip
