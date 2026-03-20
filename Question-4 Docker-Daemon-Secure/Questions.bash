#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Question 4 — Docker Daemon Security Hardening
# ══════════════════════════════════════════════════════════════════════
#
# Context:
#   The Docker daemon is currently configured insecurely on this node.
#   A user "develop" has been added to the "docker" group, giving them
#   unrestricted access to Docker. The Docker socket has incorrect
#   ownership, and the Docker service is listening on TCP (exposed to
#   the network) instead of the Unix socket only.
#
# Tasks:
#   1. Remove the user "develop" from the "docker" group
#   2. Change ownership of the Docker socket /var/run/docker.sock
#      to root:root
#   3. Edit the Docker service file at /lib/systemd/system/docker.service
#      and change the ExecStart line to use the Unix socket instead of
#      TCP. Change:
#        ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375
#      To:
#        ExecStart=/usr/bin/dockerd -H unix:///var/run/docker.sock
#   4. Reload systemd and restart the Docker service
#
# Important:
#   - Do NOT remove the user "develop" from the system, only from the
#     docker group
#   - Ensure Docker is running after your changes
#
# Weight: 15%
# ══════════════════════════════════════════════════════════════════════
EOF
