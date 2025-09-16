# VPN Gate for Linux (Ubuntu)

Follow the guide to use.

## Save script

```sudo nano /usr/local/bin/vpngate-ovpn```

```sudo chmod +x /usr/local/bin/vpngate-ovpn```

## Create alias

```echo 'alias vpn="sudo /usr/local/bin/vpngate-ovpn"' >> ~/.bashrc```

```source ~/.bashrc```

## Use it

```vpn quick```          # Quick connect

```vpn connect```        # Connect to best server

```vpn status```         # Check status

```vpn disconnect```     # Disconnect

## Download and connect to first available server

```wget -q -O /tmp/vpngate.ovpn "https://www.vpngate.net/common/openvpn_download.aspx?sid=1&udp=1" && sudo openvpn --config /tmp/vpngate.ovpn --daemon```

## Get server list and manually pick

```curl -s "https://www.vpngate.net/api/iphone/" | tail -n +2 | head -10 | cut -d',' -f2,6 | column -t -s','```
