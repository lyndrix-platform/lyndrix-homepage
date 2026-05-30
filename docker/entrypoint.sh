#!/bin/sh
set -eu

if [ ! -d node_modules/astro ]; then
  echo "[Boot] Installing homepage dependencies..."
  npm install
fi

exec "$@"