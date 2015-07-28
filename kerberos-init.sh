#!/usr/bin/env bash

ldap_kerberos_container_dn=cn=kerberos,$DOMAIN_DN
ldap_kdc_dn=$ADMIN_DN
ldap_kadmind_dn=$ADMIN_DN
ldap_service_password_file=/etc/krb5kdc/service.keyfile
KDC_ADDRESS=$HOSTNAME

cat > /etc/krb5.conf<<EOF
[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmin.log

[libdefaults]
 default_realm = $KRB5REALM
 dns_lookup_realm = false
 dns_lookup_kdc = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true

[realms]
 $KRB5REALM = {
  kdc = $KDC_ADDRESS
  admin_server = $KDC_ADDRESS
  default_domain = $DOMAIN_REALM
  database_module = openldap_ldapconf
 }

[domain_realm]
 .$DOMAIN_REALM = $KRB5REALM
 $DOMAIN_REALM = $KRB5REALM

[appdefaults]
 pam = {
  debug = false
  ticket_lifetime = 36000
  renew_lifetime = 36000
  forwardable = true
  krb4_convert = false
 }

[dbdefaults]
 ldap_kerberos_container_dn = "$ldap_kerberos_container_dn"

[dbmodules]
 openldap_ldapconf = {
    db_library = kldap
    ldap_kdc_dn = "$ldap_kdc_dn"

    # this object needs to have read rights on
    # the realm container, principal container and realm sub-trees
    ldap_kadmind_dn = "$ldap_kadmind_dn"

    # this object needs to have read and write rights on
    # the realm container, principal container and realm sub-trees
    ldap_service_password_file = $ldap_service_password_file
    ldap_servers = ldap://$LDAP_HOST
    ldap_conns_per_server = 5
 }
EOF

cat > /etc/krb5kdc/kadm5.acl <<EOF
*/admin@$KRB5REALM  *
EOF

kdb5_ldap_util -D $ADMIN_DN -w $ADMIN_PW create -subtrees $DOMAIN_DN -r $KRB5REALM -s
kdb5_ldap_util -D $ADMIN_DN -w $ADMIN_PW stashsrvpw -f $ldap_service_password_file $ADMIN_DN <<EOF
$ADMIN_PW
$ADMIN_PW

EOF

ps -ef | grep sleep | grep 86400 | awk '{print $2}' | xargs kill
