#!/bin/bash
set -euxo pipefail

# Package the system/ app
mvn -q -pl models install
mvn -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -q clean package

# Verifies that the system app is functional
mvn liberty:start
curl "http://localhost:9080/health" | grep "UP"
if [ $? -gt 0 ] ; then exit $?; fi
curl "http://localhost:9080/system/properties" | grep "os.name"
if [ $? -gt 0 ] ; then exit $?; fi
mvn liberty:stop

# Delete m2 cache after completion
rm -rf ~/.m2
