#-----------------------------------------------
#---------------------------Début du service SSH

echo "Configuratin du service SSH..."

sudo sed -i 's/^Port 22/Port 2025/' /etc/ssh/sshd_config

sudo systemctl restart sshd

echo "Service SSH configuré. Le port est 2025."

#------------------------------Fin du service SSH
#------------------------------------------------