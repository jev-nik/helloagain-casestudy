Für Loadbalancer:
kubectl apply -f aws-load-balancer-controller.yaml
Checks:
kubectl get pods -n kube-system | grep aws-load-balancer-controller
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

Für Autoscaler:
kubectl apply -f cluster-autoscaler.yaml
Check:
kubectl get pods -n kube-system | grep cluster-autoscaler
kubectl get pods -n kube-system -l app=cluster-autoscaler

Für Metrics Server:
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
Check:
kubectl get pods -n kube-system -l k8s-app=metrics-server

Für Proxy Ingress:
kubectl apply -f cors-proxy-ingress.yaml

Für ALB URL:
kubectl get ingress cors-proxy-ingress -o yaml

kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

TEST:
curl http://<ALB_URL>