#!/bin/bash
set -e

case "$1" in
configure)
    app_home="/opt/roshi"
    service_user="roshi"
    service_name="roshi-server"

    if ! getent passwd ${service_user} >/dev/null; then
        adduser --system --group --no-create-home \
         --home ${app_home} --shell /bin/false \
         --gecos "${service_name} user" ${service_user}
    fi
    chown -R ${service_user}:${service_user} ${app_home}

    chown root:root /etc/default/${service_name}
    chown root:root /etc/init/${service_name}.conf
    ;;
esac
