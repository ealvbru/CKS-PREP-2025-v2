#!/bin/bash
set -e

echo "🔹 Creating Dockerfile at ~/Dockerfile..."
cat <<'DOCKERFILE' > ~/Dockerfile
FROM debian:bullseye-slim

LABEL maintainer="CouchDB Developers dev@couchdb.apache.org"
LABEL description="CouchDB is a database that uses JSON for documents"

ENV COUCHDB_VERSION=3.3.3

RUN groupadd -g 5984 -r couchdb && \
    useradd -u 5984 -d /opt/couchdb -g couchdb couchdb

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    dirmngr \
    gnupg \
    libicu67 \
    libmozjs-78-0 \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fSL https://apache.jfrog.io/artifactory/couchdb-deb/pool/C/CouchDB/couchdb_${COUCHDB_VERSION}~bullseye_amd64.deb -o couchdb.deb \
    && dpkg -i couchdb.deb || apt-get install -y -f \
    && rm couchdb.deb

COPY --chown=couchdb:couchdb vm.args /opt/couchdb/etc/
COPY --chown=couchdb:couchdb local.ini /opt/couchdb/etc/local.d/

RUN find /opt/couchdb \! \( -user couchdb -group couchdb \) -exec chown -f couchdb:couchdb '{}' +

VOLUME /opt/couchdb/data

EXPOSE 5984 4369 9100

WORKDIR /opt/couchdb

USER root

ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
CMD ["/opt/couchdb/bin/couchdb"]
DOCKERFILE

echo "🔹 Creating deployment file at ~/couchdb-deploy.yaml..."
cat <<'DEPLOY' > ~/couchdb-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: couchdb
  namespace: default
  labels:
    app: couchdb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: couchdb
  template:
    metadata:
      labels:
        app: couchdb
    spec:
      serviceAccountName: default
      automountServiceAccountToken: false
      containers:
      - name: couchdb
        image: couchdb:3.3.3
        ports:
        - containerPort: 5984
          protocol: TCP
        env:
        - name: COUCHDB_USER
          value: "admin"
        - name: COUCHDB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: couchdb-secret
              key: password
        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: false
          runAsNonRoot: true
          runAsUser: 5984
          capabilities:
            drop:
            - ALL
        volumeMounts:
        - name: couchdb-data
          mountPath: /opt/couchdb/data
        livenessProbe:
          httpGet:
            path: /_up
            port: 5984
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /_up
            port: 5984
          initialDelaySeconds: 15
          periodSeconds: 5
      volumes:
      - name: couchdb-data
        emptyDir: {}
      securityContext:
        fsGroup: 5984
DEPLOY

echo ""
echo "✅ Lab setup complete!"
echo "   - Dockerfile: ~/Dockerfile (CouchDB — has security issue: runs as root)"
echo "   - Deployment: ~/couchdb-deploy.yaml (has security issue: readOnlyRootFilesystem: false)"
echo "   - Your task: fix ONE line in each file (do NOT add/remove lines)"
