# SSL Certificates for AudioBookshelf

This directory contains SSL certificate configuration for the AudioBookshelf deployment.

## Certificate Types

### Self-Signed Certificates
- **Files**: `audiobookshelf.crt`, `audiobookshelf.key`
- **Domains**: `rpi4.local`, `192.168.6.125`, `books.occasional-it.com`
- **Used for**: Local network access
- **Browser behavior**: Shows security warning (expected)

### Let's Encrypt Certificates
- **Files**: `books-letsencrypt.crt`, `books-letsencrypt.key`
- **Domain**: `books.occasional-it.com`
- **Used for**: Public internet access
- **Browser behavior**: Trusted, no warnings
- **Expires**: December 30, 2025

## Generating Self-Signed Certificates

To generate new self-signed certificates on rpi4:

```bash
# Generate private key
openssl genrsa -out ssl/audiobookshelf.key 2048

# Generate certificate using the config
openssl req -new -x509 -key ssl/audiobookshelf.key -out ssl/audiobookshelf.crt -days 365 -config ssl/openssl.conf -extensions v3_req
```

## Renewing Let's Encrypt Certificates

Use the renewal script on rpi4:
```bash
/home/fr0gger03/renew-letsencrypt.sh
```

## File Permissions
On production rpi4, ensure proper ownership:
```bash
sudo chown fr0gger03:fr0gger03 ssl/books-letsencrypt.*
```