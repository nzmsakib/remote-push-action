#!/usr/bin/bash

# This script is executed after the repo is pulled.
echo "Executing from post-pull.sh"

# abort on errors
set -e

# Install npm dependencies if package.json has changed
# echo Starting npm install
# npm install
# echo npm install finished

# Install php composer dependencies if composer.json has changed
# echo Starting composer install
# composer install
# echo Composer install finished

# migrate database if migrations have changed
# echo Starting php artisan migrate
# php artisan migrate:fresh --seed --force
# echo php artisan migrate finished

# link storage if storage folder has changed
# echo Starting php artisan storage:link
# php artisan storage:link
# echo php artisan storage:link finished

# npm build for production
# echo Starting npm run production
# npm run build
# echo npm run production finished

# Done!
echo "Done!"

# Exit with a success code
exit 0