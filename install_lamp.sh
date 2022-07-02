#!/bin/bash
function lamp {
        clean
        #Install Apache
        echo "Installing Apache"
        yum update -y
        yum install -y wget net-tools
        yum install -y httpd
        systemctl start httpd
        systemctl enable httpd
        systemctl stop firewalld
        systemctl disable firewalld
        echo "Install Apchae done!!!"

        #Install MariaDB
        echo "Installing MariaDB"
        yum install -y mariadb mariadb-server
        systemctl start mariadb
        systemctl enable mariadb
        echo "Install MariaDB done!!!"

        #Install PHP
        echo "Installing PHP8"
        yum install -y yum-utils https://rpms.remirepo.net/enterprise/remi-release-7.rpm
        yum-config-manager --enable remi-php80
        yum install -y php php-ldap php-zip php-embedded php-cli php-mysql php-common php-gd php-xml php-mbstring php-mcrypt php-pdo php-soap php-json php-simplexml php-process php-curl php-bcmath php-snmp php-pspell php-gmp php-intl php-imap perl-LWP-Protocol-https php-pear-Net-SMTP php-enchant php-pear php-devel php-zlib php-xmlrpc php-tidy php-opcache php-cli php-pecl-zip unzip gcc

        #Check PHP
        echo -e "phpinfo() \n<?" > /var/www/html/info.php
        echo "Install PHP done!!!"
}

function wordpress {
        clean
        #Create vHost
        echo "Creating vHost file"
        read -p "enter your doman: " domain
        wget -O /etc/httpd/conf.d/"$domain".conf https://raw.githubusercontent.com/vivi789/WebServer/main/vhost.conf
        sed -i "s|example.com|$domain|" /etc/httpd/conf.d/"$domain".conf
        sed -i "s|error.log|"$domain".error.log|g" /etc/httpd/conf.d/"$domain".conf
        sed -i "s|access.log|"$domain".access.log|g" /etc/httpd/conf.d/"$domain".conf
        touch /var/log/"$domain".error.log
        touch |"$domain".access.log
        mkdir -p /var/www/$domain/public_html/
        systemctl restart httpd > /dev/null

        #Create Database
        echo "Create database"
        read -p "enter database: " database
        read -p "enter user: " user
        read -p "enter password: " pass
        /usr/bin/mysql <<EOF
CREATE DATABASE $database;
CREATE USER '$user'@'localhost' IDENTIFIED BY '$pass';
GRANT ALL PRIVILEGES ON $database.* TO '$user'@'localhost';
EOF
        #Download Wordpress
        echo "Installing Wordpress"
        wget -O /var/www/$domain/public_html/latest.zip https://wordpress.org/latest.zip
        yum install -y unzip
        cd  /var/www/$domain/public_html/ && unzip latest.zip
        mv  /var/www/$domain/public_html/wordpress/*  /var/www/$domain/public_html/
        cd  /var/www/$domain/public_html/&& cp wp-config-sample.php wp-config.php
        sed -i "s|database_name_here|$database|g" wp-config.php
        sed -i "s|username_here|word$user|g" wp-config.php
        sed -i "s|password_here|$password|g" wp-config.php
        echo "This is your information:"
        echo "Root Folder: /var/www/$domain/public_html/"
}
echo "1) Install LAMP"
echo "2) Install Wordpress"
echo "3) Exit"
read -p "choose number: " number
case $number in
        1) lamp;;
        2) wordpress;;
        3) exit;;
esac
