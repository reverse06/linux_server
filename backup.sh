#!/bin/bash

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

chmod +x /usr/bin/backup.sh

tee -a /var/spool/cron/crontabs/root > /dev/null <<EOF

0 2 * * * /usr/local/bin/backup.sh

EOF

echo "Backup configurée."

#--------------------------------------Fin du serveur de backup
#--------------------------------------------------------------