#!/usr/bin/env bash
# Run with: ./verify.sh
set -uo pipefail
cd "$(dirname "$0")"
docker info >/dev/null 2>&1 || { echo "Docker is not running"; exit 1; }
docker inspect fa-mystery >/dev/null 2>&1 || { echo "Run ./setup.sh first (or the lab was already torn down)"; exit 1; }
pass=0; failn=0; total=0
check() { local d="$1"; shift; total=$((total+1)); if "$@" >/dev/null 2>&1; then echo "PASS  $d"; pass=$((pass+1)); else echo "FAIL  $d"; failn=$((failn+1)); fi; }
insp() { docker inspect -f "$1" "$2" 2>/dev/null; }
running() { [ "$(insp '{{.State.Running}}' "$1")" = true ]; }

echo "== Database =="
check "fa-db is running" running fa-db
check "fa-db has a password configured" bash -c "docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' fa-db | grep -q '^POSTGRES_PASSWORD=.\+'"
check "fa-db accepts connections" bash -c "sleep 2; docker exec fa-db pg_isready -U postgres"

echo "== Website =="
check "the old site container is gone" bash -c "! docker inspect fa-old-web"
check "fa-web is running and published on 8080" bash -c "running() { [ \"\$(docker inspect -f '{{.State.Running}}' fa-web)\" = true ]; }; running && docker port fa-web 80 | grep -q ':8080'"
check "http://localhost:8080 serves the NEW site" bash -c "curl -s --max-time 5 localhost:8080 | grep -q 'NEW SITE'"

echo "== Crash loop =="
check "fa-crashloop is running" running fa-crashloop
check "fa-crashloop is stable (no restarts in the last 8 seconds)" bash -c "a=\$(docker inspect -f '{{.RestartCount}}' fa-crashloop); sleep 8; b=\$(docker inspect -f '{{.RestartCount}}' fa-crashloop); [ \"\$a\" = \"\$b\" ] && [ \"\$(docker inspect -f '{{.State.Running}}' fa-crashloop)\" = true ] && docker logs fa-crashloop 2>&1 | grep -q '^connected to'"
check "fa-crashloop knows where the database is (DB_HOST=fa-db)" bash -c "docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' fa-crashloop | grep -q '^DB_HOST=fa-db\$'"

echo "== Noisy neighbour =="
check "fa-chatty is gone" bash -c "! docker inspect fa-chatty"
check "fa-worker is running" running fa-worker
check "fa-worker has a memory limit" bash -c "[ \"\$(docker inspect -f '{{.HostConfig.Memory}}' fa-worker)\" -gt 0 ]"
check "fa-worker has a CPU limit" bash -c "[ \"\$(docker inspect -f '{{.HostConfig.NanoCpus}}' fa-worker)\" -gt 0 ]"
check "fa-worker rotates its logs (max-size set)" bash -c "docker inspect -f '{{index .HostConfig.LogConfig.Config \"max-size\"}}' fa-worker | grep -q ."
check "fa-worker restarts unless stopped" bash -c "[ \"\$(docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' fa-worker)\" = unless-stopped ]"

echo "== Housekeeping =="
check "fa-mystery is still running (you did not break what worked)" running fa-mystery
check "no lab container is left stopped, created or restarting" bash -c "[ -z \"\$(docker ps -a --filter label=lab=docker-first-aid --filter status=exited --filter status=created --filter status=restarting --filter status=dead -q)\" ]"
check "notes.md has a real sentence for each of the five containers" bash -c "for c in fa-db fa-web fa-crashloop fa-chatty fa-mystery; do grep -qE \"^- \$c: .{20,}\" notes.md || exit 1; done"

echo
if [ "$failn" -eq 0 ]; then echo "ALL CHECKS PASSED ($pass/$total)"; else echo "$failn check(s) failed, $pass passed"; fi
exit "$failn"
