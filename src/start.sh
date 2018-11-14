#!/usr/bin/env bash

if ls -l /var/lib/mysql/hubzilla/account.frm 2> /dev/null > /dev/null
then
  echo "Database already installed."
else
  echo "Installing database..."
  # The pause for five seconds give the database container time to start. Database
  # connection errors can occur if there is no delay.
  sleep 5
  # Initialize the database tables
  mysql -h db -uhubzilla -phubzilla hubzilla < /var/www/html/install/schema_mysql.sql
fi

/usr/sbin/apache2ctl -D FOREGROUND
