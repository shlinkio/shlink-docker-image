#!/usr/bin/env sh
set -e

# If proxies have not been generated yet, run migrations and generate proxies
if ! [ "$(ls -A shlink/data/proxies)" ]; then
    cd shlink
    rm -rf data/cache/app_config.php
    php vendor/doctrine/orm/bin/doctrine.php orm:schema-tool:create
    php vendor/doctrine/migrations/bin/doctrine-migrations.php migrations:migrate
    php vendor/doctrine/orm/bin/doctrine.php orm:generate-proxies
    cd ..
fi

php shlink/public/index.php start
