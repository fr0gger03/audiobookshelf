# Security Configuration

This repository contains configuration files for AudioBookshelf deployment. To protect sensitive information:

## Before Deployment

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Update `.env` with your actual values:**
   - `SERVER_IP` - Your server's IP address
   - `DOMAIN_NAME` - Your domain name
   - `HTTP_PORT` and `HTTPS_PORT` - Your port numbers
   - `TZ` - Your timezone

3. **Create actual configuration files from templates:**
   ```bash
   # Update docker-compose.yml with values from .env
   # Update nginx.conf by replacing placeholders in nginx.template.conf
   ```

4. **Generate SSL certificates** (see `ssl/README.md`)

## Protected Files

The following are excluded from version control via `.gitignore`:

- `data/` - Contains user content and application data
- `ssl/*.crt`, `ssl/*.key` - SSL certificates and private keys
- `.env` files - Environment-specific configuration
- `AWSCLIV2.pkg` - Installation packages

## Never Commit

- Private IP addresses
- Domain names (if you want them private)
- SSL certificates or private keys
- User data or media files
- API keys or passwords

## Using with Git

Your actual `docker-compose.yml` and `nginx.conf` files with real values should remain local. Use the template files as references.
