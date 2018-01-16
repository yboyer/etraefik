#!/bin/sh -e

cp /etc/traefik/traefik.toml /traefik.toml

if [ -z $ETCD_USER ] || [ -z $ETCD_PASS ]; then
  echo -e '\e[93m'
  echo 'Warning:'
  echo 'Etcd does not have auth specified by $ETCD_USER and $ETCD_PASS. Skiping.'
  echo -e '\e[0m'
else
  etcd &
  insec=' --insecure-transport=false --insecure-skip-tls-verify'
  etcdctl $insec user add $ETCD_USER:$ETCD_PASS
  etcdctl $insec auth enable
  kill %1

  sed -i -e 's|# username = "ETCD_USER"|username = "'$ETCD_USER'"|' /traefik.toml
  sed -i -e 's|# password = "ETCD_PASS"|password = "'$ETCD_PASS'"|' /traefik.toml
fi

if [ -z $TRAEFIK_AUTH ]; then
  echo -e '\e[93m'
  echo 'Warning:'
  echo 'Traefik does not have basic auth specified by $TRAEFIK_AUTH. Skiping.'
  echo -e '\e[0m'
else
  sed -i -e 's|# \[web.auth.basic\]|\[web.auth.basic\]|' /traefik.toml
  sed -i -e 's|# users = \["TRAEFIK_AUTH"\]|users = \["'$TRAEFIK_AUTH'"\]|' /traefik.toml
fi

if [ -z $ACME_EMAIL ]; then
  echo -e '\e[93m'
  echo 'Warning:'
  echo 'Traefik acme does not have email specified by $ACME_EMAIL. Skiping.'
  echo -e '\e[0m'
else
  sed -i -e 's|email = .*|email = "'$ACME_EMAIL'"|' /traefik.toml
fi

exec supervisord