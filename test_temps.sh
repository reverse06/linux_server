#!/bin/bash

#Définition des couleurs pour le compte-rendu
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

errors=()

#Vérification de l'activation du service chronyd

if ! systemctl is-active --quiet chronyd; then
    errors+=("Le service chronyd (NTP) ne semble pas être actif.")
fi

#Vérification de l'ouverture du port NTP (UDP 123)
if ! ss -uln | grep -q ":123" ; then
    errors+=("Il semblerait que le port 123/UDP (NTP) ne soit pas ouvert.")
fi

#Vérification de la synchronisation du temps
if ! chronyc tracking | grep -q "Reference ID"; then
    errors+=("Le serveur NTP ne semble pas synchronisé avec une source de temps.")
fi

#Vérification de la réponse aux requêtes NTP
if ! ntpq -p 127.0.0.1 &>/dev/null; then
    erros+=("Le serveur NTP ne répond pas aux requêtes.")
fi

#Compte-rendu
if [ ${#errors[@]} -eq 0 ]; then
    echo -e "${GREEN}Le serveur NTP fonctionne correctement.${RESET}"
else
    echo -e "${RED}Le serveur NTP présente des problèmes.${RESET}"
    for err in "${errors[@]}"; do
        echo -e "${RED}- $err${RESET}"
    done
fi