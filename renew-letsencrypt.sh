#!/bin/bash

# AudioBookshelf Let's Encrypt Certificate Renewal Script
# This script handles manual renewal of Let's Encrypt certificates

DOMAIN="your-domain.com"
AUDIOBOOKSHELF_DIR="$HOME/audiobookshelf"
SSL_DIR="$AUDIOBOOKSHELF_DIR/ssl"

echo "=== AudioBookshelf Let's Encrypt Renewal Script ==="
echo "Domain: $DOMAIN"
echo "Date: $(date)"
echo ""

# Check current certificate expiration
echo "Current certificate expires:"
openssl x509 -noout -dates -in "$SSL_DIR/books-letsencrypt.crt" | grep notAfter

echo ""
echo "To renew the certificate:"
echo "1. Run: sudo certbot certonly --manual --preferred-challenges dns -d $DOMAIN"
echo "2. Add the DNS TXT record when prompted"
echo "3. After successful renewal, run this script with --update to copy the new certificates"
echo ""

if [ "$1" = "--update" ]; then
    echo "Updating certificates from Let's Encrypt to Docker containers..."
    
    # Copy new certificates
    sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem "$SSL_DIR/books-letsencrypt.crt"
    sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem "$SSL_DIR/books-letsencrypt.key"
    sudo chown $USER:$USER "$SSL_DIR/books-letsencrypt.crt" "$SSL_DIR/books-letsencrypt.key"
    
    # Restart nginx container to pick up new certificates
    cd "$AUDIOBOOKSHELF_DIR"
    docker compose restart nginx
    
    echo "Certificates updated and nginx restarted!"
    echo ""
    echo "New certificate expires:"
    openssl x509 -noout -dates -in "$SSL_DIR/books-letsencrypt.crt" | grep notAfter
else
    echo "Use --update after manual certificate renewal to copy certificates and restart containers"
fi