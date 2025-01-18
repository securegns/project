echo
echo "=== Labeling namespaces ==="
kubectl label namespace dev name=dev   --overwrite
kubectl label namespace uat name=uat   --overwrite
kubectl label namespace prod name=prod --overwrite

echo
echo "=== Applying NetworkPolicies to block dev <-> prod ==="
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
echo "=== Summary: ==="
echo "1. Namespaces 'dev', 'uat', 'prod' created (if not already)."
echo "2. 'dev' netpol allows only from dev+uat => blocks prod->dev."
echo "3. 'prod' netpol allows only from prod+uat => blocks dev->prod."
echo "4. 'uat' has no netpol => open to/from dev and prod."
echo
echo "Done! dev <-> prod are now blocked, dev <-> uat and prod <-> uat remain open."
