#!/usr/bin/env bash

if [ "$1" = '' ]; then
    if [ ! -f /etc/krb5kdc/service.keyfile ]; then
        echo "System is not configured, wait for 86400 second..."
        sleep 86400
    fi
    service krb5-kdc start
    service krb5-admin-server start
    tail -F /var/log/krb5kdc.log
    exit 0
fi

echo "[RUN]: $@"
exec "$@"
