#!/usr/bin/env bash

if [ ! -f /etc/krb5kdc/service.keyfile ]; then
    echo "System is not configured, wait for 86400 second..."
    sleep 86400
fi
service krb5-kdc start
service krb5-admin-server start
