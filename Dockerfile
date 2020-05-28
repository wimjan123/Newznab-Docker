FROM ubuntu:latest 
MAINTAINER fekhoo@gmail.com

#Install required packages
RUN apt-get update && apt-get -yq install ssh screen tmux apache2 php php-fpm php-pear php-gd php-mysql php-memcache php-curl \
php-json php-mbstring unrar lame mediainfo subversion ffmpeg memcached 

# Add Variables SVN Password and user
ENV nn_user svnplus 
ENV nn_pass svnplus5
ENV php_timezone America/New_York 
ENV path /:/var/www/html/www/

#Configer Apache
ADD ./newznab.conf /etc/apache2/sites-available/newznab.conf


# Creating Newznab Folders from SVN
RUN mkdir /var/www/newznab/
RUN svn co --username $nn_user --password $nn_pass svn://svn.newznab.com/nn/branches/nnplus /var/www/newznab/
RUN chmod 777 /var/www/newznab/www/lib/smarty/templates_c && \
chmod 777 /var/www/newznab/www/covers/movies && \
chmod 777 /var/www/newznab/www/covers/anime  && \
chmod 777 /var/www/newznab/www/covers/music  && \
chmod 777 /var/www/newznab/www  && \
chmod 777 /var/www/newznab/www/install  && \
chmod 777 /var/www/newznab/nzbfiles/ 

#fix the config files for PHP
RUN sed -i "s/max_execution_time = 30/max_execution_time = 120/" /etc/php5/cli/php.ini  && \
sed -i "s/memory_limit = -1/memory_limit = 1024M/" /etc/php5/cli/php.ini  && \
echo "register_globals = Off" >> /etc/php5/cli/php.ini  && \
echo "date.timezone =$php_timezone" >> /etc/php5/cli/php.ini  && \
sed -i "s/max_execution_time = 30/max_execution_time = 120/" /etc/php5/apache2/php.ini  && \
sed -i "s/memory_limit = -1/memory_limit = 1024M/" /etc/php5/apache2/php.ini  && \
echo "register_globals = Off" >> /etc/php5/apache2/php.ini  && \
echo "date.timezone =$php_timezone" >> /etc/php5/apache2/php.ini  && \
sed -i "s/memory_limit = 128M/memory_limit = 1024M/" /etc/php5/apache2/php.ini

# Disable Default site and enable newznab site - Restart Apache here to confirm your newznab.conf is valid in case you changed it
RUN a2dissite 000-default.conf
RUN a2ensite newznab
RUN a2enmod rewrite
RUN service apache2 restart

# add newznab config file - This needs to be edited
ADD ./config.php /var/www/newznab/www/config.php
RUN chmod 777 /var/www/newznab/www/config.php

#add newznab processing script
ADD ./newznab.sh /newznab.sh
RUN chmod 755 /*.sh

#Setup supervisor to start Apache and the Newznab scripts to load headers and build releases

RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup NZB volume this will need to be mapped locally using -v command so that it can persist.
EXPOSE 80
VOLUME /nzb
WORKDIR /var/www/html/www/
#kickoff Supervisor to start the functions
CMD ["/usr/bin/supervisord"]
