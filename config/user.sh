#!/bin/bash

set -e

sed -ri "s/^www-data:x:33:33:/www-data:x:${LOCAL_UID:-1000}:${LOCAL_UID:-1000}:/" /etc/passwd
sed -ri "s/^www-data:x:33:/www-data:x:${LOCAL_UID:-1000}:/" /etc/group
chown -R www-data:www-data /var/www/html
