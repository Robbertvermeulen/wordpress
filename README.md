### Introduction
This docker image extends the official Wordpress image to include self-signed SSL certification and Linux / Chromebook support.

- Currently only suitable for local use 
- Compatible with macOS, Linux and Chromebook (Crostini)

## How to use

#### docker-compose.yml
```yaml
version: '3.1'

services:
  mysql:
    image: mysql:5.7
    restart: unless-stopped
    volumes:
      - mysql:/var/lib/mysql
    environment:
      MYSQL_DATABASE: exampledb
      MYSQL_USER: exampleuser
      MYSQL_PASSWORD: examplepass
      MYSQL_RANDOM_ROOT_PASSWORD: '1'
  wordpress:
    image: jamesgreenaway/wordpress:latest
    restart: unless-stopped
    depends_on: 
      - mysql
    environment:
      WORDPRESS_DB_HOST: mysql
      WORDPRESS_DB_USER: exampleuser
      WORDPRESS_DB_PASSWORD: examplepass
      WORDPRESS_DB_NAME: exampledb
      SSL_SITE_NAME: Wordpress
      LOCAL_UID: 1000
    ports:
      - "5000:443"
      - "8080:80"
    volumes:
     - ./:/var/www/html
volumes: 
  mysql: {}
```

### Usage
1. Copy "docker-compose.yml" in to website directory and update default environment variables (see below for more information).

1. Run ```$ docker-compose up```.

1. Add self-certified SSL certificate to browsers certificate manager:

   For macOS users:
   * Double-click ```./ssl/cacert.pem``` to open the certificate in the Keychain Access utility
   * Double-click the certificate
   * Click the arrow next to Trust
   * Change the "When using this certificate" field to "Always Trust" and close the window
   * Enter password to confirm
    
   For Chromebook (Crostini) users:
   * Go to ```chrome://certificate-manager/```
   * Click "Authorities" then "IMPORT"
   * Select ```./ssl/cacert.pem```
   * Choose "Trust this certificate for identifying websites"
   * Click "OK"
    
1. Go to ```https://localhost:5000/```

## Setting environment variables

In order to customise Wordpress to your site you must set the following environment variables in your docker-compose file: 

* ```WORDPRESS_DB_HOST```
* ```WORDPRESS_DB_USER```
* ```WORDPRESS_DB_PASSWORD```
* ```WORDPRESS_DB_NAME```
* ```MYSQL_DATABASE```
* ```MYSQL_USER```
* ```MYSQL_PASSWORD```
* ```MYSQL_RANDOM_ROOT_PASSWORD```
* ```LOCAL_UID```\*
* ```SSL_SITE_NAME```\**

\* For Linux users, your ```LOCAL_UID``` must match the UID of the host.  This can be found by typing ```$ id -u```. (This environment variable can be ignored for macOS users.)

\** The ```SSL_SITE_NAME``` environment variable is used to name the SSL certificate.  The certificates for each new site can be found under their respective name and (for Chromebooks) under the heading "org-localhost".  Each site can be freely deleted once finished with. 

## Further information
* It is advised that you start docker-compose with a project name by typing ```docker-compose -p <project-name> up```. This will avoid any future name collisions with other containers

* Other ports can be used on your local device if necessary.

## Links

* [Docker Hub](https://hub.docker.com/r/jamesgreenaway/wordpress)
* [Github](https://github.com/JamesGreenaway/wordpress) 
