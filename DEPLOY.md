# Deployment Guide

Deploy qcrypto docs to `qcrypto.vpostea.com`.

## Prerequisites

1. DigitalOcean Droplet with Docker installed
2. DNS A record: `qcrypto` → your droplet IP

## Quick Deploy

### 1. Install Docker on your droplet

```bash
ssh root@YOUR_DROPLET_IP
curl -fsSL https://get.docker.com | sh
```

### 2. Clone and start

```bash
# On the droplet
cd /opt
git clone https://github.com/victorpostea/qcrypto-docs.git
cd qcrypto-docs
docker compose up -d
```

That's it! Caddy automatically:
- Gets SSL certificate from Let's Encrypt
- Serves the docs at https://qcrypto.vpostea.com
- Restarts if it crashes (`restart: always`)

## Updating the Docs

```bash
ssh root@YOUR_DROPLET_IP
cd /opt/qcrypto-docs
git pull
docker compose up -d --build
```

## Commands

```bash
# Check status
docker compose ps

# View logs
docker compose logs -f

# Restart
docker compose restart

# Stop
docker compose down

# Full rebuild
docker compose down -v
docker compose up -d
```

## Local Preview

```bash
pip install -r requirements.txt
mkdocs serve
# http://127.0.0.1:8000
```
