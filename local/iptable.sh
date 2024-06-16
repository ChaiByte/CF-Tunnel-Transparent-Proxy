#!/bin/bash -e

# Because reboot will clear the iptables, so we need to persist the iptables
# Check if iptables-persistent is installed
if ! dpkg -s iptables-persistent >/dev/null 2>&1; then
    # If not installed, install it
    sudo apt-get install -y iptables-persistent
fi

# Define IP ranges as constants
# IP from https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/deploy-tunnels/tunnel-with-firewall/
IP_RANGE1="198.41.192.0/24"
IP_RANGE2="198.41.200.0/24"

# If you change the port, remember to change the listen port in `config.json``
PORT=12306

if [ "$1" = "add" ] || [ "$1" = "a" ]; then
    if ! sudo iptables -t nat -C OUTPUT -d $IP_RANGE1 -p tcp -j REDIRECT --to-ports $PORT 2>/dev/null; then
        sudo iptables -t nat -A OUTPUT -d $IP_RANGE1 -p tcp -j REDIRECT --to-ports $PORT
    fi
    if ! sudo iptables -t nat -C OUTPUT -d $IP_RANGE2 -p tcp -j REDIRECT --to-ports $PORT 2>/dev/null; then
        sudo iptables -t nat -A OUTPUT -d $IP_RANGE2 -p tcp -j REDIRECT --to-ports $PORT
    fi
    sudo iptables -t nat -L OUTPUT -v -n --line-numbers
    sudo netfilter-persistent save
elif [ "$1" = "remove" ] || [ "$1" = "r" ]; then
    sudo iptables -t nat -D OUTPUT -d $IP_RANGE1 -p tcp -j REDIRECT --to-ports $PORT
    sudo iptables -t nat -D OUTPUT -d $IP_RANGE2 -p tcp -j REDIRECT --to-ports $PORT
    sudo iptables -t nat -L OUTPUT -v -n --line-numbers
    sudo netfilter-persistent save
elif [ "$1" = "list" ] || [ "$1" = "l" ]; then
    sudo iptables -t nat -L OUTPUT -v -n --line-numbers
else
    echo "Invalid argument. Please use 'add' or 'remove' or 'list'."
    exit 1
fi