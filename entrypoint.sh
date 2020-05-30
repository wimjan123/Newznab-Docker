#!/bin/bash

#Creating Config File
if [[ -n "$DB_TYPE" && -n "$DB_HOST" && -n "$DB_PORT" && -n "$DB_USER" && -n "$DB_PASSWORD" && -n "$DB_NAME" && -n "$NNTP_USERNAME" && -n "$NNTP_PASSWORD" && -n "$NNTP_SERVER" && -n "$NNTP_PORT" && -n "$NNTP_SSLENABLED" ]]; then
	echo "Creating database configuration"
	echo "define('DB_TYPE', '$DB_TYPE');" >> /config/config.php
	echo "define('DB_HOST', '$DB_HOST');" >> /config/config.php
	echo "define('DB_PORT', $DB_PORT);" >> /config/config.php
	echo "define('DB_USER', '$DB_USER');" >> /config/config.php
	echo "define('DB_PASSWORD','$DB_PASSWORD');" >> /config/config.php
	echo "define('DB_NAME', '$DB_NAME');" >> /config/config.php
	echo "define('DB_INNODB', true);" >> /config/config.php
	echo "define('DB_PCONNECT', true);" >> /config/config.php
	echo "define('DB_ERRORMODE', PDO::ERRMODE_SILENT);" >> /config/config.php
	echo "define('NNTP_USERNAME', '$NNTP_USERNAME');" >> /config/config.php
	echo "define('NNTP_PASSWORD', '$NNTP_PASSWORD');" >> /config/config.php
	echo "define('NNTP_SERVER', '$NNTP_SERVER');" >> /config/config.php
	echo "define('NNTP_PORT', '$NNTP_PORT');" >> /config/config.php
	echo "define('NNTP_SSLENABLED', $NNTP_SSLENABLED);" >> /config/config.php
fi

if [ -f /config/config.php ]; then
	chmod 777 /config/config.php
	#rm -f /var/www/newznab/www/config.php
	ln -s /config/config.php /var/www/newznab/www/config.php
else
	echo -e "\nWARNING: You have no database configuration file, either create /config/config.php or restart this container with the correct environment variables to auto generate the config.\n"
fi

# Clean up apache pid (if there is one)
#rm -rf /run/apache2/apache2.pid

screen -dmS newznab && ./newznab.sh

/bin/bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND"
