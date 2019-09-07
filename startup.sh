#!/bin/bash
set -euo pipefail

echo "wating for mysql..."
mysqladmin ping -u${WORDPRESS_DB_USER} -h${WORDPRESS_DB_HOST:-mysql} -p${WORDPRESS_DB_PASSWORD:-} --silent --wait
mysql -u${WORDPRESS_DB_USER} -p${WORDPRESS_DB_PASSWORD:-} -h${WORDPRESS_DB_HOST:-mysql} -e "CREATE DATABASE IF NOT EXISTS ${WORDPRESS_DB_NAME}"

sudo sh -c "chown wordpress:wordpress /var/www/html"

export SERVER_NAME=`echo ${SITE_URL} |  awk -F"/" '{print $3}'`
sudo sh -c "echo 'ServerName ${SERVER_NAME}' >> /etc/apache2/apache2.conf"
sudo sed -ri "s!Listen 80!Listen 5000!" /etc/apache2/ports.conf
sudo sed -ri "s!ServerName!ServerName ${SERVER_NAME}!" /etc/apache2/sites-available/000-default.conf

sudo sed -i -e 's/^exec "$@"/#exec "$@"/g' /usr/local/bin/docker-entrypoint.sh
source /usr/local/bin/docker-entrypoint.sh
echo "starting apache..."
exec "$@"
