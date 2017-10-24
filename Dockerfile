FROM php:7.1-fpm-alpine
MAINTAINER Alejandro Celaya <alejandro@alejandrocelaya.com>

ENV SHLINK_VERSION=1.6.1

RUN apk update && \

    # Install common php extensions
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install iconv && \
    docker-php-ext-install mbstring && \
    docker-php-ext-install calendar && \

    # Install sqlite
    apk add --no-cache --virtual sqlite-libs && \
    apk add --no-cache --virtual sqlite-dev && \
    docker-php-ext-install pdo_sqlite && \

    # Install other PHP packages that depend on pther system packages
    apk add --no-cache --virtual icu-dev && \
    docker-php-ext-install intl && \

    apk add --no-cache --virtual zlib-dev && \
    docker-php-ext-install zip && \

    apk add --no-cache --virtual libmcrypt-dev && \
    docker-php-ext-install mcrypt && \

    apk add --no-cache --virtual libpng-dev && \
    docker-php-ext-install gd

# Install APCu
ADD https://pecl.php.net/get/apcu-5.1.3.tgz /tmp/apcu.tar.gz
RUN mkdir -p /usr/src/php/ext/apcu && \
    tar xf /tmp/apcu.tar.gz -C /usr/src/php/ext/apcu --strip-components=1 && \
    docker-php-ext-configure apcu && \
    docker-php-ext-install apcu && \
    rm /tmp/apcu.tar.gz

# Install APCu-BC extension
ADD https://pecl.php.net/get/apcu_bc-1.0.3.tgz /tmp/apcu_bc.tar.gz
RUN mkdir -p /usr/src/php/ext/apcu-bc && \
    tar xf /tmp/apcu_bc.tar.gz -C /usr/src/php/ext/apcu-bc --strip-components=1 && \
    docker-php-ext-configure apcu-bc && \
    docker-php-ext-install apcu-bc && \
    rm /tmp/apcu_bc.tar.gz

# Load APCU.ini before APC.ini
RUN rm /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini && \
    echo extension=apcu.so > /usr/local/etc/php/conf.d/20-php-ext-apcu.ini

# Install shlink
RUN php -r "readfile('https://getcomposer.org/installer');" | php && \
    chmod +x composer.phar && \
    php composer.phar create-project shlinkio/shlink:$SHLINK_VERSION \
    --prefer-dist \
    --no-dev \
    --no-interaction && \
    cd shlink && \
    php ../composer.phar dump-autoload --optimize --apcu --classmap-authoritative --no-dev && \
    rm ../composer.phar
