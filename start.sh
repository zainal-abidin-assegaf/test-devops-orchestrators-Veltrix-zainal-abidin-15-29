#!/bin/bash

# Exit immediately if any command fails
set -e

timestamp=$(date +"%Y%m%d_%H%M%S")

# Ensure the 'logs' directory exists
mkdir -p logs

# Redirect all output (stdout + stderr) to both terminal and log file
exec > >(tee -a logs/run_$timestamp.log) 2>&1

# Add PID lock
LOCKFILE="/tmp/swap_optimizer.pid"
if [ -f "$LOCKFILE" ]; then
    echo "[ERROR] Service already running (PID $(cat $LOCKFILE))"
    exit 1
fi
echo $$ > "$LOCKFILE"

# Remove lock automatically when the script exit
trap 'rm -f "$LOCKFILE"' EXIT

echo "[Swap Optimizer] Starting the path-finder service..."

# Ensure .env exists
if [ ! -f .env ]; then
    echo "[ERROR] Missing .env file. Please run setup.sh first."
    exit 1
fi

# Run orchestrator logic
echo "[Swap Optimizer] Starting orchestrator..."

npm run build

npm start &

(
  sleep 600
  pkill -f "node dist/app.js"
  echo "[SWAP OPTIMIZER] Simulated crash: app.js stopped after 5 minutes." >> logs/output.log
) &

wait
