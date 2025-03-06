#!/bin/bash

#Définition des couleurs pour le compte-rendu
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

errors=()

#Vérification de l'activation des services postfix et dovecot
for svc in postfix dovecot; do
    if ! systemctl is-active --quiet "$svc"; then
        errors+=("Le service "$svc" n'est pas actif.")
    fi
done

#Vérification de l'ouverture des ports mail
ports=("25" "465" "587" "143" "993")
for port in "${ports[@]}"; do
    if ! ss -tln | grep -q ":$port"; then
        errors+=("Le port $port (mail) n'est pas ouvert.")
    fi
done

#Test d'envoi de mail local
echo "Test mail" | sendmail root
sleep 2 #Attente pour que le mail soit traîté

#Vérification de la réception du mail
if ! mail -H | grep -q "Test mail" && ! doveadmn fetch -u root mailbox INBOX | grep -q "Test mail"; then
    errors+=("L'envoi ou la réception de mail ne fonctionne pas correctement.")
fi

#Compte-rendu
if [ ${#errors[@]} -eq 0 ]; then
    echo -e "${GREEN}Le serveur mail fonctionne correctement.${RESET}"
else
    echo -e "${RED}Le serveur mail présente des problèmes.${RESET}"
    for err in "${errors[@]}"; do
        echo -e "${RED}- $err${RESET}"
    done
fi