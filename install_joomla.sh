#!/bin/bash
###############################################################################
# Flowku / rdsproject - Automated Joomla Installation Script
# For use on rdsproject-webserver-2 (Advanced Tier)
#
# This installs Apache, PHP, and downloads Joomla so it's ready for the
# browser-based installer to connect to the existing RDS database.
###############################################################################

set -e  # exit immediately if a command fails

echo "==> Updating package lists..."
sudo apt update -y

echo "==> Installing Apache, PHP, and required PHP extensions..."
sudo apt install -y apache2 php libapache2-mod-php php-mysql php-xml php-curl \
    php-gd php-mbstring php-zip unzip wget

echo "==> Starting and enabling Apache..."
sudo systemctl enable apache2
sudo systemctl start apache2

echo "==> Downloading latest Joomla..."
cd /tmp
wget -q https://downloads.joomla.org/cms/joomla5/latest/Joomla_5-Stable-Full_Package.zip -O joomla.zip

echo "==> Clearing default Apache web root..."
sudo rm -rf /var/www/html/*

echo "==> Extracting Joomla into web root..."
sudo unzip -q joomla.zip -d /var/www/html/

echo "==> Setting ownership and permissions..."
sudo chown -R www-data:www-data /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;

echo "==> Restarting Apache..."
sudo systemctl restart apache2

echo ""
echo "=============================================================="
echo " Joomla files are installed and Apache is running."
echo " Next steps:"
echo "  1. Visit http://<this-instance-public-ip>/ in your browser"
echo "  2. Run through the Joomla installer using the SAME RDS"
echo "     database details as your first instance:"
echo "       Host: rdsproject-db.cyh4yugo6x73.us-east-1.rds.amazonaws.com"
echo "       Username: joomlauser"
echo "       Database Name: joomladb"
echo "     -> NOTE: since joomladb already has tables from instance 1,"
echo "        use a DIFFERENT table prefix on this install (e.g. jos2_)"
echo "        so Joomla doesn't collide with existing tables."
echo "  3. Delete the installation verification file when prompted"
echo "  4. Remove /var/www/html/installation/ after setup completes"
echo "=============================================================="