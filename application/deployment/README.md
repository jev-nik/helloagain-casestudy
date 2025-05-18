export AWS_ACCOUNT_ID=

envsubst < cors-proxy-deployment.yaml | kubectl apply -f -

Für Proxy Ingress:
kubectl apply -f cors-proxy-ingress.yaml

Warten bis provisioniert und dann URL holen:
kubectl get ingress cors-proxy-ingress -n default