#!/bin/bash

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

# 🌟 ASCII Blessing Banner
echo -e "${GREEN}"
cat << "EOF"
   ╔═══════════════════════════════════════╗
   ║             SAINT KHEN               ║
   ║          Follow @admirkhen           ║
   ╚═══════════════════════════════════════╝
         The saints bless even the Sybils.
                God loves all.
EOF
echo -e "${NC}"

echo -e "${GREEN}>> Chromium MULTI-CONTAINER Setup (Max 20 Instances)...${NC}"

# Ask how many containers to run
read -p "How many Chromium containers do you want to run? (default: 10, max: 20): " INSTANCE_COUNT
INSTANCE_COUNT=${INSTANCE_COUNT:-10}
if [[ $INSTANCE_COUNT -gt 20 ]]; then
  INSTANCE_COUNT=20
  echo "⚠️  Capped to 20 containers to prevent overload."
fi

# Ask if password login should be enabled
read -p "Do you want to password-protect the browser? (y/n): " USE_PASSWORD

if [[ "$USE_PASSWORD" == "y" || "$USE_PASSWORD" == "Y" ]]; then
  read -p "Enter Chromium username base (e.g. user): " BASE_USER
  read -p "Enter Chromium password: " CHROME_PASS
fi

read -p "Enter homepage URL (default: about:blank): " HOMEPAGE
HOMEPAGE=${HOMEPAGE:-about:blank}

read -p "Are you running this on a VPS (y/n)? " VPS

# Step 0: Install tools if needed
sudo apt update -y
sudo apt install -y lsb-release

if ! command -v curl &> /dev/null || ! command -v wget &> /dev/null || ! command -v dig &> /dev/null; then
  echo -e "${GREEN}>> Installing curl, wget, and dnsutils (dig)...${NC}"
  sudo apt install curl wget dnsutils -y
fi

# Auto-detect timezone
TZ=$(timedatectl show --value --property=Timezone 2>/dev/null)
if [[ -z "$TZ" ]]; then
  TZ="Etc/UTC"
  echo -e "${GREEN}⚠️ Could not auto-detect timezone. Defaulting to UTC.${NC}"
else
  echo -e "${GREEN}🕓 Auto-detected timezone: $TZ${NC}"
fi

# Step 1: Install Docker if not present
if ! command -v docker &> /dev/null; then
  echo -e "${GREEN}>> Docker not found. Installing Docker...${NC}"

  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  if ! command -v docker &> /dev/null; then
    echo -e "${GREEN}>> APT install failed. Using official Docker install script as fallback...${NC}"
    curl -fsSL https://get.docker.com | sh
  fi
else
  echo -e "${GREEN}>> Docker is already installed. Skipping Docker installation.${NC}"
fi

# Step 2: Create base directory
mkdir -p ~/chromium/multi
cd ~/chromium/multi

# Step 3: Count existing containers to continue from last index
existing_count=$(docker ps -a --format '{{.Names}}' | grep -c '^chromium[0-9]\+$')
start_index=$existing_count
end_index=$((existing_count + INSTANCE_COUNT - 1))

# Step 4: Create docker-compose files
for ((i=start_index; i<=end_index; i++)); do
  HTTP_PORT=$((3010 + i * 2))
  HTTPS_PORT=$((3011 + i * 2))
  CONFIG_DIR="/root/chromium/multi/config${i}"
  mkdir -p "$CONFIG_DIR"

  USERNAME="${BASE_USER}${i}"

  cat > docker-compose-${i}.yaml <<EOF
services:
  chromium${i}:
    image: lscr.io/linuxserver/chromium:latest
    container_name: chromium${i}
    security_opt:
      - seccomp:unconfined
    environment:
EOF

  if [[ "$USE_PASSWORD" == "y" || "$USE_PASSWORD" == "Y" ]]; then
    echo "      - CUSTOM_USER=${USERNAME}" >> docker-compose-${i}.yaml
    echo "      - PASSWORD=${CHROME_PASS}" >> docker-compose-${i}.yaml
  fi

  cat >> docker-compose-${i}.yaml <<EOF
      - PUID=1000
      - PGID=1000
      - TZ=${TZ}
      - CHROME_CLI=${HOMEPAGE}
    volumes:
      - ${CONFIG_DIR}:/config
    ports:
      - ${HTTP_PORT}:3000
      - ${HTTPS_PORT}:3001
    shm_size: "1gb"
    restart: unless-stopped
EOF
done

# Step 5: Launch new containers
for ((i=start_index; i<=end_index; i++)); do
  docker compose -f docker-compose-${i}.yaml up -d
done

# Step 6: Detect IP address
if [[ "$VPS" == "y" || "$VPS" == "Y" ]]; then
  if command -v curl &> /dev/null; then
    IP=$(curl -s ifconfig.me)
  elif command -v wget &> /dev/null; then
    IP=$(wget -qO- https://ifconfig.me)
  elif command -v dig &> /dev/null; then
    IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
  else
    IP="localhost"
  fi
else
  IP="localhost"
fi

# Step 7: Show access URLs
echo -e "${GREEN}>> All $INSTANCE_COUNT Chromium containers are now running.${NC}"
echo -e "\n${GREEN}📡 Access URLs:${NC}"
for ((i=start_index; i<=end_index; i++)); do
  HTTP_PORT=$((3010 + i * 2))
  HTTPS_PORT=$((3011 + i * 2))
  echo -e "chromium${i} → http://$IP:$HTTP_PORT/  |  https://$IP:$HTTPS_PORT/"
done

# 🌟 Closing blessing
echo -e "\n${GREEN}🌟 Saint Khen blesses your shortcut journey.\n🛋️  Stay lazy.${NC}"
