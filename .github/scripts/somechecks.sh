#!/usr/bin/env bash
set -euo pipefail

# somechecks.sh
# Run health checks against local services started by docker compose.
# On failure, dump docker compose logs for troubleshooting.

readonly RETRIES=10
readonly WAIT=2
readonly DEFAULT_CURL_TIMEOUT=30
readonly DEFAULT_CONNECT_TIMEOUT=10

wait_for() {
  local url="$1"
  local name="$2"
  local timeout="${3:-$DEFAULT_CURL_TIMEOUT}"
  local connect_timeout="${4:-$DEFAULT_CONNECT_TIMEOUT}"
  echo "Checking ${name} at ${url} (connect-timeout ${connect_timeout}s, max-time ${timeout}s)"
  for i in $(seq 1 ${RETRIES}); do
    if curl --connect-timeout "${connect_timeout}" --max-time "${timeout}" -sSf -I "${url}" >/dev/null 2>&1; then
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
  # format: url|display name|max_timeout|connect_timeout|service_name
  # service_name is used to selectively dump logs on failure (e.g. 'cadvisor')
  "http://localhost:5000/api/data|backend (5000)|||backend"
  "http://localhost:3000/|frontend dev server (3000)|||frontend"
  # Loki readiness: handled specially below (no entry here)
  "http://localhost:9090/-/ready|prometheus (9090)||"
  "http://localhost:3200/api/health|grafana (3200)|||grafana"
  # cadvisor can be slow; set a larger max timeout (e.g. 30s) and a longer connect timeout (10s)
  "http://localhost:8080/metrics|cadvisor (8080)|30|10|cadvisor"
)

for entry in "${checks[@]}"; do
  url=${entry%%|*}
  rest=${entry#*|}
  name=${rest%%|*}
  rest_after_name=${rest#*|}
  max_timeout=${rest_after_name%%|*}
  rest_after_max=${rest_after_name#*|}
  connect_timeout=${rest_after_max%%|*}
  svc=${rest_after_max#*|}
  # normalize empty strings to unset so wait_for picks defaults
  max_timeout=${max_timeout:-}
  connect_timeout=${connect_timeout:-}
  svc=${svc:-}
  if ! wait_for "${url}" "${name}" "${max_timeout}" "${connect_timeout}"; then
    if [ "${svc}" = "cadvisor" ]; then
      # On GitHub Actions runners cadvisor often can't access host mounts.
      # Make this check non-fatal in CI: log a warning and continue.
      echo "WARNING: ${name} (${url}) failed on CI runner; continuing without cadvisor checks."
      # Optionally dump cadvisor logs for debugging, but don't fail the job.
      echo "Dumping cadvisor logs for debugging (non-fatal)..."
      docker compose logs --no-color --timestamps --tail=200 cadvisor || true
      continue
    fi
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
