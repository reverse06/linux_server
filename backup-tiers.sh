#!/bin/bash

#Ceci est le script de config qui servira au second serveur, celui qui
#est censé accueillir les backups et les compresser.

echo "Début de la configuration des backups sur le serveur tiers."

# Configuration du serveur de sauvegarde
BACKUP_DIR="/backups"
EXPORT_FILE="/etc/exports"

# Création du dossier de sauvegarde
sudo mkdir -p $BACKUP_DIR
sudo chmod 777 $BACKUP_DIR

# Configuration de NFS
if ! grep -q "$BACKUP_DIR" $EXPORT_FILE; then
    echo "$BACKUP_DIR 192.168.0.0/24(rw,sync,no_subtree_check)" | sudo tee -a $EXPORT_FILE
    sudo exportfs -ra
    sudo systemctl restart nfs-server
fi

# Script de gestion des sauvegardes
MANAGE_BACKUPS="/usr/local/bin/manage_backups.sh"
sudo tee $MANAGE_BACKUPS > /dev/null <<EOF
#!/bin/bash
DATE=\$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE_DIR="$BACKUP_DIR/\$DATE"
mkdir -p "\$ARCHIVE_DIR"

# Déplacer les nouvelles données vers un dossier daté
mv $BACKUP_DIR/var/log "\$ARCHIVE_DIR/"
mv $BACKUP_DIR/var/www "\$ARCHIVE_DIR/"
mv $BACKUP_DIR/var/srv "\$ARCHIVE_DIR/"

# Compression des sauvegardes
cd "$BACKUP_DIR" && tar -czf "\$DATE.tar.gz" "\$DATE" && rm -rf "\$ARCHIVE_DIR"
EOF

sudo chmod +x $MANAGE_BACKUPS

# Configuration d'un cron job pour gérer les sauvegardes quotidiennement
(crontab -l ; echo "0 2 * * * $MANAGE_BACKUPS") | crontab -

echo "Configuration des backups sur le serveur tiers terminée."
