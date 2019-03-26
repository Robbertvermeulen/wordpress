FROM wordpress:5.1.1-php7.1-apache

# ENABLE APACHE REWRITES
RUN a2enmod ssl && a2enmod rewrite

# OVERRIDE VIRTUALHOSTS
COPY config/httpd-ssl.conf /etc/apache2/conf/extra/httpd-ssl.conf
COPY config/000-default.conf /etc/apache2/sites-available
COPY config/default-ssl.conf /etc/apache2/sites-available
RUN a2ensite 000-default.conf && a2ensite default-ssl.conf

# SET SERVERNAME TO LOCALHOST
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# COPY SSL CONFIG
COPY config/localdomain.csr.cnf /etc/apache2/
COPY config/localdomain.v3.ext /etc/apache2/

# START-UP SCRIPTS
COPY config/user.sh /usr/local/bin
COPY config/ssl.sh /usr/local/bin
COPY config/startup.sh /usr/local/bin
ENTRYPOINT ["startup.sh"]
CMD ["apache2-foreground"]

# EXPOSE PORTS
EXPOSE 80 443
