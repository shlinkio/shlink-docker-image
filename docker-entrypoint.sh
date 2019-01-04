#!/usr/bin/env sh
set -e

cd /etc/shlink
rm -f data/cache/app_config.php

# Ignore the error when creating the database, since it could already exist
echo "Creating fresh database if needed..."
php vendor/doctrine/orm/bin/doctrine.php orm:schema-tool:create -n -q >/dev/null 2>/dev/null || true

echo "Updating database..."
php vendor/doctrine/migrations/bin/doctrine-migrations.php migrations:migrate -n -q

echo "Generating proxies..."
php vendor/doctrine/orm/bin/doctrine.php orm:generate-proxies -n -q

echo "Updating GeoLite2 database..."
shlink visit:update-db -q

# When restarting the container, swoole might think it is already in execution
# This forces the app to be started every second until the exit code is 0
until php vendor/zendframework/zend-expressive-swoole/bin/zend-expressive-swoole start; do sleep 1 ; done
