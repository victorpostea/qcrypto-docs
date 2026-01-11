#!/bin/bash
# Deploy qcrypto docs to DigitalOcean VM
# Usage: ./deploy.sh user@your-droplet-ip

set -e

if [ -z "$1" ]; then
    echo "Usage: ./deploy.sh user@droplet-ip"
    echo "Example: ./deploy.sh root@143.198.xxx.xxx"
    exit 1
fi

SERVER=$1
REMOTE_DIR="/opt/qcrypto-docs"

echo "Deploying qcrypto docs to $SERVER..."

# Build locally first to catch errors
echo "Building docs locally..."
pip install -r requirements.txt
mkdocs build

# Sync files to server
echo "Uploading files..."
rsync -avz --delete \
    --exclude '.git' \
    --exclude 'venv' \
    --exclude '__pycache__' \
    --exclude 'site' \
    ./ "$SERVER:$REMOTE_DIR/"

# Build and run on server
echo "Building and starting container..."
ssh "$SERVER" << 'ENDSSH'
cd /opt/qcrypto-docs
docker compose down || true
docker compose build --no-cache
docker compose up -d
docker compose logs --tail=20
ENDSSH

echo "Deployment complete!"
echo "Visit http://$SERVER to see the docs"
