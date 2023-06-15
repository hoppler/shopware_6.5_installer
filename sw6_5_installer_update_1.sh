#!/bin/bash

### This script has been written by Torsten Schuermann which is the copyright holder.
### If you want to support my work please consider a donation.
### My paypal mail address is: schuermann69@mein.gmx

### Declare variables
download_shopware_installer="https://github.com/shopware/web-installer/releases/latest/download/shopware-installer.phar.php"
filename="shopware-installer.phar.php"
ipaddress=$(hostname -I | awk '{print $1}')

# Function to display error messages
show_error() {
  whiptail --msgbox --title "Error" "$1" 8 50
}

# Function to clear the screen
clear_screen() {
  clear
}

# Function to display information messages
show_info() {
  whiptail --msgbox --title "Info" "$1" 12 50
}

# Function to install required programs (Part 1)
install_part_1() {
  # Ask for database name
  if [ "$language" = "en" ]; then
    dbname=$(whiptail --inputbox "Enter the database name:" 8 50 3>&1 1>&2 2>&3)
  else
    dbname=$(whiptail --inputbox "Geben Sie den Datenbanknamen ein:" 8 50 3>&1 1>&2 2>&3)
  fi

  # Set default database name if empty
  if [ -z "$dbname" ]; then
    dbname="shopware"
    if [ "$language" = "en" ]; then
      show_info "Database name set to default value 'shopware'."
    else
      show_info "Datenbankname auf den Standardwert 'shopware' gesetzt."
    fi
  fi

  # Ask for database password
  while true; do
    pass1=$(whiptail --passwordbox "Enter the database password:" 8 50 3>&1 1>&2 2>&3)
    pass2=$(whiptail --passwordbox "Confirm the database password:" 8 50 3>&1 1>&2 2>&3)

    if [ "$pass1" == "$pass2" ]; then
      passer="$pass1"
      break
    else
      if [ "$language" = "en" ]; then
        show_error "Passwords do not match. Please try again."
      else
        show_error "Passwoerter stimmen nicht ueberein. Bitte versuchen Sie es erneut."
      fi
    fi
  done

  # Set default password if empty
  if [ -z "$passer" ]; then
    passer="root"
    if [ "$language" = "en" ]; then
      show_info "Password set to default value 'root'."
    else
      show_info "Passwort auf den Standardwert 'root' gesetzt."
    fi
  fi

  # Ask for domain name
  if [ "$language" = "en" ]; then
    domainname=$(whiptail --inputbox "Enter your domain name (e.g., example.com):" 8 50 3>&1 1>&2 2>&3)
  else
    domainname=$(whiptail --inputbox "Geben Sie Ihre Domain ein (z.B.: example.com):" 8 50 3>&1 1>&2 2>&3)
  fi

  # Set default domain name if empty
  if [ -z "$domainname" ]; then
    domainname="example.com"
    if [ "$language" = "en" ]; then
      show_info "Domain name set to default value 'example.com'."
    else
      show_info "Domainname auf den Standardwert 'example.com' gesetzt."
    fi
  fi

  # Check if the user is sudo
  if [ "$(id -u)" -ne 0 ]; then
    if [ "$language" = "en" ]; then
      show_error "This script requires root privileges. Please run it with sudo."
    else
      show_error "Dieses Skript erfordert Root-Rechte. Bitte fuehren Sie es mit sudo aus."
    fi
    return 1
  fi

  # Update repository and install required programs
  apt update
  apt install -y unzip nginx php8.1-fpm php8.1-mysql php8.1-curl php8.1-gd php8.1-xml php8.1-zip php8.1-opcache php8.1-mbstring php8.1-intl php8.1-cli mysql-server-8.0 > /dev/null

  # Create the database
  mysql -u root -e "drop database if exists $dbname; create database $dbname; Drop USER if exists '$dbname'@'localhost'; CREATE USER '$dbname'@'localhost' IDENTIFIED BY '$passer';GRANT ALL PRIVILEGES ON $dbname.* TO '$dbname'@'localhost';" > /dev/null

  # Adjust PHP configuration
  sed -i '/memory_limit*/c\memory_limit = 1024M' /etc/php/8.1/fpm/php.ini
  sed -i '/post_max_size*/c\post_max_size = 128M' /etc/php/8.1/fpm/php.ini
  sed -i '/upload_max_filesize*/c\upload_max_filesize = 32M' /etc/php/8.1/fpm/php.ini

  systemctl restart php8.1-fpm
  systemctl enable php8.1-fpm
  rm -f /etc/nginx/sites-enabled/default

  # Configure Nginx
  cat << 'EOF' > "/etc/nginx/sites-enabled/default"
  server {
      listen 80;

      # Redirect / to index.php
      index index.php;

      # Our server name
      server_name $domainname;

      # Should be equal to the value of post_max_size
      client_max_body_size 128M;

      # Directory with the code
      root /var/www/html/public;

      location /recovery/update/ {
          location /recovery/update/assets {
          }
          if (!-e $request_filename){
              rewrite . /recovery/update/index.php last;
          }
      }

      # Pass all non-existing files to index.php. Enables nice URLs like /homemade-products/
      location / {
          try_files $uri /index.php$is_args$args;
      }

      # Process .php files with php-fpm
      location ~ ^/(index|shopware-installer\.phar)\.php(/|$) {
          fastcgi_split_path_info ^(.+\.php)(/.+)$;
          include fastcgi.conf;
          fastcgi_param HTTP_PROXY "";
          fastcgi_buffers 8 16k;
          fastcgi_buffer_size 32k;
          fastcgi_read_timeout 300s;
          client_body_buffer_size 128k;
          fastcgi_pass unix:/run/php/php8.1-fpm.sock;
      }
  }
EOF

  systemctl restart nginx
  systemctl enable nginx

  cd /var/www/html
  rm index.nginx-debian.html

  mkdir public
  chmod 777 public
  cd public
  wget "$download_shopware_installer"
  chmod 755 "$filename"

  clear_screen

  if [ "$language" = "en" ]; then
    show_info "Please run the following command in your browser: $ipaddress/$filename\n\nWait for 'File not found.' and then proceed with Part 2."
  else
    show_info "Bitte fuehren Sie den folgenden Befehl in Ihrem Browser aus: $ipaddress/$filename\n\nWarten Sie auf 'File not found.' und starten Sie dann Teil 2."
  fi
}

# Function for installing Shopware (Part 2)
correct_error() {
  cd /var/www/html
  chown -R www-data:www-data .

  clear_screen

  if [ "$language" = "en" ]; then
    show_info "Error should be corrected now.\nPlease refresh page in browser"
  else
    show_info "Der Fehler sollte nun behoben sein.\nBitte die Seite im Browser auffrischen."
  fi
}


# Function for installing Shopware (Part 2)
install_part_2() {
  cd /var/www/html
  chmod -R 755 public
  mv public/ install/
  cd install
  shopt -s dotglob
  mv -- * /var/www/html
  rm -rf install
  chown -R www-data:www-data .

  clear_screen

  if [ "$language" = "en" ]; then
    show_info "Part 2 has been completed.\n\nPlease visit $ipaddress in your browser to finish the installation."
  else
    show_info "Teil 2 ist abgeschlossen.\n\nBitte rufen Sie $ipaddress in Ihrem Browser auf, um die Installation abzuschliessen."
  fi
}

# Function for uninstalling Shopware
uninstall_shopware() {
  if [ "$language" = "en" ]; then
    if (whiptail --title "Confirmation" --yesno "Are you sure you want to uninstall Shopware?" 8 50) then
      rm -rf /var/www/html/*
      show_info "Shopware has been uninstalled."
    else
      return 0
    fi
  else
    if (whiptail --title "Bestaetigung" --yesno "Moechten Sie Shopware wirklich deinstallieren?" 8 50) then
      rm -rf /var/www/html/*
      show_info "Shopware wurde deinstalliert."
    else
      return 0
    fi
  fi
}


# Parse command-line options
while getopts "e" opt; do
  case $opt in
    e)
      language="en"
      ;;
    *)
      ;;
  esac
done


# Main menu
while true; do
  clear_screen

  if [ -f "/var/www/html/public/composer.lock" ]; then
    if [ "$language" = "en" ]; then
      choice=$(whiptail --title "Shopware Installation" --menu "Select an option:" 12 50 3 \
        "2" "Install Shopware (Part 2)" \
        "u" "Uninstall Shopware" \
        "e" "Exit" 3>&1 1>&2 2>&3)
    else
      choice=$(whiptail --title "Shopware Installation" --menu "Waehlen Sie eine Option aus:" 12 50 3 \
        "2" "Shopware installieren (Teil 2)" \
        "u" "Shopware deinstallieren" \
        "e" "Beenden" 3>&1 1>&2 2>&3)
    fi
  fi 

  if [ -f "/var/www/html/composer.lock" ]; then
    if [ "$language" = "en" ]; then
      choice=$(whiptail --title "Shopware Installation" --menu "Select an option:" 12 50 4 \
        "u" "Uninstall Shopware" \
	"c" "Correct Eorrr '.'" \
        "e" "Exit" 3>&1 1>&2 2>&3)
    else
      choice=$(whiptail --title "Shopware Installation" --menu "Waehlen Sie eine Option aus:" 12 50 4 \
        "u" "Shopware deinstallieren" \
	"c" "'.' Fehler beheben" \
        "e" "Beenden" 3>&1 1>&2 2>&3)
    fi
  fi
  if [ ! -d "/var/www/html/public" ]; then
    if [ "$language" = "en" ]; then
      choice=$(whiptail --title "Shopware Installation" --menu "Select an option:" 12 50 4 \
        "1" "Install Shopware (Part 1)" \
        "e" "Exit" 3>&1 1>&2 2>&3)
    else
      choice=$(whiptail --title "Shopware Installation" --menu "Waehlen Sie eine Option aus:" 12 50 4 \
        "1" "Shopware installieren (Teil 1)" \
        "e" "Beenden" 3>&1 1>&2 2>&3)
    fi
  fi

  case $choice in
    1)
      install_part_1
      ;;
    2)
      install_part_2
      ;;
    u)
      uninstall_shopware
      ;;
    c)
      correct_error
      ;;

    e)
      break
      ;;
  esac
done
