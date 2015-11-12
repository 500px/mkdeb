#!/bin/bash
set -e

case "$1" in
configure)
    app_home="/opt/oauth2_proxy"
    service_user="oauth2_proxy"
    service_name="oauth2_proxy"

    if ! getent passwd ${service_user} >/dev/null; then
        adduser --system --group --no-create-home \
         --home ${app_home} --shell /bin/false \
         --gecos "${service_name} user" ${service_user}
    fi

    chown -R root:root ${app_home}
    chown -R root:root /etc/${service_name}
    chown root:root /etc/init/${service_name}.conf
    ;;
esac
