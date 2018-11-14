#!/usr/bin/env bash

source conf/hub.conf

cp src/docker-compose.template.yml docker-compose.yml
cp src/traefik.template.toml traefik.toml

sed -i "s/{{SMTP_EMAIL}}/$SMTP_EMAIL/g" docker-compose.yml
sed -i "s/{{SMTP_SERVER}}/$SMTP_SERVER/g" docker-compose.yml
sed -i "s/{{SMTP_PORT}}/$SMTP_PORT/g" docker-compose.yml
sed -i "s/{{SMTP_PASS}}/$SMTP_PASS/g" docker-compose.yml
sed -i "s/{{SMTP_USER}}/$SMTP_USER/g" docker-compose.yml
sed -i "s/{{HUB_DOMAIN}}/$HUB_DOMAIN/g" docker-compose.yml
sed -i "s/{{HUB_ADMIN_EMAIL}}/$HUB_ADMIN_EMAIL/g" docker-compose.yml

sed -i "s/{{HUB_DOMAIN}}/$HUB_DOMAIN/g" traefik.toml
sed -i "s/{{HUB_ADMIN_EMAIL}}/$HUB_ADMIN_EMAIL/g" traefik.toml

docker-compose up -d
