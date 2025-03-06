#!/bin/bash

#------------------------------------------------------------------------------------------------------------
# /!\ README /!\
#Ce document est un rassemblage des test unitaires remaniés afin de permettre la pouruite des
#tes sans avoir d'interruption en cas d'erreur. Un message de compte-rendu sera affiché à la fin du test pour
#indiquer lequel des tests unitaires doit être repassé séparément. Ne lancez pas ce script deux fois, 
#cela serait inutile.
#------------------------------------------------------------------------------------------------------------


#----------------------------------------
#----------Début du test sur les services

# Liste des services à vérifier
services=("apache2" "named" "sshd" "postfix" "dovecot" "chronyd")
packages=("apache2" "apache-mod_ssl" "btop" "openssh" "wireshark-qt" "nmap" "nfs-kernel-utils" "nfs-utils" "nfs-client" "bind" "bind-utils" "chrony" "postfix" "dovecot")

errors_serv=()

# Vérification de l'installation des paquets
for pkg in "${packages[@]}"; do
    if ! rpm -q "$pkg" &>/dev/null; then
        errors_serv+=("Paquet non installé : $pkg")
    fi
done

# Vérification de l'activation des services
for svc in "${services[@]}"; do
    if ! systemctl is-active --quiet "$svc"; then
        errors_serv+=("Service non actif : $svc")
    fi
done

#----------Fin du test sur les services
#--------------------------------------


#----------------------------------
#----------Début du test sur le DNS

errors_dns=()

#Commencer par vérifier l'état du service bind (named.service)
if ! systemctl is-active --quiet named; then
    errors_dns+=("Le service bind (named.service) n'est actuellement pas actif.")
fi

#Vérification de la résolution du domaine en local
if ! dig @127.0.0.1 google.com +short | grep -qE "^(1.1.1.1|8.8.8.8)"; then
    errors_dns+=("Les requêtes externes ne semblent pas être redirigées vers 1.1.1.1 ou 8.8.8.8.")
fi

#----------Fin du test sur le DNS
#--------------------------------


#----------------------------------
#----------Début du test sur le web

errors_web=()

#Vérification de l'activation du service apache
if ! systemctl is-active --quiet apache2; then
    errors+=("Il semblerait que le service apache2 ne soit pas actuellement actif.")
fi

#Vérification de l'ouverture du port 80
if ! ss -tln | grep -q ":80 "; then
    errors_web+=("Le port 80 semble être fermé.")
fi

#Vérification de l'accessibilité du serveur web
if ! curl -s --head http://192.168.0.2 | grep -q "200 OK"; then
    errors_web+=("Le serveur web ne répond pas correctement (pas de réponse http 200).")
fi

#----------Fin du test sur le web
#--------------------------------


#-------------------------------------
#----------Début du test sur les mails

errors_mail=()

#Vérification de l'activation des services postfix et dovecot
for svc in postfix dovecot; do
    if ! systemctl is-active --quiet "$svc"; then
        errors_mail+=("Le service "$svc" n'est pas actif.")
    fi
done

#Vérification de l'ouverture des ports mail
ports=("25" "465" "587" "143" "993")
for port in "${ports[@]}"; do
    if ! ss -tln | grep -q ":$port"; then
        errors_mail+=("Le port $port (mail) n'est pas ouvert.")
    fi
done

#Test d'envoi de mail local
echo "Test mail" | sendmail root
sleep 2 #Attente pour que le mail soit traîté

#Vérification de la réception du mail
if ! mail -H | grep -q "Test mail" && ! doveadmn fetch -u root mailbox INBOX | grep -q "Test mail"; then
    errors_mail+=("L'envoi ou la réception de mail ne fonctionne pas correctement.")
fi

#----------Fin du test sur les mails
#-----------------------------------


#------------------------------------
#----------Début du test sur le temps

errors_tmp=()

#Vérification de l'activation du service chronyd

if ! systemctl is-active --quiet chronyd; then
    errors_tmp+=("Le service chronyd (NTP) ne semble pas être actif.")
fi

#Vérification de l'ouverture du port NTP (UDP 123)
if ! ss -uln | grep -q ":123" ; then
    errors_tmp+=("Il semblerait que le port 123/UDP (NTP) ne soit pas ouvert.")
fi

#Vérification de la synchronisation du temps
if ! chronyc tracking | grep -q "Reference ID"; then
    errors_tmp+=("Le serveur NTP ne semble pas synchronisé avec une source de temps.")
fi

#Vérification de la réponse aux requêtes NTP
if ! ntpq -p 127.0.0.1 &>/dev/null; then
    errors_tmp+=("Le serveur NTP ne répond pas aux requêtes.")
fi

#----------Fin du tests sur le temps
#-----------------------------------



################################
#-------------------------------
#----------Début du compte-rendu


#Définition du code couleur
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"


#------------------------------------------------
#----------Début su compte-rendu sur les services
if [ ${#errors_serv[@]} -eq 0 ]; then
    echo -e "${GREEN}Installation et activation des services effectuées avec succès.${RESET}"
else
    echo -e "${RED}Installation et activation des services échouées.${RESET}"
    for err in "${errors_serv[@]}"; do
        echo -e "${RED}- $err${RESET}"
    done
fi
#----------Fin du compte-rendu sur les services
#----------------------------------------------


#------------------------------------------
#----------Début du compte-rendu sur le DNS
if [ ${#errors_dns[@]} -eq 0 ]; then
    echo -e "${GREEN}Le serveur DNS fonctionne correctement.${RESET}"
else
    echo -e "${RED}Le serveur DNS présente des problèmes.${RESET}"
    for err in "${errors_dns[@]}"; do
        echo -e "${RED}- $err${RESET}"
    done
fi
#----------Fin du compte-rendu sur le DNS
#----------------------------------------


#------------------------------------------
#----------Début du compte-rendu sur le web
if [ ${#errors_web[@]} -eq 0 ]; then
    echo -e "${GREEN}Le serveur web fonctionne correctement.${RESET}"
else
    echo -e "${RED}Le serveur web présente des problèmes.${RESET}"
    for err in "${errors_web[@]}"; do
        echo -e "${RED}- $err${RESET}"
    done
fi
#----------Fin du compte-rendu sur le web
#----------------------------------------


#---------------------------------------------
#----------Début du compte-rendu sur les mails
if [ ${#errors_mail[@]} -eq 0 ]; then
    echo -e "${GREEN}Le serveur mail fonctionne correctement.${RESET}"
else
    echo -e "${RED}Le serveur mail présente des problèmes.${RESET}"
    for err in "${errors_mail[@]}"; do
        echo -e "${RED}- $err${RESET}"
    done
fi
#----------Fin du compte-rendu sur les mails
#-------------------------------------------


#--------------------------------------------
#----------Début du compte-rendu sur le temps
if [ ${#errors_tmp[@]} -eq 0 ]; then
    echo -e "${GREEN}Le serveur NTP fonctionne correctement.${RESET}"
else
    echo -e "${RED}Le serveur NTP présente des problèmes.${RESET}"
    for err in "${errors_tmp[@]}"; do
        echo -e "${RED}- $err${RESET}"
    done
fi
#----------Fin du compte-rendu sur le temps
#------------------------------------------


#----------Fin du compte-rendu
#-----------------------------
##############################