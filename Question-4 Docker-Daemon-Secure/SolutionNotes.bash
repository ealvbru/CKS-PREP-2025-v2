#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Solution — Question 4: Docker Daemon Security
# ══════════════════════════════════════════════════════════════════════

# Step 1: Remove user "develop" from docker group
sudo gpasswd -d develop docker
# Verify:
groups develop  # should NOT show "docker"

# Step 2: Change ownership of Docker socket to root:root
sudo chown root:root /var/run/docker.sock
# Verify:
ls -la /var/run/docker.sock  # should show root root

# Step 3: Edit Docker service to use Unix socket instead of TCP
sudo sed -i 's|ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375|ExecStart=/usr/bin/dockerd -H unix:///var/run/docker.sock|' /lib/systemd/system/docker.service
# Verify the change:
grep ExecStart /lib/systemd/system/docker.service

# Step 4: Reload systemd and restart Docker
sudo systemctl daemon-reload
sudo systemctl restart docker
# Verify Docker is running:
sudo systemctl status docker
docker ps  # should work

# ══════════════════════════════════════════════════════════════════════
EOF
