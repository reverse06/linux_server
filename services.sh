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
systemctl enable --now chronyd

echo "Services requis démarrés."

#-----------------------------------------------
#-----------Fin du démarrage des services requis