#!/usr/bin/bash

# This script is executed after the repo is cloned.
echo "Executing: post-clone.sh"

# abort on errors
set -e

# Install npm dependencies
echo Starting npm install
npm install
echo npm install finished

# Install php composer dependencies
echo Starting composer install
composer install
echo Composer install finished

# create .env file
echo Creating .env file
cp .env.example .env
echo .env file created

# generate key
echo Generating key
php artisan key:generate
echo Key generated

# add database credentials
echo Please add database credentials to .env file and run php artisan migrate

# Done!
echo "Done!: post-clone.sh"

# Exit with a success code
exit 0