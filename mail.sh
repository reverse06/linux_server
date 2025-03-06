#!/bin/bash

#--------------------------------------------------------------
#-----------------------------------------Début du serveur mail

echo "Configuration du serveur mail..."

sudo tee /etc/postfix/main.cf > /dev/null <<EOF

myhostname = mail.site.local
mydomain = site.local
myorigin = $mydomain
inet_interfaces = all
inet_protocols = ipv4
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
mynetworks = 192.168.0.0/24, 127.0.0.0/8
home_mailbox = Maildir/

EOF

systemctl restart postfix

sudo tee /etc/dovecot/dovecot.conf > /dev/null <<EOF

protocols = imap pop3 lmtp

EOF

sudo tee /etc/dovecot/conf.d/10-mail.conf > /dev/null <<EOF

mail_location = maildir:~/Maildir

EOF

sudo systemctl restart dovecot

sudo useradd -m -s /sbin/nologin usermail
passwd usermail

sudo tee /var/lib/named/site.local.zone > /dev/null <<EOF

@   IN  MX 10 mail.site.local.
mail IN  A  192.168.0.2

EOF

sudo systemctl restart named

echo "Serveur mail configuré."

#-------------------------------------------Fin du serveur mail
#--------------------------------------------------------------