## 🖥️ `README-VPS.md` — For Linux VPS or Cloud

# 🧱 Multi-Chromium on VPS (Dockerized)

Launch multiple Chromium containers (up to 20) on your Linux VPS with optional password login.

---

## ⚙️ Requirements

- Debian/Ubuntu VPS
- Docker & Docker Compose
- At least 2 CPUs and 4–8 GB RAM for multiple instances

---

## 🚀 Quick Start

```bash
sudo apt update && sudo apt install -y git
```
```
git clone https://github.com/emmogrin/multi-chromium
cd multi-chromium
chmod +x multi-chromium.sh
./multi-chromium.sh 5
```

Answer prompts interactively:

Number of instances (up to 20) [more like saying 20 separate chromes)

Password-protection? (y or n)

Homepage URL (you can say google.com or leave it blank)

VPS? → Answer y




---

🌐 Access Chromium

After setup, the script will output URLs like:

chromium0 → http://your_vps_ip:3010/ | https://your_vps_ip:3011/
chromium1 → http://your_vps_ip:3012/ | https://your_vps_ip:3013/

Open/copy any of them in your local browser(chrome or brave).


---

🧹 Cleanup All Chromium Containers
```
./cleanup.sh
```
Stops and removes all containers, volumes, and configs.


---

➕ Add More Containers Later
```
./multi-chromium.sh 3
```
Automatically creates next available Chromium instances (starting after your last).


---

♻️ Reboot Handling

Docker is set to auto-restart containers, but if needed:

# Start them again manually after reboot
docker ps -a                  # check containers
docker start chromium0        # start a container


---

🧪 Check Running Containers
```
docker ps
```
To see logs of a specific instance:
```
docker logs chromium0

```
---

📁 Configs Location

All Chromium browser data is saved in:

~/chromium/multi/config*

Each container gets its own isolated config folder.


---

🌟 Saint Khen blesses your shortcut journey.
🛋️ Stay lazy.
# multi-chromium
Reference: @bigray0x 
