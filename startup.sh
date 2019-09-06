#!/bin/bash
set -euo pipefail

if [ ! "$(ls -A /var/www/html/)" ]; then
    mysql_connect_retry () {
        while ! mysqladmin ping -u${WORDPRESS_DB_USER} -h${WORDPRESS_DB_HOST:-mysql} -p${WORDPRESS_DB_PASSWORD} --silent; do
            echo "- Awaiting response from MySQL..."
            sleep 10
        done
    }

    setup_mysql_database () {
        mysql -uroot -p${MYSQL_ROOT_PASSWORD:-} -h${WORDPRESS_DB_HOST:-mysql} -e "CREATE DATABASE IF NOT EXISTS ${WORDPRESS_DB_NAME}"
        mysql -uroot -p${MYSQL_ROOT_PASSWORD:-} -h${WORDPRESS_DB_HOST:-mysql} -e "GRANT ALL PRIVILEGES ON *.* TO ${WORDPRESS_DB_USER}@'%'"
        mysql -uroot -p${MYSQL_ROOT_PASSWORD:-} -h${WORDPRESS_DB_HOST:-mysql} -e "ALTER USER ${WORDPRESS_DB_USER}@'%' IDENTIFIED WITH mysql_native_password BY '${WORDPRESS_DB_PASSWORD}'"
        mysql -uroot -p${MYSQL_ROOT_PASSWORD:-} -h${WORDPRESS_DB_HOST:-mysql} -e "FLUSH PRIVILEGES"
    }

    mysql_connect_retry
    setup_mysql_database
fi

sudo sh -c "chown wordpress:wordpress /var/www/html"

# Remove https from SITE_URL.
export SERVER_NAME=`echo ${SITE_URL} |  awk -F"/" '{print $3}'`
sudo sh -c "echo 'ServerName ${SERVER_NAME}' >> /etc/apache2/apache2.conf"
# Update Virtual Hosts with server name/alias.
sudo sed -ri "s!ServerName!ServerName ${SERVER_NAME}!" /etc/apache2/sites-available/000-default.conf
sudo sed -ri "s!Listen 80!Listen 5000!" /etc/apache2/ports.conf

# mute CMD from official wordpress image
sudo sed -i -e 's/^exec "$@"/#exec "$@"/g' /usr/local/bin/docker-entrypoint.sh
# execute bash script from official wordpress image
source /usr/local/bin/docker-entrypoint.sh

PURPLE='\033[1;35m'
NO_COLOR='\033[0m'
PARTY_POPPER='🎉'
echo -e "\n- Congratulations ${PARTY_POPPER}  your Wordpress site ready to go! Please visit: ${PURPLE} ${SITE_URL} ${NO_COLOR}\n"

exec "$@"
