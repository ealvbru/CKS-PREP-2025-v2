#!/bin/bash
set -e

echo "🔹 Installing Docker (if not present)..."
if ! command -v docker &>/dev/null; then
  apt-get update -qq
  apt-get install -y -qq docker.io >/dev/null 2>&1 || true
fi

echo "🔹 Creating user 'develop'..."
id develop &>/dev/null || useradd -m -s /bin/bash develop

echo "🔹 Adding 'develop' to docker group (insecure)..."
groupadd docker 2>/dev/null || true
usermod -aG docker develop

echo "🔹 Setting insecure ownership on Docker socket..."
touch /var/run/docker.sock 2>/dev/null || true
chown develop:docker /var/run/docker.sock 2>/dev/null || true

echo "🔹 Configuring Docker to listen on TCP (insecure)..."
# Backup original service file
if [ -f /lib/systemd/system/docker.service ]; then
  cp /lib/systemd/system/docker.service /lib/systemd/system/docker.service.bak
fi

# Create a simulated insecure Docker service file
cat <<'SERVICEFILE' > /lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target docker.socket firewalld.service containerd.service
Wants=network-online.target containerd.service

[Service]
Type=notify
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutStartSec=0
RestartSec=2
Restart=always
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
SERVICEFILE

systemctl daemon-reload 2>/dev/null || true

echo ""
echo "✅ Lab setup complete!"
echo "   - User 'develop' added to docker group"
echo "   - Docker socket has insecure ownership (develop:docker)"
echo "   - Docker service configured to listen on TCP 0.0.0.0:2375 (insecure)"
echo "   - Your task: harden the Docker daemon configuration"
