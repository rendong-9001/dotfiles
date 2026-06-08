## Firewall
### Usage
```sh
nft add table inet default # create table
nft add chain inet default INPUT { type filter hook input priority 0 \; policy drop \; } # add chain
nft add rule inet default INPUT tcp dport 22 accept # add rule
nft -a list table inet default # check table
nft insert rule inet default INPUT position 3 tcp dport 636 accept # insert rule
nft delete rule inet default INPUT handle 6 # delete rule
nft flush chain inet default INPUT # delete chain
```
```sh
sudo nft list ruleset | sudo tee /etc/nftables.conf
```
```
table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;
    ct state established,related accept
    iifname "lo" accept
    ip protocol icmp accept
    tcp dport {22, 80, 443} accept
  }

  chain forward {
    type filter hook forward priority 0; policy drop;
  }

  chain output {
    type filter hook output priority 0; policy accept;
  }
}
```
