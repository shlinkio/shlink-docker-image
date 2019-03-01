FROM php:7.3.2-cli-alpine3.9
LABEL maintainer="Alejandro Celaya <alejandro@alejandrocelaya.com>"

ARG SHLINK_VERSION=v1.16.1
ENV SHLINK_VERSION ${SHLINK_VERSION}
ENV APCu_VERSION 5.1.16
ENV APCuBC_VERSION 1.0.4

WORKDIR /etc/shlink

RUN \

    # Install common php extensions
    docker-php-ext-install -j"$(nproc)" pdo_mysql calendar && \

    # Install sqlite
    apk add --no-cache sqlite-libs sqlite-dev && \
    docker-php-ext-install -j"$(nproc)" pdo_sqlite && \

    # Install other PHP packages that depend on other system packages
    apk add --no-cache icu-dev && \
    docker-php-ext-install -j"$(nproc)" intl && \

    apk add --no-cache libzip-dev zlib-dev libpng-dev && \
    docker-php-ext-install -j"$(nproc)" zip gd

# Install APCu
RUN wget "https://pecl.php.net/get/apcu-${APCu_VERSION}.tgz" -O /tmp/apcu.tar.gz && \
    mkdir -p /usr/src/php/ext/apcu && \
    tar xf /tmp/apcu.tar.gz -C /usr/src/php/ext/apcu --strip-components=1 && \
    docker-php-ext-configure apcu && \
    docker-php-ext-install -j"$(nproc)" apcu && \
    rm /tmp/apcu.tar.gz

# Install APCu-BC extension
RUN wget "https://pecl.php.net/get/apcu_bc-${APCuBC_VERSION}.tgz" -O /tmp/apcu_bc.tar.gz && \
    mkdir -p /usr/src/php/ext/apcu-bc && \
    tar xf /tmp/apcu_bc.tar.gz -C /usr/src/php/ext/apcu-bc --strip-components=1 && \
    docker-php-ext-configure apcu-bc && \
    docker-php-ext-install -j"$(nproc)" apcu-bc && \
    rm /tmp/apcu_bc.tar.gz

# Load APCU.ini before APC.ini
RUN rm /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini && \
    echo extension=apcu.so > /usr/local/etc/php/conf.d/20-php-ext-apcu.ini

# Install swoole
# First line fixes an error when installing pecl extensions. Found in https://github.com/docker-library/php/issues/233
RUN apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS && \
    pecl install swoole && \
    docker-php-ext-enable swoole && \
    apk del .phpize-deps

# Install shlink
RUN wget https://github.com/shlinkio/shlink/releases/download/v${SHLINK_VERSION}/shlink_${SHLINK_VERSION}_dist.zip -O /tmp/shlink.zip && \
    unzip /tmp/shlink.zip -d /etc/shlink && \
    mv shlink_${SHLINK_VERSION}_dist/* . && \
    rm -rf shlink_${SHLINK_VERSION}_dist && \
    rm -f /tmp/shlink.zip

# Add shlink to the path to ease running it after container is created
RUN ln -s /etc/shlink/bin/cli /usr/local/bin/shlink

# Add shlink in docker config to the project
COPY config/shlink_in_docker.local.php config/autoload/shlink_in_docker.local.php

# Expose swoole port
EXPOSE 8080

# Expose params config dir, since the user is expected to provide custom config from there
VOLUME config/params

COPY docker-entrypoint.sh docker-entrypoint.sh
ENTRYPOINT ["/bin/sh", "./docker-entrypoint.sh"]
