#!/bin/bash
set -euxo pipefail

mvn -q package

docker pull icr.io/appcafe/open-liberty:full-java11-openj9-ubi

docker build -t system:1.0-SNAPSHOT system/.

NAMESPACE_NAME=$(bx cr namespace-list | grep sn-labs- | sed 's/ *$//g')
echo "${NAMESPACE_NAME}"
docker tag system:1.0-SNAPSHOT us.icr.io/"${NAMESPACE_NAME}"/system:1.0-SNAPSHOT
docker push us.icr.io/"${NAMESPACE_NAME}"/system:1.0-SNAPSHOT

sed -i 's=system:1.0-SNAPSHOT=us.icr.io/'"${NAMESPACE_NAME}"'/system:1.0-SNAPSHOT=g' deploy.yaml

kubectl apply -f deploy.yaml

sleep 60

kubectl get pods

kubectl proxy &

NAMESPACE_NAME=$(bx cr namespace-list | grep sn-labs- | sed 's/ //g')
SYSTEM_PROXY=localhost:8001/api/v1/namespaces/"$NAMESPACE_NAME"/services/system-service/proxy

echo "$SYSTEM_PROXY"

mvn failsafe:integration-test 
mvn failsafe:verify

curl http://"${SYSTEM_PROXY}"/system/properties

kubectl logs "$(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep system)"

kill "$(pidof kubectl)"

kubectl delete -f deploy.yaml
