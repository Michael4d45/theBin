#!/bin/sh
set -e

echo "Prd Entrypoint Script Started"

echo "Cache the framework bootstrap files"
php artisan optimize

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
    set -- php-fpm "$@"
fi

exec "$@"
