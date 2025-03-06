#!/bin/bash

#-----------------------------------------------
#----Début de l'installation des services requis

echo "Installation des services requis..."

sudo zypper install apache2 apache-mod_ssl btop openssh wireshark-qt nmap nfs-kernel-utils nfs-utils nfs-client bind bind-utils chrony postfix dovecot

echo "Tous les services requis installés."

#-------Fin de l'installation des services requis
#------------------------------------------------


#-----------------------------------------------
#------------------Démarrage des services requis

echo "Démarrage des services requis..."

sudo systemctl enable --now sshd
sudo systemctl enable --now named.service
sudo systemctl enable --now apache2
sudo systemctl enable --now postfix
sudo systemctl enable --now dovecot

echo "Services requis démarrés."

#-----------------------------------------------
#-----------Fin du démarrage des services requis


#-----------------------------------------------
#---------------------------Début du service SSH

echo "Configuratin du service SSH..."

sudo sed -i 's/^Port 22/Port 2025/' /etc/ssh/sshd_config

sudo systemctl restart sshd

echo "Service SSH configuré. Le port dédié est 2025."

#------------------------------Fin du service SSH
#------------------------------------------------


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


#--------------------------------------------------------------
#------------------------------------------Début du serveur web

echo "Configuration du serveur web..."

sudo tee /etc/apache2/vhosts.d/site.local.conf > /dev/null <<EOF

<VirtualHost *:80>
    ServerName site.local
    ServerAlias www.site.local
    DocumentRoot /var/www/site.local

    <Directory /var/www/site.local>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /var/log/apache2/site.local-error.log
    CustomLog /var/log/apache2/site.local-access.log combined
</VirtualHost>

EOF

a2ensite site.local
systemctl restart apache2

mkdir -p /var/www/site.local
echo "<h1>Test réussi !</h1>" > /var/www/site.local/index.html
chown -R wwwrun:www /var/www/site.local
chmod -R 755 /var/www/site.local

systemctl restart apache2

echo "Serveur web configuré."

#--------------------------------------------Fin du serveur web
#--------------------------------------------------------------


#--------------------------------------------------------------
#----------------------------------------Début du serveur temps

echo "Configuration du serveur NTP..."

sudo tee /etc/chrony.conf > /dev/null <<EOF
server 0.pool.ntp.org iburst
server 1.pool.ntp.org iburst

allow 192.168.0.0/24  # Autorise le réseau local à interroger ce serveur

EOF

systemctl restart chronyd

echo "Serveur NTP configuré."

#------------------------------------------Fin du serveur temps
#--------------------------------------------------------------


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


#--------------------------------------------------------------
#------------------------------------Début du serveur de backup

echo "Configuration de la backup avec le serveur tiers..."

sudo mkdir -p /mnt/nfs/var/log
sudo mkdir -p /mnt/nfs/var/www
sudo mkdir -p /mnt/nfs/var/srv

sudo mount 192.168.0.3:/backups /mnt/nfs/var/log
sudo mount 192.168.0.3:/backups /mnt/nfs/var/www
sudo mount 192.168.0.3:/backups /mnt/nfs/var/srv

sudo tee /etc/fstab > /dev/null <<EOS
192.168.0.3:/backups /mnt/nfs/var/log nfs defaults 0 0
192.168.0.3:/backups /mnt/nfs/var/www nfs defaults 0 0
192.168.0.3:/backups /mnt/nfs/var/srv nfs defaults 0 0

EOS

sudo rsync -av --delete /var/log/ /mnt/nfs/var/log/
sudo rsync -av --delete /var/www/ /mnt/nfs/var/www/
sudo rsync -av --delete /var/srv/ /mnt/nfs/var/srv/

sudo touch /usr/local/bin/backup.sh
sudo tee /usr/local/bin/backup.sh > /dev/null <<EOF

rsync -av --delete /var/log/ /mnt/nfs/var/log/
rsync -av --delete /var/www/ /mnt/nfs/var/www/
rsync -av --delete /var/srv/ /mnt/nfs/var/srv/

EOF

sudo chmod +x /usr/bin/backup.sh

sudo tee -a /var/spool/cron/crontabs/root > /dev/null <<EOF

0 2 * * * /usr/local/bin/backup.sh

EOF

echo "Serveur NFS configuré."

#--------------------------------------Fin du serveur de backup
#--------------------------------------------------------------
