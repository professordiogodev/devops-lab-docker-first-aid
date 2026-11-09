#!/usr/bin/env bash
# Removes everything the lab created. Run:  ./teardown.sh
set -uo pipefail
ids=$(docker ps -a -q --filter label=lab=docker-first-aid)
# containers you created yourself with the lab's names (without the label) too
extra=$(docker ps -a --format '{{.Names}}' | grep -E '^fa-' || true)
[ -n "$ids" ] && docker rm -f -v $ids >/dev/null
[ -n "$extra" ] && docker rm -f -v $extra >/dev/null
docker network ls -q --filter label=lab=docker-first-aid | xargs -r docker network rm >/dev/null 2>&1 || true
docker volume ls -q --filter label=lab=docker-first-aid | xargs -r docker volume rm >/dev/null 2>&1 || true
echo "Removed the lab's containers, networks and volumes. Now run ./verify-teardown.sh to prove it."
