#!/bin/sh
set -eu

# Configuration
DISPLAY=":99"
SCREEN_RESOLUTION="1024x768x16"
XVFB_RETRY_ATTEMPTS=10
XVFB_RETRY_INTERVAL=0.5
REW_PORT=4735
REW_HOST="0.0.0.0"

# Trap cleanup on exit
trap 'kill $(jobs -p) 2>/dev/null || true' EXIT

# Function to start and verify Xvfb
start_xvfb()
{
  echo "Starting Xvfb..."
  Xvfb ${DISPLAY} -screen 0 ${SCREEN_RESOLUTION} -nolisten tcp 2>/dev/null &

  echo "Waiting for Xvfb to start..."
  i=1
  while [ $i -le ${XVFB_RETRY_ATTEMPTS} ]; do
    if xdpyinfo -display ${DISPLAY} > /dev/null 2>&1; then
      echo "Xvfb started successfully"
      return 0
    fi
    echo "Attempt $i of ${XVFB_RETRY_ATTEMPTS}..."
    sleep ${XVFB_RETRY_INTERVAL}
    i=$((i + 1))
  done

  echo "Error: Xvfb failed to start after ${XVFB_RETRY_ATTEMPTS} attempts"
  return 1
}

# Start Xvfb
if ! start_xvfb; then
  exit 1
fi

# Extra delay for ARM64 emulation
sleep 1

echo "Starting RoomEQWizard..."
exec /opt/rew/roomeqwizard -api -nogui -port ${REW_PORT} -host ${REW_HOST} -console
