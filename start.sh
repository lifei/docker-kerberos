#!/usr/bin/env bash

if [ ! -f /etc/krb5kdc/service.keyfile ]; then
    echo "Error: system is not configured..."
    exit 1
fi

if [ ! -f /etc/krb5.conf ]; then
    cp -f /etc/krb5kdc/krb5.conf /etc/krb5.conf
fi

service krb5-kdc start
service krb5-admin-server start
