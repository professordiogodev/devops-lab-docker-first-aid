#!/usr/bin/env bash
# Builds the broken dev box. Run:  ./setup.sh   (no sudo needed, only a working `docker`)
set -uo pipefail
cd "$(dirname "$0")"
command -v docker >/dev/null || { echo "docker is not installed or not on PATH"; exit 1; }
docker info >/dev/null 2>&1 || { echo "Docker is not running (or your user may not use it). Start Docker and try again."; exit 1; }
L="--label lab=docker-first-aid"

if docker ps -a --filter label=lab=docker-first-aid -q | grep -q .; then
  echo "The lab is already set up. Run ./teardown.sh first if you want to start over."; exit 1
fi
for port in 8080; do
  if docker ps --format '{{.Ports}}' | grep -q ":$port->"; then echo "Port $port is used by a container that is not part of this lab. Stop it first."; exit 1; fi
  if (exec 3<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null; then echo "Port $port is in use on your machine. Free it first."; exit 1; fi
done

echo "Pulling images (first run only)..."
for img in postgres:16-alpine redis:7-alpine nginx:alpine alpine:3.20; do docker pull -q "$img" >/dev/null || { echo "could not pull $img"; exit 1; }; done

# 1. The database somebody started without a password: it starts, complains and exits.
docker run -d --name fa-db $L postgres:16-alpine >/dev/null

# 2. A forgotten old website that still owns port 8080.
docker run -d --name fa-old-web $L -p 8080:80 nginx:alpine \
  sh -c 'echo "OLD SITE (do not use)" > /usr/share/nginx/html/index.html; exec nginx -g "daemon off;"' >/dev/null
# ...so the new website cannot start. (docker create + start keeps the container around in the failed state.)
docker create --name fa-web $L -p 8080:80 nginx:alpine \
  sh -c 'echo "NEW SITE" > /usr/share/nginx/html/index.html; exec nginx -g "daemon off;"' >/dev/null
docker start fa-web >/dev/null 2>&1 || true

# 3. A worker that restarts forever.
docker run -d --name fa-crashloop $L --restart always alpine:3.20 \
  sh -c '[ -n "$DB_HOST" ] || { echo "fatal: DB_HOST is not set, cannot find the database" >&2; exit 3; }; echo "connected to $DB_HOST"; sleep 86400' >/dev/null

# 4. A chatty process that eats CPU and fills the disk with logs.
docker run -d --name fa-chatty $L alpine:3.20 \
  sh -c 'while true; do echo "$(date +%s) heartbeat heartbeat heartbeat heartbeat heartbeat heartbeat heartbeat heartbeat"; done' >/dev/null

# 5. A healthy container you know nothing about.
docker run -d --name fa-mystery $L -e RELEASE="orchid-$(( RANDOM % 900 + 100 ))" -p 127.0.0.1::6379 redis:7-alpine >/dev/null

sleep 3
echo
echo "The dev box is ready. This is what you inherited:"
docker ps -a --filter label=lab=docker-first-aid --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'
echo
echo "Run ./verify.sh any time to see how far you are."
