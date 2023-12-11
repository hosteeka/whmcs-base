#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM php:7.4-apache

# Install dependencies required by PHP extensions

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    libjpeg-dev \
    libz-dev \
    libpng-dev \
    libwebp-dev \
    libfreetype6-dev \
    libgmp-dev \
    libicu-dev; \
    rm -rf /var/lib/apt/lists/*

## Configure and Install GD2 extension

RUN docker-php-ext-configure gd \
    --with-jpeg \
    --with-webp \
    --with-freetype; \
    docker-php-ext-install gd

## Install PDO_MYSQL, BC Math, GMP and Intl extensions

RUN docker-php-ext-install pdo_mysql bcmath gmp intl
