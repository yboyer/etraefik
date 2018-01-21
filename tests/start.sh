#!/bin/sh -e

cd `dirname $0`

IP='127.0.0.1'

TRAEFIK_AUTH=`htpasswd -nBb -C 10 admin 'test'`
ETCD_USER="root"
ETCD_PASS="test"

docker build -t yboyer/etraefik ..

# Generate certs for Traefik and Etcd
docker run --rm -v $PWD/certs/etcd/:/certs yboyer/certgen $IP
docker run --rm -v $PWD/certs/traefik/:/certs yboyer/certgen $IP

docker run --rm -d --name etraefik \
  -v $PWD/certs/traefik/ca.pem:/certs/RootCA.crt \
  -v $PWD/certs/etcd/$IP.pem:/certs/etcd.crt \
  -v $PWD/certs/etcd/$IP-key.pem:/certs/etcd.key \
  -e ACME_EMAIL=yboyer@w-inn.eu \
  -e TRAEFIK_AUTH=$TRAEFIK_AUTH \
  -e ETCD_USER=$ETCD_USER \
  -e ETCD_PASS=$ETCD_PASS \
  -e DEBUG=true \
  -p 80:80 -p 8080:8080 -p 443:443 -p 2379:2379 \
  yboyer/etraefik

sleep 3

docker logs etraefik

node tests.js

docker kill etraefik
