#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $SCRIPTDIR

echo "---Uninstallation Start---"
timeout 5m kubectl delete -f 02_promtail.yaml 
suc=`echo $?`
if [ $suc != 0 ]; then
  echo "Failed to delete Promtail"
  #exit 1
fi

timeout 5m kubectl delete -f 01_loki.yaml 
suc=`echo $?`
if [ $suc != 0 ]; then
  echo "Failed to delete loki"
  #exit 1
fi

echo "---Uninstallation Done---"
popd
