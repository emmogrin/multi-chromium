#!/bin/bash

echo "🧹 Stopping and removing all Chromium containers..."

for i in {0..19}; do
  docker stop chromium$i 2>/dev/null && echo "✅ Stopped chromium$i"
  docker rm chromium$i 2>/dev/null && echo "🗑️  Removed chromium$i"
  rm -f docker-compose-${i}.yaml
done

echo "🧼 Removing config directories..."
rm -rf ~/chromium/multi/config*

echo "🎉 Cleanup complete. You're free."
