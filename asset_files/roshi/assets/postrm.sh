#!/bin/bash
set -e

case "$1" in
remove | purge)
    echo "Package removal, cleaning up"

    service_user="roshi"
    service_name="roshi-server"

    # Delete user
    if getent passwd ${service_user} >/dev/null; then
        deluser --system --quiet ${service_user}
    fi

    # Delete upstart script
    if [[ -e /etc/init/${service_name}.conf  ]]; then
      rm /etc/init/${service_name}.conf
    fi

    if [[ -e /etc/init.d/${service_name}  ]]; then
      rm /etc/init.d/${service_name}
    fi

    # If dpkg deletes /opt like a jerk
    if [[ ! -d /opt ]]; then
      mkdir /opt
    fi
    ;;
upgrade)
    echo "Package upgrade, skipping clean up."
esac
