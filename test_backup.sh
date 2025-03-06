#!/bin/bash

echo "Début du test unitaire sur la backup..."

#Définition des couleurs pour le compte-rendu
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

#Définition des variables
SOURCE="/var/www"
BACKUP_DIR="/tmp/backup_test"
BACKUP_FILE="/tmp/backup_www.tar.gz"
RESTORE_DIR="/tmp/www_restored"

#Vérifier si le dossier source existe
if [ ! -d "$SOURCE" ]; then
    echo -e "${RED}Le dossier source $SOURCE n'existe pas.${RESET}"
    echo "Test unitaire sur la backup terminé pour cause d'échec."
    exit 1
fi

#Création d'une copie temporaire pour le test
echo "Création d'une copie temporaire de $SOURCE..."
cp -a "$SOURCE" "$BACKUP_DIR"

#Vérification de la copie
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}Échec de la copie temporaire.${RESET}"
    echo "Test unitaire sur la backup terminé pour cause d'échec."
    exit 1
fi

#Sauvegarde de la copie
echo "Réalisation de la sauvegarde test."
tar -czf "$BACKUP_FILE" -C "$BACKUP_DIR" .

#Vérification de la sauvegarde
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}Échec de la création de la sauvegarde.${RESET}"
    echo "Test unitaire sur la backup terminé."
    exit 1
fi

#Suppression de la copie temporaire
echo "Suppression de la copie temporaire..."
rm -rf "$BACKUP_DIR"

#Vérification de la suppression de la copie temporaire
if [ -d "$BACKUP_DIR" ]; then
    echo -e "${RED}Échec de la suppression de la copie temporaire.${RESET}"
    echo "Test unitaire sur la backup terminé pour cause d'échec."
    exit 1
fi

#Restauration de la sauvegarde
echo "Restauration de la sauvegarde..."
mkdir -p "$RESTORE_DIR"
tar -xzf "$BACKUP_FILE" -C "$RESTORE_DIR"

#Vérification de la restauration
if [ ! "$(ls -A "$RESTORE_DIR")" ]; then
    echo -e "${RED}Échec de la restauration des fichiers.${RESET}"
    echo "Test unitaire sur la backup terminé pour cause d'échec."
    exit 1
fi

#Compte-rendu
echo -e "${GREEN}Si vous êtes arrivé jusqu'ici, c'est que le test a été passé avec succès!.${RESET}"

echo "Test unitaire sur la backup terminé."
