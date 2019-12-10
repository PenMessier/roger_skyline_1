#!/bin/bash

## Reset tables configurations
#
echo "📦  Reset tables configurations"

# Flush all rules
echo "   -- Flush iptable rules"
sudo iptables -F
sudo iptables -F -t nat
sudo iptables -F -t mangle
sudo iptables -F -t raw
# Erase all non-default chains
echo "   -- Erase all non-default chains"
sudo iptables -X
sudo iptables -X -t nat
sudo iptables -X -t mangle
sudo iptables -X -t raw


## Trafic configurations
#
echo "⚙️  Trafic configurations"
# Block all traffic by default
echo "   -- Block all traffic by default"
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT
echo "   -- Allow all and everything on localhost"
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
# Allow established connections TCP
echo "   -- Allow established connections TCP"
sudo iptables -A INPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
# Allow established connections UDP
echo "   -- Allow established connections UDP"
sudo iptables -A INPUT -p udp -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -p udp -m state --state ESTABLISHED,RELATED -j ACCEPT
# Allow pings
echo "   -- Allow output pings"
sudo iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT
# Allow SSH connection on 69 port
echo "   -- Allow SSH connection on 50150 port"
sudo iptables -A INPUT -p tcp --dport 50150 -j ACCEPT
# Allow HTTP
echo "   -- Allow HTTP"
sudo iptables -t filter -A OUTPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
# Allow HTTPS
echo "   -- Allow HTTPS"
sudo iptables -t filter -A OUTPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 443 -j ACCEPT


## Mail configurations
#
echo "✉️  Mail configurations"
# Allow SMTP
echo "   -- Allow SMTP"
sudo iptables -t filter -A INPUT -p tcp --dport 25 -j ACCEPT
sudo iptables -t filter -A OUTPUT -p tcp --dport 25 -j ACCEPT
# Allow POP3
echo "   -- Allow POP3"
sudo iptables -t filter -A INPUT -p tcp --dport 110 -j ACCEPT
sudo iptables -t filter -A OUTPUT -p tcp --dport 110 -j ACCEPT
# Allow IMAP
echo "   -- Allow IMAP"
sudo iptables -t filter -A INPUT -p tcp --dport 143 -j ACCEPT
sudo iptables -t filter -A OUTPUT -p tcp --dport 143 -j ACCEPT
# Allow POP3S
echo "   -- Allow POP3S"
sudo iptables -t filter -A INPUT -p tcp --dport 995 -j ACCEPT
sudo iptables -t filter -A OUTPUT -p tcp --dport 995 -j ACCEPT


## DDoS protections
#
echo "🛡  DDoS protetion"

# Synflood protection
echo "   -- Synflood protection"
sudo /sbin/iptables -A INPUT -p tcp --syn -m limit --limit 2/s --limit-burst 30 -j ACCEPT
# Pingflood protection
echo "   -- Pingflood protection"
sudo /sbin/iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
# Port scanning protection
echo "   -- Port scanning protection"
sudo /sbin/iptables -A INPUT -p tcp --tcp-flags ALL NONE -m limit --limit 1/h -j ACCEPT
sudo /sbin/iptables -A INPUT -p tcp --tcp-flags ALL ALL -m limit --limit 1/h -j ACCEPT


## Save the tables configuration
#
# sudo iptables-save > /etc/iptables/rules.v4
