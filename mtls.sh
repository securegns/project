kubectl label namespace dev istio-injection=enabled
kubectl label namespace uat istio-injection=enabled
kubectl label namespace prod istio-injection=enabled

kubectl create deployment httpd-dev --image=httpd -n dev
kubectl create deployment httpd-uat --image=httpd -n uat
kubectl create deployment httpd-prod --image=httpd -n prod

# Expose the deployments as services
kubectl expose deployment httpd-dev --port=80 -n dev --name=httpd-service
kubectl expose deployment httpd-uat --port=80 -n uat --name=httpd-service
kubectl expose deployment httpd-prod --port=80 -n prod --name=httpd-service

# Create curl pods in each namespace
kubectl run -n dev curl-dev --image=curlimages/curl --command -- sleep infinity
kubectl run -n uat curl-uat --image=curlimages/curl --command -- sleep infinity
kubectl run -n prod curl-prod --image=curlimages/curl --command -- sleep infinity


# Enable mTLS in strict mode for each namespace
kubectl apply -n dev -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
EOF

kubectl apply -n uat -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
EOF

kubectl apply -n prod -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
spec:
  mtls:
    mode: STRICT
EOF

# Apply AuthorizationPolicies to control traffic

# In 'dev' namespace, allow ingress only from 'uat'
kubectl apply -n dev -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-uat
spec:
  rules:
  - from:
    - source:
        namespaces: ["uat"]
EOF

# In 'prod' namespace, allow ingress only from 'uat'
kubectl apply -n prod -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-uat
spec:
  rules:
  - from:
    - source:
        namespaces: ["uat"]
EOF
