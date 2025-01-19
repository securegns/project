echo
echo "Labeling namespaces here..."
kubectl label namespace dev name=dev   --overwrite
kubectl label namespace uat name=uat   --overwrite
kubectl label namespace prod name=prod --overwrite

echo
echo "Applying NetworkPolicies here to block dev and prod thing"
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-only-dev-and-uat
  namespace: dev
spec:
  podSelector:
    matchLabels: {}
  policyTypes:
  - Ingress
  ingress:
    - from:
      - namespaceSelector:
          matchLabels:
            name: dev
      - namespaceSelector:
          matchLabels:
            name: uat
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-only-prod-and-uat
  namespace: prod
spec:
  podSelector:
    matchLabels: {}
  policyTypes:
  - Ingress
  ingress:
    - from:
      - namespaceSelector:
          matchLabels:
            name: prod
      - namespaceSelector:
          matchLabels:
            name: uat
EOF

echo
echo ""
echo "2. 'dev' net policy allows  from dev+uat and now blocks prod->dev."
