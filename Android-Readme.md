📱 README-Termux.md — For Android (Termux + QEMU)

# 🧱 Multi-Chromium on Android (Termux + QEMU)

Run multiple isolated Chromium browsers on your Android using QEMU and Docker inside a Debian VM.

---

## ⚙️ Requirements

- Android phone with **Termux** installed
- At least **8GB storage**, **4GB RAM**, **QEMU system installed**
- A Debian VM image (`debian-11.qcow2`)
- Port-forwarding enabled in QEMU

---

## 🔌 QEMU Command (Start Debian VM) [skip if you are already logged in the vm/qemu]
```
cd qemu-debian
```
```bash
qemu-system-x86_64 \
  -m 2048 \
  -smp 2 \
  -drive file=debian-11.qcow2,format=qcow2 \
  -net nic \
  -net user,hostfwd=tcp::2222-:22,hostfwd=tcp::3010-:3010,hostfwd=tcp::3011-:3011 \
  -nographic
```
> ⚠️ Only 1 or 2 Chromium instances recommended due to limited RAM on Android




---

# 🚀 Quick Start

# Inside Debian (via SSH or QEMU login):
```
apt update && apt install -y git
```
```
git clone https://github.com/emmogrin/multi-chromium
cd multi-chromium
chmod +x multi-chromium.sh
./multi-chromium.sh 1
```
Accept prompts (VPS = n) enter n which means no

You can skip password protection



---

🌐 Access Chromium

From your Android browser (chrome or brave), visit:
```
http://localhost:3010
```
```
https://localhost:3011
```

If you're using Termux with port forwarding, these ports are forwarded from QEMU to Android.


---

🧹 Cleanup Chromium Containers (incase you decide to wipe it all)
```
./cleanup.sh
```
Removes all running Chromium containers and config folders.


---

🧩 Add More Containers Later
```
./multi-chromium.sh 1
```
Adds one more Chromium instance (next in line, no overwrite).


---

💡 Notes

First pull may take time due to image size.

You can safely run 1–2 containers on Termux VM.

More than that may crash or lag. fr fr bro😂

don't worry 😉, it automatically restarts there's no need for a Start code.


---

🌟 Saint Khen blesses your shortcut journey. 🛋️ Stay lazy.


shoutout: @bigray0x @0xmoei
