#!/bin/bash

echo "Début du test sur le DNS..."

#Couleurs pour l'affichage des résultats
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

errors=()

#Commencer par vérifier l'état du service bind (named.service)
if ! systemctl is-active --quiet named; then
    errors+=("Le service bind (named.service) n'est actuellement pas actif.")
fi

#Vérification de la résolution du domaine en local
if ! dig @127.0.0.1 google.com +short | grep -qE "^(1.1.1.1|8.8.8.8)"; then
    errors+=("Les requêtes externes ne semblent pas être redirigées vers 1.1.1.1 ou 8.8.8.8.")
fi

#Affichage du résultat final
if [ ${#errors[@]} -eq 0 ] then
    echo -e "${GREEN}Le serveur DNS fonctionne correctement.${RESET}"
else
    echo -e "${RED}Le serveur DNS présente des problèmes.${RESET}"
    for err in "${errors[@]}"; do
        echo -e "{RED}- $err${RESET}"
    done
fi

echo "Test sur le DNS terminé."
