FROM debian:9.7
ENV DEBIAN_FRONTEND noninteractive

ARG DOMAIN
ARG SMTP_EMAIL
ARG SMTP_SERVER
ARG SMTP_PORT
ARG SMTP_USER
ARG SMTP_PASS
ARG ADMIN_EMAIL

# Install packages
RUN apt-get update && apt-get install -y apache2 openssl php php-cli php-mysql php-curl php-fpm php-gd php-json php-xml php-zip php-mbstring software-properties-common git ssmtp mysql-client

# Remove APT files
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Generate self-signed SSL certificate
RUN openssl req -x509 -nodes -subj "/C=US/ST=Oregon/L=Portland/O=organization/OU=Org/CN=$DOMAIN" -newkey rsa:4096 -keyout /etc/ssl/private/$DOMAIN.key -out /etc/ssl/certs/$DOMAIN.crt -days 365

# Install and activate the apache config file
COPY src/container_apache.conf /etc/apache2/sites-available/$DOMAIN.conf
RUN sed -i "s/{{DOMAIN}}/$DOMAIN/g" /etc/apache2/sites-available/$DOMAIN.conf
RUN a2dissite 000-default default-ssl
RUN a2ensite $DOMAIN.conf
RUN a2enmod ssl rewrite

# Construct the hub web root from the official git repositories
RUN rm -r /var/www/html/
RUN git clone https://framagit.org/hubzilla/core.git /var/www/html/
RUN cd /var/www/html/ && util/add_addon_repo https://framagit.org/hubzilla/addons.git official
RUN mkdir -p "/var/www/html/store/[data]/smarty3" && \
    chown -R www-data:www-data /var/www/html/

# Configure sSMTP for hub activity notification email delivery
COPY src/ssmtp.conf /etc/ssmtp/ssmtp.conf
COPY src/revaliases /etc/ssmtp/revaliases
RUN sed -i "s/{{SMTP_EMAIL}}/$SMTP_EMAIL/g" /etc/ssmtp/ssmtp.conf && \
    sed -i "s/{{SMTP_SERVER}}/$SMTP_SERVER/g" /etc/ssmtp/ssmtp.conf && \
    sed -i "s/{{SMTP_PORT}}/$SMTP_PORT/g" /etc/ssmtp/ssmtp.conf && \
    sed -i "s/{{SMTP_PASS}}/$SMTP_PASS/g" /etc/ssmtp/ssmtp.conf && \
    sed -i "s/{{SMTP_USER}}/$SMTP_USER/g" /etc/ssmtp/ssmtp.conf
RUN sed -i "s/{{SMTP_EMAIL}}/$SMTP_EMAIL/g" /etc/ssmtp/revaliases
RUN sed -i 's#\;sendmail_path =#sendmail_path = /usr/sbin/ssmtp -t#g' /etc/php/7.0/apache2/php.ini

# Generate the basic hub config file
COPY src/.htconfig.php /var/www/html/.htconfig.php
RUN LOCATION_HASH=$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 64 | head -n 1) && \
    sed -i "s/{{DOMAIN}}/$DOMAIN/g" /var/www/html/.htconfig.php && \
    sed -i "s/{{LOCATION_HASH}}/$LOCATION_HASH/g" /var/www/html/.htconfig.php && \
    sed -i "s/{{ADMIN_EMAIL}}/$ADMIN_EMAIL/g" /var/www/html/.htconfig.php

RUN echo "*/15 * * * * cd /var/www/html; /usr/bin/php Zotlabs/Daemon/Master.php Cron" | crontab -u www-data -

# Run the startup script when the container is launched
COPY src/start.sh /start.sh
CMD /bin/bash /start.sh
