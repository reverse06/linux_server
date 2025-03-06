#!/bin/bash

# Liste des services à vérifier
services=("apache2" "named" "sshd" "postfix" "dovecot" "chronyd")
packages=("apache2" "apache-mod_ssl" "btop" "openssh" "wireshark-qt" "nmap" "nfs-kernel-utils" "nfs-utils" "nfs-client" "bind" "bind-utils" "chrony" "postfix" "dovecot")

# Couleurs pour l'affichage
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

errors=()

# Vérification de l'installation des paquets
for pkg in "${packages[@]}"; do
    if ! rpm -q "$pkg" &>/dev/null; then
        errors+=("Paquet non installé : $pkg")
    fi
done

# Vérification de l'activation des services
for svc in "${services[@]}"; do
    if ! systemctl is-active --quiet "$svc"; then
        errors+=("Service non actif : $svc")
    fi
done

# Affichage final
if [ ${#errors[@]} -eq 0 ]; then
    echo -e "${GREEN}Installation et activation des services effectuées avec succès.${RESET}"
else
    echo -e "${RED}Installation et activation des services échouées.${RESET}"
    for err in "${errors[@]}"; do
        echo -e "${RED}- $err${RESET}"
    done
fi