#!/usr/bin/env bash
# Proves the lab environment is gone. Run with: ./verify-teardown.sh
set -uo pipefail
docker info >/dev/null 2>&1 || { echo "Docker is not running"; exit 1; }
pass=0; failn=0; total=0
check() { local d="$1"; shift; total=$((total+1)); if "$@" >/dev/null 2>&1; then echo "PASS  $d"; pass=$((pass+1)); else echo "FAIL  $d"; failn=$((failn+1)); fi; }
none() { [ -z "$(eval "$1")" ]; }
check "no container named fa-*" none "docker ps -a --format '{{.Names}}' | grep -E '^fa-'"
check "no container with the label lab=docker-first-aid" none "docker ps -a -q --filter label=lab=docker-first-aid"
check "no network with the lab label" none "docker network ls -q --filter label=lab=docker-first-aid"
check "no volume with the lab label" none "docker volume ls -q --filter label=lab=docker-first-aid"
check "port 8080 is free" bash -c "! (exec 3<>/dev/tcp/127.0.0.1/8080) 2>/dev/null"
echo
if [ "$failn" -eq 0 ]; then echo "TEARDOWN VERIFIED ($pass/$total)"; else echo "NOT CLEAN: $failn leftover(s). Finish the tear down steps and run this again."; fi
exit "$failn"
