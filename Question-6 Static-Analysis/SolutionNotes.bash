#!/bin/bash
cat <<'EOF'
# ══════════════════════════════════════════════════════════════════════
# Solution — Question 6: Static File Analysis
# ══════════════════════════════════════════════════════════════════════

# Step 1: Fix the Dockerfile — change USER root to USER couchdb
sed -i 's/^USER root$/USER couchdb/' ~/Dockerfile
# Verify:
grep '^USER' ~/Dockerfile
# Should show: USER couchdb

# Step 2: Fix the Deployment — change readOnlyRootFilesystem from false to true
sed -i 's/readOnlyRootFilesystem: false/readOnlyRootFilesystem: true/' ~/couchdb-deploy.yaml
# Verify:
grep 'readOnlyRootFilesystem' ~/couchdb-deploy.yaml
# Should show: readOnlyRootFilesystem: true

# Important reminders:
# - Do NOT build the Docker image
# - Do NOT add or remove any lines
# - Only change the specific values as instructed

# ══════════════════════════════════════════════════════════════════════
EOF
