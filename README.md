# Cloudflare IPv6 DNS Updater

This script automatically updates Cloudflare DNS records with your IPv6 address.

## Installation

1. Copy the DNS updater script and systemd files:
```bash
sudo cp dns-updater.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/dns-updater.sh
sudo cp -r systemd/* /etc/systemd/system/
```

3. Reload systemd and enable the timer:
```bash
sudo systemctl daemon-reexec
sudo systemctl enable --now cloudflare-update.timer
```

## Configuration

Before running the script, copy `config.example.env` to `config.env` and update the configuration with your Cloudflare API credentials and DNS record details.

## Requirements

- bash
- curl
- systemd

## Usage

The script will run automatically via the systemd timer. You can manually run the script using:
```bash
dns-updater.sh
```