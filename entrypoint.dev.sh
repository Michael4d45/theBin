#!/usr/bin/env bash
set -Ee

echo "Dev Entrypoint Script Started"

# Generating the autoloader takes forever, even when no packages are installed.
if [ ! -f "vendor/autoload.php" ] ; then
    echo "composer install"
    composer install
fi

echo "seeding database"

php artisan migrate:fresh --seed

echo "starting php-fpm daemon"

# exec required. executing `php-fpm`, w/o exec, will spawn a subshell and we won't
# get SIGTERM from docker. Docker has a 10s default timeout before sending a SIGKILL.
exec php-fpm
