#!/bin/bash

echo "Début du test sur le serveur web."

#Commencer par définir les couleurs pour le message compte-rendu
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

errors=()

#Vérification de l'activation du service apache
if ! systemctl is-active --quiet apache2; then
    errors+=("Il semblerait que le service apache2 ne soit pas actuellement actif.")
fi

#Vérification de l'ouverture du port 80
if ! ss -tln | grep -q ":80 "; then
    erros+=("Le port 80 semble être fermé.")
fi

#Vérification de l'accessibilité du serveur web
if ! curl -s --head http://192.168.0.2 | grep -q "200 OK"; then
    errors+=("Le serveur web ne répond pas correctement (pas de réponse http 200).")
fi

#Compte-rendu
if [ ${#errors[@]} -eq 0 ]; then
    echo -e "${GREEN}Le serveur web fonctionne correctement.${RESET}"
else
    echo -e "${RED}Le serveur web présente des problèmes.${RESET}"
    for err in "${errors[@]}"; do
        echo -e "${RED}- $err${RESET}"
    done
fi

echo "Test sur le serveur web terminé."
