#!/bin/bash

# AudioBookShelf Docker Compose Deployment Script
# Run this script on rpi4 after copying the files

set -e

echo "🎧 AudioBookShelf Docker Deployment Starting..."

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p data/{config,metadata,audiobooks,podcasts}
mkdir -p ssl

# Set correct permissions
echo "🔐 Setting permissions..."
sudo chown -R 1000:1000 data/
chmod -R 755 data/

# Create SSL directory (for future HTTPS support)
touch ssl/.gitkeep

# Verify Docker is running
echo "🐳 Checking Docker status..."
if ! docker --version > /dev/null 2>&1; then
    echo "❌ Docker is not installed or not in PATH"
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker daemon is not running"
    echo "Please start Docker: sudo systemctl start docker"
    exit 1
fi

# Check if Docker Compose is available
if docker compose version > /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
elif docker-compose --version > /dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
else
    echo "❌ Docker Compose is not installed"
    exit 1
fi

echo "✅ Using: $COMPOSE_CMD"

# Pull latest images
echo "🔄 Pulling latest images..."
$COMPOSE_CMD pull

# Stop any existing containers
echo "🛑 Stopping existing containers..."
$COMPOSE_CMD down --remove-orphans 2>/dev/null || true

# Start services
echo "🚀 Starting AudioBookShelf..."
$COMPOSE_CMD up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be healthy..."
sleep 10

# Check service status
echo "📊 Service Status:"
$COMPOSE_CMD ps

# Show logs
echo -e "\n📋 Recent logs:"
$COMPOSE_CMD logs --tail=20

# Network information
echo -e "\n🌐 Network Information:"
RPI4_IP=$(hostname -I | awk '{print $1}')
echo "AudioBookShelf will be available at:"
echo "  • http://$RPI4_IP"
echo "  • http://$(hostname).local"

# Health check
echo -e "\n🏥 Health Check:"
sleep 5
if curl -f http://localhost/health >/dev/null 2>&1; then
    echo "✅ NGINX is healthy"
else
    echo "⚠️  NGINX health check failed"
fi

echo -e "\n🎉 Deployment complete!"
echo "📖 To view logs: $COMPOSE_CMD logs -f"
echo "🛑 To stop: $COMPOSE_CMD down"
echo "🔄 To restart: $COMPOSE_CMD restart"