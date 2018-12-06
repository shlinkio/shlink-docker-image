#!/usr/bin/env sh
set -e

cd /etc/shlink

# If proxies have not been generated yet, run first-time operations
if ! [[ $(ls -A data/proxies) ]]; then
    rm -f data/cache/app_config.php
    php vendor/doctrine/orm/bin/doctrine.php orm:schema-tool:create
    php vendor/doctrine/migrations/bin/doctrine-migrations.php migrations:migrate
    php vendor/doctrine/orm/bin/doctrine.php orm:generate-proxies
    shlink visit:update-db
fi

php vendor/zendframework/zend-expressive-swoole/bin/zend-expressive-swoole start
