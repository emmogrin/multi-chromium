#!/bin/bash

echo "🔧 Installing Portainer (Docker Dashboard)..."

# Create volume for Portainer data
docker volume create portainer_data

# Run Portainer container
docker run -d \
  --name portainer \
  --restart=always \
  -p 9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce

echo "✅ Portainer installed!"
echo "🌐 Access it at: http://<your_vps_ip>:9000"
echo "🛡️  Set your admin password on first login."
