# AudioBookshelf Docker Deployment

This repository contains the Docker Compose configuration and supporting files for deploying AudioBookshelf with an nginx reverse proxy and SSL/TLS certificates.

## Quick Start

```bash
# Clone or download this repository
git clone <repository-url>
cd audiobookshelf

# Generate self-signed certificates for local use
cd ssl
openssl genrsa -out audiobookshelf.key 2048
openssl req -new -x509 -key audiobookshelf.key -out audiobookshelf.crt -days 365 -config openssl.conf -extensions v3_req
cd ..

# Start the services
docker compose up -d

# Check status
docker compose ps
```

## 🌐 Access URLs

### Production (with trusted Let's Encrypt certificate)
- **`https://books.occasional-it.com`** - External access, no browser warnings

### Local Network (with self-signed certificates)
- **`https://rpi4.local:8443`** - Local hostname access
- **`https://192.168.6.125:8443`** - Direct IP access

*Note: Self-signed certificates will show browser security warnings - this is expected and safe for local use.*

## Services

### AudioBookshelf
- **Container**: `audiobookshelf`
- **Image**: `ghcr.io/advplyr/audiobookshelf:latest`
- **Internal Port**: 80
- **Health Check**: `wget --spider -q http://localhost:80`
- **Data Volumes**:
  - `./data/config` → `/config`
  - `./data/metadata` → `/metadata`
  - `./data/audiobooks` → `/audiobooks`
  - `./data/podcasts` → `/podcasts`

### nginx Reverse Proxy
- **Container**: `audiobookshelf-nginx`
- **Image**: `nginx:alpine`
- **External Ports**: 
  - `192.168.6.125:8080:80` (HTTP - redirects to HTTPS)
  - `192.168.6.125:8443:443` (HTTPS)
- **Features**:
  - Dual certificate setup (Let's Encrypt + Self-signed)
  - WebSocket/Socket.IO support for real-time features
  - HTTP to HTTPS redirects
  - Static asset caching with 24h expiration
  - Gzip compression
  - Modern security headers (HSTS, XSS protection, etc.)
  - HTTP/2 support

## 🔐 SSL Certificate Configuration

### Self-Signed Certificates (Local)
- **Files**: `ssl/audiobookshelf.crt`, `ssl/audiobookshelf.key`
- **Domains**: `rpi4.local`, `192.168.6.125`, `books.occasional-it.com`
- **Expires**: ~1 year from generation
- **Used for**: Local network access (`rpi4.local:8443`, `192.168.6.125:8443`)

### Let's Encrypt Certificates (Production)
- **Files**: `ssl/books-letsencrypt.crt`, `ssl/books-letsencrypt.key`
- **Domain**: `books.occasional-it.com`
- **Expires**: December 30, 2025
- **Used for**: Public internet access (`https://books.occasional-it.com`)
- **Renewal**: Manual DNS challenge required

## Configuration

### Environment Variables
- `TZ=America/Toronto` - Timezone for the AudioBookshelf container
- `PORT=80` - Internal port for AudioBookshelf

### Volume Structure
```
audiobookshelf/
├── data/
│   ├── config/          # AudioBookshelf configuration
│   ├── metadata/        # Book/podcast metadata
│   ├── audiobooks/      # Audiobook files
│   └── podcasts/        # Podcast files
├── ssl/                 # SSL certificates
│   ├── audiobookshelf.crt      # Self-signed certificate
│   ├── audiobookshelf.key      # Self-signed private key
│   ├── books-letsencrypt.crt   # Let's Encrypt certificate
│   ├── books-letsencrypt.key   # Let's Encrypt private key
│   ├── openssl.conf            # OpenSSL config for self-signed certs
│   └── README.md               # Certificate documentation
├── docker-compose.yml
├── nginx.conf
└── renew-letsencrypt.sh        # Certificate renewal helper
```

## 🔄 Certificate Management

### Generating Self-Signed Certificates
```bash
cd ssl
# Generate private key
openssl genrsa -out audiobookshelf.key 2048

# Generate certificate with multiple domains/IPs
openssl req -new -x509 -key audiobookshelf.key -out audiobookshelf.crt -days 365 -config openssl.conf -extensions v3_req
```

### Renewing Let's Encrypt Certificates
```bash
# Check expiration (runs on rpi4)
./renew-letsencrypt.sh

# Manual renewal process:
# 1. Run DNS challenge
sudo certbot certonly --manual --preferred-challenges dns -d books.occasional-it.com

# 2. Add DNS TXT record via WordPress.com
# 3. Update certificates after successful renewal
./renew-letsencrypt.sh --update
```

## Management Commands

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f

# Update containers
docker compose pull
docker compose up -d

# Restart nginx (after config/certificate changes)
docker compose restart nginx

# Check nginx configuration
docker exec audiobookshelf-nginx nginx -t
```

## 🌐 Network Configuration

### Docker Network
- **Name**: `audiobookshelf-network` (bridge)
- **Internal communication**: `audiobookshelf:80` → nginx upstream
- **External access**: Only nginx ports exposed to host

### Port Mapping
- **Host**: `192.168.6.125:8080` → Container: `80` (HTTP)
- **Host**: `192.168.6.125:8443` → Container: `443` (HTTPS)
- **NAT**: External `443` → Internal `8443` (configured at firewall level)

## 🔍 Health Checks

### AudioBookshelf Health Check
- **Method**: `wget --spider -q http://localhost:80`
- **Interval**: 30s, Timeout: 10s, Retries: 3, Start Period: 40s

### nginx Health Check
- **Method**: `curl -f http://localhost:80/health`
- **Interval**: 30s, Timeout: 5s, Retries: 3
- **Dependency**: nginx waits for audiobookshelf to be healthy

## 🛡️ Security Features

- **HTTP to HTTPS redirects** (except `/health` endpoint)
- **Modern TLS** (TLS 1.2/1.3 only)
- **Security Headers**:
  - `Strict-Transport-Security: max-age=31536000; includeSubDomains`
  - `X-Frame-Options: SAMEORIGIN`
  - `X-XSS-Protection: 1; mode=block`
  - `X-Content-Type-Options: nosniff`
  - `Referrer-Policy: no-referrer-when-downgrade`
- **Network isolation** via custom Docker network
- **Strong cipher suites** and modern SSL configuration

## 🔧 Troubleshooting

### Container Issues
```bash
# Check container status
docker compose ps

# View detailed logs
docker compose logs audiobookshelf
docker compose logs nginx

# Check nginx configuration
docker exec audiobookshelf-nginx nginx -t
```

### Certificate Issues
```bash
# Test HTTPS connectivity
curl -k -I https://192.168.6.125:8443/
curl -I https://books.occasional-it.com/

# Verify certificate details
openssl x509 -in ssl/audiobookshelf.crt -text -noout
openssl x509 -in ssl/books-letsencrypt.crt -text -noout

# Check certificate expiration
openssl x509 -in ssl/books-letsencrypt.crt -noout -dates
```

### Permission Issues
```bash
# Fix data directory permissions
sudo chown -R $(id -u):$(id -g) data/

# Fix SSL certificate permissions (on rpi4)
sudo chown fr0gger03:fr0gger03 ssl/books-letsencrypt.*
```

### Network Connectivity
```bash
# Test internal container communication
docker exec audiobookshelf-nginx wget -qO- http://audiobookshelf:80

# Check port bindings
sudo ss -tuln | grep ":8080\|:8443"
```

---

**Production Status**: ✅ Active  
**Let's Encrypt Certificate**: Expires December 30, 2025  
**Last Updated**: October 1, 2025
