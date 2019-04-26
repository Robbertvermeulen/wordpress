#!/bin/bash
set -euo pipefail

# mute CMD from official wordpress image
sed -i -e 's/^exec "$@"/#exec "$@"/g' /usr/local/bin/docker-entrypoint.sh

# execute bash script from official wordpress image
source /usr/local/bin/docker-entrypoint.sh

# set server name 
echo "ServerName ${APACHE_SERVER_NAME}" >> /etc/apache2/apache2.conf

# custom scripts
user.sh
ssl.sh

# execute CMD
exec "$@"
