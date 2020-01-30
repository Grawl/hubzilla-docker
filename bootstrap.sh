#!/usr/bin/env bash

source conf/hub.conf

cp src/docker-compose.template.yml docker-compose.yml
cp src/traefik.template.toml traefik.toml

sed -i '' "s,{{SMTP_EMAIL}},$SMTP_EMAIL," docker-compose.yml
sed -i '' "s,{{SMTP_SERVER}},$SMTP_SERVER," docker-compose.yml
sed -i '' "s,{{SMTP_PORT}},$SMTP_PORT," docker-compose.yml
sed -i '' "s,{{SMTP_PASS}},$SMTP_PASS," docker-compose.yml
sed -i '' "s,{{SMTP_USER}},$SMTP_USER," docker-compose.yml
sed -i '' "s,{{HUB_DOMAIN}},$HUB_DOMAIN," docker-compose.yml
sed -i '' "s,{{HUB_ADMIN_EMAIL}},$HUB_ADMIN_EMAIL," docker-compose.yml

sed -i '' "s,{{HUB_DOMAIN}},$HUB_DOMAIN," traefik.toml
sed -i '' "s,{{HUB_ADMIN_EMAIL}},$HUB_ADMIN_EMAIL," traefik.toml

touch acme.json
chmod 600 acme.json

docker-compose up -d --build
