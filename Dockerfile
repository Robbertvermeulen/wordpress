FROM wordpress:5.1.1-php7.1-apache

# ENABLE APACHE REWRITES
RUN a2enmod ssl && a2enmod rewrite

# OVERRIDE VIRTUALHOSTS
COPY config/httpd-ssl.conf /etc/apache2/conf/extra/httpd-ssl.conf
COPY config/default-ssl.conf /etc/apache2/sites-available
RUN a2ensite default-ssl.conf

# SET SERVERNAME TO LOCALHOST
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# COPY SSL CONFIG
COPY config/localdomain.csr.cnf /etc/apache2/
COPY config/localdomain.v3.ext /etc/apache2/

# START-UP SCRIPTS
COPY config/docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]

# EXPOSE PORTS
EXPOSE 80 443
