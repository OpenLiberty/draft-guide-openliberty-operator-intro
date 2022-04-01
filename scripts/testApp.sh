#!/bin/bash
set -euxo pipefail

# Package the system/ app
mvn -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -q clean package

# Verifies that the system app is functional
mvn -pl system verify

# Delete m2 cache after completion
rm -rf ~/.m2
