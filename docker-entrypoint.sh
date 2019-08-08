#!/usr/bin/env sh
set -e

cd /etc/shlink
rm -f data/cache/app_config.php

echo "Creating fresh database if needed..."
if [ -f "./module/CLI/src/Command/Db/CreateDatabaseCommand.php" ]; then
  php bin/cli db:create -n -q
else
  # Ignore the error when creating the database, since it could already exist
  php vendor/doctrine/orm/bin/doctrine.php orm:schema-tool:create -n -q >/dev/null 2>/dev/null || true
fi

echo "Updating database..."
if [ -f "./module/CLI/src/Command/Db/MigrateDatabaseCommand.php" ]; then
  php bin/cli db:migrate -n -q
else
  php vendor/doctrine/migrations/bin/doctrine-migrations.php migrations:migrate -n -q
fi

echo "Generating proxies..."
php vendor/doctrine/orm/bin/doctrine.php orm:generate-proxies -n -q

# When restarting the container, swoole might think it is already in execution
# This forces the app to be started every second until the exit code is 0
until php vendor/zendframework/zend-expressive-swoole/bin/zend-expressive-swoole start; do sleep 1 ; done
