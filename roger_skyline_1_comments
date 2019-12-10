#Login through terminlal:
ssh frenna@127.0.0.1 -p 22322

##################################################################################
## Resize disk size to 8GB

# From host machine terminal:
cd VirtualBox\ VMs/frenna_init/
# Show existing size:
VBoxManage showhdinfo frenna_init.vdi
# Resize (to a larger size only):
VBoxManage modifyhd --resize 8192 frenna_init.vdi

#Create disk partition:
#switch to command mode:
fdisk /dev/sda
#Create a new primary partition n , p
#View partition table:
fdisk -l or lsblk

##################################################################################

### Network and Security part

## Enable sudo on user account: 
/sbin/adduser frenna sudo

## Configure static IP and netmask /30:
#Change in VM settings Network NAT to Bridged adapter with name en0: ethernet
# On host machine find ip address of en0 
ifconfig | grep en0
## 192.168.21.63 host ip
# Check if we can ping the ip on host:
ping 192.168.21.61 -c4

# Assign static ip of a guest machine from the same range as host ip with netmask /30.
# Edit file
nano /etc/network/interfaces:
# The primary network interface
allow-hotplug enp0s3
# iface enp0s3 inet dhcp
auto enp0s3
iface enp0s3 inet static
			address 192.168.21.61
			netmask 255.255.255.252
			geteway 10.0.2.2

#View netmask and getaway:
route -n
#View ip:
ip addr

systemctl restart networking
#or service networking restart

## Change default port of the ssh
# change Configuration file:
nano /etc/ssh/sshd_config
port 50150

# Connect on host machine via ssh
ssh frenna@192.168.21.61 -p50150

## Setup SSH with public keys

# Generate a pair of keys on a host machine:
ssh-keygen -t rsa

# Copy public key on a guest machine:
ssh-copy-id -i .ssh/id_rsa.pub -p 50150 frenna@192.168.21.61

# Edit /etc/ssh/sshd_config file:
Line: #PermitRootLogin prohibit-password - PermitRootLogin no
Line: #PasswordAuthentication yes - PasswordAuthentication no
Line: PublickeyAuthentication yes

# Firewall

# Setup ufw(Uncomplicated Firewall) sudo apt install ufw
# Check ufw status: sudo ufw status
# Enable ufw: sudo ufw enable
# Security policies is in file /etc/default/ufw

#Setup rules:
sudo ufw allow 50150/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443

#Show rules:
ufw status numbered


## DOS (Denial of Service Attack)
## Scans protection
sh iptables.sh

# Show iptables rules:
sudo iptables -S

## Stop services you don't need for this project:

# List all services:
sudo service --status-all

# Stop services:
sudo service <service> stop

## Create a script that updates all the sources of package:
update.sh

# Create a scheduled task for this script once a week at 4AM and every time the machine reboots:
crontab -e

# Add in file:
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin

@reboot sudo ~/update.sh
0 4 * * 6 sudo ~/update.sh

## Make a script to monitor changes of the /etc/crontab file 
## and sends an email to root if it has been modified.
## Create a scheduled script task every day at midnight.

# Create file cron_monitor.sh

crontab -e
0 0 * * * sudo ~/cron_monitor.sh

##################################################################################

### Set a web server

# switch to NAT in Network settings of VM
# Connect via ssh with localhost 127.0.0.1
# Update existing repositories:
sudo apt update -y

# Install Apache on debian:
sudo apt install apache2 -y

# Check apache server status:
sudo systemctl status apache2
# enable Apache Web server on boot execute the command: sudo systemctl enable apache2

# Switch to bridged adapter in Network settings of VM
# Connect via ssh with static ip
## Firewall settings (optional):
# Check ufw status sudo ufw status and 
# allow http port, so extarnal users can reach web server:
# sudo allow 80/tcp

# Check active connections:
sudo netstat -pnltu

# Open browser and connect to apache server:
#/var/www/html
http://static-ip

##################################################################################

## Self signed SSL creation:
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout
 /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt

## Modify our Apache configuration:
# Create a new snippet in the /etc/apache2/conf-available:
sudo nano /etc/apache2/conf-available/ssl-params.conf

# Modifying the Default Apache SSL Virtual Host File:
sudo nano /etc/apache2/sites-available/default-ssl.conf
# Add line:
ServerName 192.168.21.61

# Edit lines:
SSLCertificateFile      /etc/ssl/certs/apache-selfsigned.crt
SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key

# Modifying the HTTP Host File to Redirect to HTTPS
sudo nano /etc/apache2/sites-available/000-default.conf
# Add line:
Redirect "/" "https://192.168.21.61/"

# Enabling the Changes in Apache:
sudo a2enmod ssl
sudo a2enmod headers
sudo a2ensite default-ssl
sudo a2enconf ssl-params
sudo apache2ctl configtest

# Changing to a Permanent Redirect
sudo nano /etc/apache2/sites-available/000-default.conf
# Edit line:
Redirect permanent "/" "https://192.168.21.61/"

##################################################################################

# Make backup file for index.html
sudo mv /var/www/html/index.html /var/www/html/index.html.bak

# Create a new index.html

##################################################################################

### Deployment part

# Create project folder on host machine and initialize as git repo:
~/Desctop/social_studies_quiz
git init
git commit -q -m ".."

# Install git on vm
# Initialize empty Git repository ~/deploy.git
git init --bare

# Create file ~/deploy.git/hooks/post-receive, add lines:
#!/bin/sh
GIT_WORK_TREE=/var/www/html git checkout -f

# Add rights:
chmod +x hooks/post-receive

# On host machine
git remote add web ssh://frenna@192.168.21.61:50150/~/deploy.git
git push web +master:refs/heads/master

# To check, if remote repo was added
git remote -v
