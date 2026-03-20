#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Question 6 — Static File Analysis: Dockerfile & Deployment
# ══════════════════════════════════════════════════════════════════════
#
# Context:
#   You have been given two files to review for security issues:
#     - ~/Dockerfile        — A Dockerfile for a CouchDB application
#     - ~/couchdb-deploy.yaml — A Kubernetes Deployment manifest
#
#   DO NOT build the Docker image. DO NOT add or remove any lines.
#
# Tasks:
#   1. In the Dockerfile (~/Dockerfile):
#      Change ONE line only — the application should NOT run as root.
#      Find the line "USER root" and change it to "USER couchdb"
#      Do NOT add or remove any lines.
#
#   2. In the Deployment file (~/couchdb-deploy.yaml):
#      Change ONE line only — enable read-only root filesystem.
#      Find "readOnlyRootFilesystem: false" and change it to
#      "readOnlyRootFilesystem: true"
#      Do NOT add or remove any lines.
#
# Important:
#   - You must change exactly ONE line in each file
#   - Do NOT add new lines or remove existing lines
#   - Do NOT build the Docker image
#
# Weight: 14%
# ══════════════════════════════════════════════════════════════════════
EOF
