#!/bin/bash

set -e
export SSL_SITE_NAME="${SSL_SITE_NAME:-Testing}"

html=( `find /var/www/html -maxdepth 1 -name "ssl"`)
if [ ${#html[@]} -gt 0 ]; then
    echo "- SSL already generated"
    cp /var/www/html/ssl/localdomain.crt /var/www/html/ssl/localdomain.insecure.key /etc/apache2/
else
	openssl genrsa -des3 -passout pass:password -out /etc/apache2/localdomain.secure.key 2048  && \
	echo "password" |openssl rsa -in /etc/apache2/localdomain.secure.key -out /etc/apache2/localdomain.insecure.key -passin stdin  && \
	openssl req -new -sha256 -nodes -out /etc/apache2/localdomain.csr -key /etc/apache2/localdomain.insecure.key -config /etc/apache2/localdomain.csr.cnf && \
	openssl genrsa -des3 -passout pass:password -out /etc/apache2/rootca.secure.key 2048  && \
	echo "password" | openssl rsa -in /etc/apache2/rootca.secure.key -out /etc/apache2/rootca.insecure.key -passin stdin  && \
	openssl req -new -x509 -nodes -key /etc/apache2/rootca.insecure.key -sha256 -out /etc/apache2/cacert.pem -days 3650 -subj "/C=GB/ST=London/L=London/O=${APACHE_SERVER_NAME}/OU=IT Department/CN=${SSL_SITE_NAME}"  && \
	openssl x509 -req -in /etc/apache2/localdomain.csr -CA /etc/apache2/cacert.pem -CAkey /etc/apache2/rootca.insecure.key -CAcreateserial -out /etc/apache2/localdomain.crt -days 500 -sha256 -extfile /etc/apache2/localdomain.v3.ext
	mkdir /var/www/html/ssl
	chown www-data:www-data -R /var/www/html/ssl
	mv /etc/apache2/cacert.pem /var/www/html/ssl
	cp /etc/apache2/localdomain.crt /etc/apache2/localdomain.insecure.key /var/www/html/ssl
	chown www-data:www-data -R /var/www/html/ssl
fi
