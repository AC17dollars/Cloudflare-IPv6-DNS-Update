#!/bin/bash

set -e

# Config
source "$(dirname "$0")/config.env"

# Current public IPv6 address (global scope)
CURRENT_IP=$(ip -6 a | awk '/inet6/ && /global/ {print $2}' | cut -d'/' -f1 | head -n1)

# Log failed
if [[ -z "$CURRENT_IP" ]]; then
    echo "[$(date)] Failed to retrieve global IPv6 address."
    exit 1
fi

# Check if IP has changed
if [[ -f "$IP_FILE" ]]; then
    LAST_IP=$(cat "$IP_FILE")
    if [[ "$LAST_IP" == "$CURRENT_IP" ]]; then
        echo "[$(date)] IP unchanged ($CURRENT_IP). No update needed."
        exit 0
    fi
fi

# Update DNS record
RESPONSE=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_RECORD_ID" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -d "{
          \"type\": \"$RECORD_TYPE\",
          \"name\": \"$DNS_NAME\",
          \"content\": \"$CURRENT_IP\",
          \"ttl\": $TTL,
          \"proxied\": false
        }")

# Check success
if echo "$RESPONSE" | grep -q '"success":true'; then
    echo "$CURRENT_IP" > "$IP_FILE"
    echo "[$(date)] IP updated to $CURRENT_IP."
else
    echo "[$(date)] Failed to update DNS record."
    echo "Response: $RESPONSE"
    exit 1
fi
