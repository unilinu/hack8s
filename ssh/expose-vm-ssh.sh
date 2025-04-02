iptables -t nat -A PREROUTING -p tcp --dport 2222 -j DNAT --to-destination 192.168.49.2:22
#iptables -A FORWARD -p tcp -d 192.168.49.2 --dport 22 -j ACCEPT
#iptables -t nat -A POSTROUTING -s 192.168.49.2 -j MASQUERADE

#%s/192.168.49.2//g
