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

echo -e "${GREEN}>> Chromium MULTI-CONTAINER Setup (20 Instances)...${NC}"

# Ask if password login should be enabled
read -p "Do you want to password-protect the browser? (y/n): " USE_PASSWORD

if [[ "$USE_PASSWORD" == "y" || "$USE_PASSWORD" == "Y" ]]; then
  read -p "Enter Chromium username base (e.g. user): " BASE_USER
  read -p "Enter Chromium password: " CHROME_PASS
fi

read -p "Enter homepage URL (e.g. https://example.com): " HOMEPAGE
read -p "Are you running this on a VPS (y/n)? " VPS

# Step 0: Install tools if needed
sudo apt update -y
sudo apt install -y lsb-release

if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null && ! command -v dig &> /dev/null; then
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
  sudo apt-get install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt update -y
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
  echo -e "${GREEN}>> Docker is already installed. Skipping Docker installation.${NC}"
fi

# Step 2: Create base directory
mkdir -p ~/chromium/multi
cd ~/chromium/multi

# Step 3: Create 20 docker-compose files
for i in {0..19}; do
  HTTP_PORT=$((3010 + i * 2))
  HTTPS_PORT=$((3011 + i * 2))
  CONFIG_DIR="/root/chromium/multi/config${i}"
  mkdir -p "$CONFIG_DIR"

  USERNAME="${BASE_USER}${i}"

  echo "services:" > docker-compose-${i}.yaml
  echo "  chromium${i}:" >> docker-compose-${i}.yaml
  echo "    image: lscr.io/linuxserver/chromium:latest" >> docker-compose-${i}.yaml
  echo "    container_name: chromium${i}" >> docker-compose-${i}.yaml
  echo "    security_opt:" >> docker-compose-${i}.yaml
  echo "      - seccomp:unconfined" >> docker-compose-${i}.yaml
  echo "    environment:" >> docker-compose-${i}.yaml

  if [[ "$USE_PASSWORD" == "y" || "$USE_PASSWORD" == "Y" ]]; then
    echo "      - CUSTOM_USER=${USERNAME}" >> docker-compose-${i}.yaml
    echo "      - PASSWORD=${CHROME_PASS}" >> docker-compose-${i}.yaml
  fi

  echo "      - PUID=1000" >> docker-compose-${i}.yaml
  echo "      - PGID=1000" >> docker-compose-${i}.yaml
  echo "      - TZ=${TZ}" >> docker-compose-${i}.yaml
  echo "      - CHROME_CLI=${HOMEPAGE}" >> docker-compose-${i}.yaml
  echo "    volumes:" >> docker-compose-${i}.yaml
  echo "      - ${CONFIG_DIR}:/config" >> docker-compose-${i}.yaml
  echo "    ports:" >> docker-compose-${i}.yaml
  echo "      - ${HTTP_PORT}:3000" >> docker-compose-${i}.yaml
  echo "      - ${HTTPS_PORT}:3001" >> docker-compose-${i}.yaml
  echo "    shm_size: \"1gb\"" >> docker-compose-${i}.yaml
  echo "    restart: unless-stopped" >> docker-compose-${i}.yaml
done

# Step 4: Launch all containers
for i in {0..19}; do
  docker compose -f docker-compose-${i}.yaml up -d
done

# Step 5: Detect IP address
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

# Step 6: Show access URLs
echo -e "${GREEN}>> All 20 Chromium containers are now running.${NC}"
echo -e "\n${GREEN}📡 Access URLs:${NC}"
for i in {0..19}; do
  HTTP_PORT=$((3010 + i * 2))
  HTTPS_PORT=$((3011 + i * 2))
  echo -e "chromium${i} → http://$IP:$HTTP_PORT/  |  https://$IP:$HTTPS_PORT/"
done

# 🧘 Closing message
echo -e "\n${GREEN}🌟 Saint Khen blesses your shortcut journey.\n🛋️  Stay lazy.${NC}"
