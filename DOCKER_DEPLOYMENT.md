# AudioBookShelf Docker Compose Deployment

This directory contains a Docker Compose setup for AudioBookShelf with NGINX reverse proxy, optimized for single-node deployment on rpi4.

## 🗂️ File Structure

```
audiobookshelf/
├── docker-compose.yml      # Main compose configuration
├── nginx.conf             # Optimized NGINX configuration
├── deploy-docker.sh       # Deployment script
├── data/                  # Persistent data storage
│   ├── config/           # AudioBookShelf configuration
│   ├── metadata/         # Cache, covers, logs
│   ├── audiobooks/       # Audiobook library
│   └── podcasts/         # Podcast library
└── ssl/                  # SSL certificates (future use)
```

## 🚀 Deployment Steps

### 1. Prerequisites on rpi4

Run these commands manually on rpi4:

```bash
# Remove k3s agent
sudo /usr/local/bin/k3s-agent-uninstall.sh
sudo rm -rf /var/lib/rancher/k3s /etc/rancher/k3s

# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker CE
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Configure Docker
sudo usermod -aG docker fr0gger03
sudo systemctl enable docker
sudo systemctl start docker

# Verify installation
docker --version
docker compose version
```

### 2. Deploy AudioBookShelf

Copy the files to rpi4 and run:

```bash
# Copy files to rpi4
scp -r ./* fr0gger03@10.10.10.13:~/audiobookshelf/

# SSH to rpi4 and deploy
ssh fr0gger03@10.10.10.13
cd ~/audiobookshelf
./deploy-docker.sh
```

## 📋 Configuration Details

### Docker Compose Features

- **AudioBookShelf**: Latest version with health checks
- **NGINX**: Alpine-based reverse proxy with WebSocket support
- **Networking**: Isolated bridge network for security
- **Volumes**: Persistent data storage with proper permissions
- **Health Checks**: Built-in monitoring for both services

### NGINX Features

- **WebSocket Support**: Optimized for AudioBookShelf real-time features
- **Static Caching**: 24-hour cache for images, CSS, JS
- **Gzip Compression**: Reduces bandwidth usage
- **Security Headers**: Basic XSS and clickjacking protection
- **Health Endpoints**: `/health` for monitoring

### Performance Optimizations

- **Connection Pooling**: 32 keepalive connections to backend
- **Optimized Timeouts**: Fast failover for better UX
- **Resource Limits**: Controlled memory and CPU usage
- **Log Management**: Structured logging with rotation

## 🌐 Access Points

After deployment, AudioBookShelf will be available at:

- **Primary**: http://10.10.10.13 (rpi4 IP)
- **Local**: http://rpi4.local (if mDNS works)
- **Health Check**: http://10.10.10.13/health

## 🔧 Management Commands

```bash
# View status
docker compose ps

# View logs
docker compose logs -f

# Restart services
docker compose restart

# Stop services
docker compose down

# Update images
docker compose pull && docker compose up -d

# Backup data
tar -czf audiobookshelf-backup-$(date +%Y%m%d).tar.gz data/
```

## 📊 Monitoring

### Health Checks

- **NGINX**: http://localhost/health
- **AudioBookShelf**: Built-in health check on port 80
- **Docker**: `docker compose ps` shows health status

### Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f audiobookshelf
docker compose logs -f nginx

# With timestamps
docker compose logs -f -t
```

### Resource Usage

```bash
# Container stats
docker stats

# Disk usage
du -sh data/*
df -h
```

## 🔄 Migration Notes

This setup replaces the previous Kubernetes deployment with:

- **Simpler Architecture**: Direct Docker containers vs K8s pods
- **Better Performance**: No Kubernetes networking overhead
- **Easier Management**: Standard Docker commands
- **Local Storage**: Direct filesystem vs Longhorn volumes
- **Reduced Complexity**: No cluster management needed

## 🆘 Troubleshooting

### Common Issues

1. **Permission Errors**
   ```bash
   sudo chown -R 1000:1000 data/
   chmod -R 755 data/
   ```

2. **Port Conflicts**
   ```bash
   sudo netstat -tlnp | grep :80
   sudo systemctl stop apache2  # if running
   ```

3. **Docker Daemon Issues**
   ```bash
   sudo systemctl start docker
   sudo usermod -aG docker $USER
   # Logout and login again
   ```

4. **Health Check Failures**
   ```bash
   docker compose logs nginx
   docker compose logs audiobookshelf
   curl -v http://localhost/health
   ```

### Recovery

```bash
# Complete reset
docker compose down --volumes --remove-orphans
docker system prune -f
./deploy-docker.sh
```

---

**Deployment Date**: October 1, 2025  
**Environment**: Raspberry Pi 4 with Docker CE  
**Version**: AudioBookShelf latest + NGINX Alpine