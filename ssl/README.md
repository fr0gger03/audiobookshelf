# SSL Certificates for AudioBookshelf

This directory contains SSL certificate configuration for the AudioBookshelf deployment.

## Certificate Types

### Self-Signed Certificates
- **Files**: `audiobookshelf.crt`, `audiobookshelf.key`
- **Domains**: Configure for your hostname, IP, and domain
- **Used for**: Local network access
- **Browser behavior**: Shows security warning (expected)

### Let's Encrypt Certificates
- **Files**: `books-letsencrypt.crt`, `books-letsencrypt.key`
- **Domain**: Your domain
- **Used for**: Public internet access
- **Browser behavior**: Trusted, no warnings

## Generating Self-Signed Certificates

To generate new self-signed certificates on your server:

```bash
# Generate private key
openssl genrsa -out ssl/audiobookshelf.key 2048

# Generate certificate using the config
openssl req -new -x509 -key ssl/audiobookshelf.key -out ssl/audiobookshelf.crt -days 365 -config ssl/openssl.conf -extensions v3_req
```

## Renewing Let's Encrypt Certificates

Use the renewal script on your server:
```bash
~/audiobookshelf/renew-letsencrypt.sh
```

## File Permissions
On production server, ensure proper ownership:
```bash
sudo chown $USER:$USER ssl/books-letsencrypt.*
```
