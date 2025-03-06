#!/bin/bash

#--------------------------------------------------------------
#------------------------------------------Début du serveur web

echo "Configuration du serveur web..."

sudo tee /etc/apache2/vhosts.d/site.local.conf > /dev/null <<EOF

<VirtualHost *:80>
    ServerName site.local
    ServerAlias www.site.local
    DocumentRoot /var/www/site.local

    <Directory /var/www/site.local>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /var/log/apache2/site.local-error.log
    CustomLog /var/log/apache2/site.local-access.log combined
</VirtualHost>

EOF

a2ensite site.local
systemctl restart apache2

mkdir -p /var/www/site.local
echo "<h1>Test réussi !</h1>" > /var/www/site.local/index.html
chown -R wwwrun:www /var/www/site.local
chmod -R 755 /var/www/site.local

systemctl restart apache2

echo "Serveur web configuré."

#--------------------------------------------Fin du serveur web
#--------------------------------------------------------------