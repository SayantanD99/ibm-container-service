#!/bin/bash

if [ "${PWD##*/}" == "create" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/delete' folder"
fi

WITH_COUCHDB=false
PAID=false

Parse_Arguments() {
	while [ $# -gt 0 ]; do
		case $1 in
			--with-couchdb)
				echo "Configured to setup network with couchdb"
				WITH_COUCHDB=true
				;;
			--paid)
				echo "Configured to setup a paid storage on ibm-cs"
				PAID=true
				;;
		esac
		shift
	done
}

Parse_Arguments $@

if [ "${PAID}" == "true" ]; then
	OFFERING="paid"
else
	OFFERING="free"
fi

echo "Deleting composer-identity-import pod"
echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/composer-identity-import.yaml"
kubectl delete -f ${KUBECONFIG_FOLDER}/composer-identity-import.yaml

while [ "$(kubectl get svc | grep composer-identity-import | wc -l | awk '{print $1}')" != "0" ]; do
	echo "Waiting for composer-identity-import pod to be deleted"
	sleep 1;
done

echo "Deleting Composer Playground pod"
echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/composer-playground.yaml"
kubectl delete -f ${KUBECONFIG_FOLDER}/composer-playground.yaml

while [ "$(kubectl get deployments | grep composer-playground | wc -l | awk '{print $1}')" != "0" ]; do
	echo "Waiting for composer-playground deployment to be deleted"
	sleep 1;
done

echo "Deleting Composer Playground services"
echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/composer-playground-services-${OFFERING}.yaml"
kubectl delete -f ${KUBECONFIG_FOLDER}/composer-playground-services-${OFFERING}.yaml

while [ "$(kubectl get svc | grep composer-playground | wc -l | awk '{print $1}')" != "0" ]; do
	echo "Waiting for composer-playground service to be deleted"
	sleep 1;
done

echo "Composer Playground is deleted"
