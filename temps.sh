#!/bin/bash

#--------------------------------------------------------------
#----------------------------------------Début du serveur temps

echo "Configuration du serveur temps..."

sudo tee /etc/chrony.conf > /dev/null <<EOF
server 0.pool.ntp.org iburst
server 1.pool.ntp.org iburst

allow 192.168.0.0/24  # Autorise le réseau local à interroger ce serveur

EOF

systemctl restart chronyd

echo "Serveur temps configuré."

#------------------------------------------Fin du serveur temps
#--------------------------------------------------------------