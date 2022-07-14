#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $SCRIPTDIR

# Apply configuration
source ./loki.config

echo "LOKI_VERSION = $LOKI_VERSION"
echo "PROMTAIL_VERSION = $PROMTAIL_VERSION"

set +e

if [ $STORAGECLASS_NAME != "{STORAGECLASS_NAME}" ]; then
  sed -i 's/{STORAGECLASS_NAME}/'${STORAGECLASS_NAME}'/g' 01_loki.yaml
  echo "STORAGECLASS_NAME = $STORAGECLASS_NAME"
else
  sed -i 's/storageClassName: {STORAGECLASS_NAME}//g' 01_loki.yaml
  echo "STORAGECLASS_NAME = default-storage-class"
fi
if [ $REGISTRY != "{REGISTRY}" ]; then
  echo "REGISTRY = $REGISTRY"
fi

sed -i 's/{LOKI_VERSION}/'${LOKI_VERSION}'/g' 01_loki.yaml
sed -i 's/{PROMTAIL_VERSION}/'${PROMTAIL_VERSION}'/g' 02_promtail.yaml


if [ $REGISTRY != "{REGISTRY}" ]; then
  sed -i 's/docker.io\/grafana\/loki/'${REGISTRY}'\/grafana\/loki/g' 01_loki.yaml
  sed -i 's/docker.io\/grafana\/promtail/'${REGISTRY}'\/grafana\/promtail/g' 02_promtail.yaml
fi

# 1. Install Grafana Loki
echo " "
echo "---Installation Start---"
kubectl create namespace monitoring

echo " "
echo "---1. Install Loki---"
kubectl apply -f 01_opensearch.yaml
timeout 5m kubectl -n monitoring rollout status statefulset/loki
suc=`echo $?`
if [ $suc != 0 ]; then
  echo "Failed to install Loki"
  kubectl delete -f 01_loki.yaml
  exit 1
else
  echo "Loki pod running success" 
fi

# 2. Wait until Loki starts up
echo " "
echo "---2. Wait until Loki starts up---"
echo "It will take a couple of minutes"
sleep 1m
set +e
export LO_IP=`kubectl get svc -n monitoring | grep loki | tr -s ' ' | cut -d ' ' -f3`
for ((i=0; i<11; i++))
do
  curl -XGET https://$LO_IP:3100/loki/api/v1/status/buildinfo
  is_success=`echo $?`
  if [ $is_success == 0 ]; then
    break
  elif [ $i == 10 ]; then
    echo "Timeout. Start uninstall"
    kubectl delete -f 01_loki.yaml
    exit 1
  else
    echo "try again..."
    sleep 1m
  fi
done
echo "Loki starts up successfully"
set -e

# 3. Install Promtail
echo " "
echo "---3. Install Promtail---"
kubectl apply -f 02_promtail.yaml
timeout 10m kubectl -n monitoring rollout status daemonset/promtail
suc=`echo $?`
if [ $suc != 0 ]; then
  echo "Failed to install Promtail"
  kubectl delete -f 02_promtail.yaml
  exit 1
else
  echo "Promtail running success"
  sleep 10s
fi

echo " "
echo "---Installation Done---"
popd
