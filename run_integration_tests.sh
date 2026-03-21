#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/dart_desk_be_server"

echo "=== Dart Desk Backend Integration Tests ==="
echo ""

echo "[1/3] Starting test Docker services..."
docker compose up -d postgres_test redis_test

echo "[2/3] Waiting for PostgreSQL to be ready..."
RETRIES=30
until docker compose exec -T postgres_test pg_isready -U postgres > /dev/null 2>&1; do
  RETRIES=$((RETRIES - 1))
  if [ $RETRIES -le 0 ]; then
    echo "ERROR: PostgreSQL did not become ready in time."
    docker compose down
    exit 1
  fi
  sleep 1
done
echo "PostgreSQL ready."

echo "[3/3] Running integration tests..."
echo ""
TEST_EXIT=0
# NOTE: If you see flaky test failures due to cross-test DB interference,
# add --concurrency=1 to run tests sequentially. This is only needed if
# any test file uses rollbackDatabase: RollbackDatabase.disabled.
dart test test/integration/ --exclude-tags=stress || TEST_EXIT=$?

echo ""
echo "Stopping test Docker services..."
docker compose down

exit $TEST_EXIT
