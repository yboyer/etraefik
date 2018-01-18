#!/bin/sh -e

destTraefikConf=/etc/traefik/traefik.toml
mkdir `dirname $destTraefikConf`
cp /traefik.toml $destTraefikConf
insec=' --insecure-transport=false --insecure-skip-tls-verify'

etcd &
if [ -z $ETCD_USER ] || [ -z $ETCD_PASS ]; then
  echo -e '\e[93m'
  echo 'Warning:'
  echo 'Etcd does not have auth specified by $ETCD_USER and $ETCD_PASS. Skiping.'
  echo -e '\e[0m'
else
  etcdctl $insec user add $ETCD_USER:$ETCD_PASS
  etcdctl $insec auth enable

  userOption="--user=$ETCD_USER:$ETCD_PASS"

  sed -i -e 's|# username = "ETCD_USER"|username = "'$ETCD_USER'"|' $destTraefikConf
  sed -i -e 's|# password = "ETCD_PASS"|password = "'$ETCD_PASS'"|' $destTraefikConf

  echo 'Etcd config done'
fi
etcdctl $insec put "/traefik/acme/account/lock" "" $userOption
etcdctl $insec put "/traefik/acme/account/object" "" $userOption
kill %1



if [ -z $TRAEFIK_AUTH ]; then
  echo -e '\e[93m'
  echo 'Warning:'
  echo 'Traefik does not have basic auth specified by $TRAEFIK_AUTH. Skiping.'
  echo -e '\e[0m'
else
  sed -i -e 's|# \[web.auth.basic\]|\[web.auth.basic\]|' $destTraefikConf
  sed -i -e 's|# users = \["TRAEFIK_AUTH"\]|users = \["'$TRAEFIK_AUTH'"\]|' $destTraefikConf
fi

if [ -z $ACME_EMAIL ]; then
  echo -e '\e[93m'
  echo 'Warning:'
  echo 'Traefik acme does not have email specified by $ACME_EMAIL. Skiping.'
  echo -e '\e[0m'
else
  sed -i -e 's|email = .*|email = "'$ACME_EMAIL'"|' $destTraefikConf
fi

exec supervisord
