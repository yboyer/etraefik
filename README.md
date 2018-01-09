# ETraefik
> Combo of Træfik and Etcd.


## Usage
```shell
# Generate certs for Traefik and Etcd
docker run --rm -v $PWD/certs/etcd/:/certs yboyer/certgen $HOSTNAME
docker run --rm -v $PWD/certs/traefik/:/certs yboyer/certgen $HOSTNAME

docker run --name etraefik \
  -v $PWD/certs/traefik/ca.pem:/certs/RootCA.crt \
  -v $PWD/certs/etcd/$HOSTNAME.pem:/certs/etcd.crt \
  -v $PWD/certs/etcd/$HOSTNAME-key.pem:/certs/etcd.key \
  -e ACME_EMAIL=$EMAIL \
  -e TRAEFIK_AUTH=$TRAEFIK_AUTH \
  -e ETCD_USER=$ETCD_USER \
  -e ETCD_PASS=$ETCD_PASS \
  -v $PWD/etcd-data:/etcd-data
  -p 80:80 -p 8080:8080 -p 443:443 -p 2379:2379 \
  yboyer/etraefik
```

##### Træfik user for the basic auth
```shell
TRAEFIK_AUTH=`htpasswd -nBb -C 10 $USER $PASS`
```

##### Generate a certificate for a new backend
```shell
docker run --rm -v $PWD/certs/traefik/:/certs yboyer/certgen $BACKEND_HOSTNAME
```
will be on `$PWD/certs/traefik/{$BACKEND_HOSTNAME.pem,$BACKEND_HOSTNAME-key.pem}`.

## Why
Træefik doesn't do much good on its own. ¯\\_(ツ)_/¯
