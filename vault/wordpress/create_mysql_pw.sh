#! /bin/bash

# this is script to call the secret injected in the busybox, and create secret object out of it for wordpress

echo "create secret object for wordpress"
POD_NAME=$(kubectl -n app get pods -l app=busybox-mysql-secret -o jsonpath='{.items[0].metadata.name}')
SECRET_FILE=$(kubectl -n app exec "$POD_NAME" -- sh -c 'cat /vault/secrets/mysql')
VALUE=$(echo "$SECRET_FILE" | jq -r '.password')
kubectl create secret generic wordpress-secret --namespace=app --from-literal=mysql-password=$VALUE

# create file for the secret manifest
touch ./vault/wordpress/wordpress-secret.yaml
kubectl get secret/wordpress-secret -n app -o yaml > ./vault/wordpress/wordpress-secret.yaml

# delete the busybox helper
kubectl delete  -n app -f vault/wordpress/1-busybox.yaml