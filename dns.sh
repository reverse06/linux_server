#!/bin/bash

#-----------------------------------------------
#---------------------------Début du serveur DNS

echo "Configuration du serveur DNS..."

sudo tee /etc/named.conf > /dev/null <<EOF
zone "monsite.local" IN {
    type master;
    file "/var/lib/named/monsite.local.zone";
};

zone "0.168.192.in-addr.arpa" IN {
    type master;
    file "/var/lib/named/0.168.192.in-addr.arpa.zone";
};

forwarders {
    1.1.1.1;
    8.8.8.8;
};

EOF

sudo tee /var/lib/named/site.local.zone > /dev/null <<EOF
$TTL 86400
@   IN  SOA site.local. admin.site.local. (
        2025022801 ; Serial
        3600       ; Refresh
        1800       ; Retry
        604800     ; Expire
        86400 )    ; Minimum TTL

    IN  NS  ns.site.local.
ns  IN  A   192.168.0.2  ; IP du serveur DNS
@   IN  A   192.168.0.2  ; IP du serveur Web
www IN  A   192.168.0.2  ; Alias pour le serveur Web

EOF

sudo tee /var/lib/named/0.168.192.in-addr.arpa.zone > /dev/null <<EOF
$TTL 86400
@   IN  SOA monsite.local. admin.monsite.local. (
        2025022801 ; Serial
        3600       ; Refresh
        1800       ; Retry
        604800     ; Expire
        86400 )    ; Minimum TTL

    IN  NS  ns.site.local.
2   IN  PTR site.local.

EOF

sudo systemctl restart named.service

echo "Serveur DNS configuré."

#-------------------------------------------Fin du serveur DNS
#-------------------------------------------------------------