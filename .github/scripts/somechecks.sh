#!/usr/bin/env bash
set -euo pipefail

# somechecks.sh
# Run health checks against local services started by docker compose.
# On failure, dump docker compose logs for troubleshooting.

readonly RETRIES=30
readonly WAIT=2

wait_for() {
  local url="$1"
  local name="$2"
  echo "Checking ${name} at ${url}"
  for i in $(seq 1 ${RETRIES}); do
    if curl --max-time 5 -sSf -I "${url}" >/dev/null 2>&1; then
      echo "${name} is reachable"
      return 0
    fi
    echo "${name} not ready yet (attempt ${i}/${RETRIES}), sleeping ${WAIT}s..."
    sleep ${WAIT}
  done
  echo "ERROR: ${name} did not become ready at ${url} after $((RETRIES*WAIT))s"
  return 1
}

dump_logs_and_exit() {
  echo "\n--- Dumping docker compose logs for debugging ---\n"
  # Collect logs from all services
  docker compose logs --timestamps || true
  echo "\n--- End logs ---\n"
  # Tear down and exit non-zero
  docker compose down || true
  exit 1
}

# Services and endpoints to check (host ports from docker-compose)
checks=(
  "http://localhost:5000/api/data|backend (5000)"
  "http://localhost:3000/|frontend dev server (3000)"
  # Loki readiness: try /ready first (lighter), fall back to /loki/api/v1/labels
  # The script handles this special-case below.
  "http://localhost:9090/-/ready|prometheus (9090)"
  "http://localhost:3200/api/health|grafana (3200)"
  "http://localhost:8080/metrics|cadvisor (8080)"
)

for entry in "${checks[@]}"; do
  url=${entry%%|*}
  name=${entry##*|}
  if ! wait_for "${url}" "${name}"; then
    echo "Health check failed for ${name} (${url})"
    dump_logs_and_exit
  fi
done

# Special-case Loki: try /ready first, then fallback to labels endpoint
if wait_for "http://localhost:3100/ready" "loki (3100 readiness)"; then
  echo "loki is ready"
elif wait_for "http://localhost:3100/loki/api/v1/labels" "loki (3100 labels)"; then
  echo "loki labels endpoint reachable"
else
  echo "Health check failed for loki (both /ready and /loki/api/v1/labels unreachable)"
  dump_logs_and_exit
fi

echo "All checks passed."

# Keep running services up for subsequent steps if any; caller should tear down.
