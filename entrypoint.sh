#!/bin/bash
set -euo pipefail

# Configuration
readonly DISPLAY=":99"
readonly SCREEN_RESOLUTION="1024x768x16"
readonly XVFB_RETRY_ATTEMPTS=10
readonly XVFB_RETRY_INTERVAL=0.5
readonly REW_PORT=4735
readonly REW_HOST="0.0.0.0"

# Trap cleanup on exit
trap 'kill $(jobs -p)' EXIT

# Function to start and verify Xvfb
start_xvfb()
{
  echo "Starting Xvfb..."
  Xvfb ${DISPLAY} -screen 0 ${SCREEN_RESOLUTION} -nolisten tcp &

  echo "Waiting for Xvfb to start..."
  for ((i = 1; i <= XVFB_RETRY_ATTEMPTS; i++)); do
    if xdpyinfo -display ${DISPLAY} > /dev/null 2>&1; then
      echo "Xvfb started successfully"
      return 0
    fi
    echo "Attempt $i of ${XVFB_RETRY_ATTEMPTS}..."
    sleep ${XVFB_RETRY_INTERVAL}
  done

  echo "Error: Xvfb failed to start after ${XVFB_RETRY_ATTEMPTS} attempts"
  return 1
}

# Start Xvfb
if ! start_xvfb; then
  exit 1
fi

echo "Starting RoomEQWizard..."
exec /opt/rew/roomeqwizard -api -nogui -port ${REW_PORT} -host ${REW_HOST} -console
