# Save script
sudo nano /usr/local/bin/vpngate-ovpn
sudo chmod +x /usr/local/bin/vpngate-ovpn

# Create alias
echo 'alias vpn="sudo /usr/local/bin/vpngate-ovpn"' >> ~/.bashrc
source ~/.bashrc

# Use it:
vpn quick          # Quick connect
vpn connect        # Connect to best server
vpn status         # Check status
vpn disconnect     # Disconnect
