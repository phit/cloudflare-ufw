#!/bin/sh

curl -s https://www.cloudflare.com/ips-v4 -o /tmp/cf_ips
#curl -s https://www.cloudflare.com/ips-v6 >> /tmp/cf_ips

# clear all rules
for NUM in $(ufw status numbered | grep 80,443/tcp | awk -F"[][]" '{print $2}' | tr --delete [:blank:] | sort -rn); do
    yes | ufw delete $NUM
done

# allow internal traffic
ufw allow proto tcp from 192.168.100.0/24 to any port 80,443

# Allow all traffic from Cloudflare IPs (no ports restriction)
for cfip in `cat /tmp/cf_ips`; do ufw allow proto tcp from $cfip to any port 80,443 comment 'Cloudflare IP'; done

ufw reload > /dev/null
