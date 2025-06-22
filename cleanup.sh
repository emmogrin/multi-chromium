#!/bin/bash
echo "🔥 Saint Khen's cleanup — removing all Chromium containers and configs..."

for i in {0..19}; do
  docker stop chromium$i && docker rm chromium$i
  rm -f docker-compose-${i}.yaml
done

rm -rf ~/chromium/multi/config*

echo "✅ Cleanup complete. All Chromium instances removed. Bless the next batch 🙏"
