#!/usr/bin/env bash
set -euo pipefail

HOST="localhost:8080"
echo "Smoke testing $HOST..."

curl -s -o /dev/null -w "%{http_code}" http://$HOST/actuator/health | grep 200
curl http://$HOST/actuator/info

echo "OK ✓"