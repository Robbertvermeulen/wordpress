FROM wordpress:5.2.2-php7.3-apache
RUN apt-get update && apt-get -y upgrade

RUN apt-get install -y \ 
    sudo mariadb-client iputils-ping 

# CONFIGURE APACHE 
RUN a2enmod rewrite

# OVERRIDE VIRTUALHOSTS
ENV APACHE_DOCUMENT_ROOT /var/www/html
COPY ./virtualhost.conf /etc/apache2/sites-available/000-default.conf

# CREATE USER
ARG LOCAL_UID=1000
RUN groupadd -g $LOCAL_UID wordpress && \
    useradd -rm -s /bin/bash -u $LOCAL_UID -g wordpress -G sudo wordpress
RUN echo "wordpress ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/wordpress && \
    chmod 0440 /etc/sudoers.d/wordpress
ENV APACHE_RUN_USER wordpress
ENV APACHE_RUN_GROUP wordpress

# SET WORKING DIRECTORY
WORKDIR /var/www/html/

# COPY SCRIPTS
COPY ./startup.sh /usr/local/bin/startup
RUN chmod u+x /usr/local/bin/startup

# SET USER
USER wordpress

# RUN STARTUP SCRIPT
ENTRYPOINT ["startup"]
CMD ["apache2-foreground"]

# EXPOSE PORTS
EXPOSE 5000
