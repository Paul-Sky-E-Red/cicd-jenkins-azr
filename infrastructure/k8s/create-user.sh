#!/bin/bash
set -e

echo "Welcome to the Kubernetes user creation script!"
echo "Createing a new user in kubernetes with appropriate permissions and kubeconfig"
echo "This script assumes that you have kubectl installed and configured to access your k3s cluster."
echo "Cheking if kubectl is installed and k3s is reachable..."

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
  echo "kubectl could not be found. Please install kubectl and try again."
  exit 1
fi

# Smoketest the kubeconfig file
echo "Testing the default kubeconfig file..."
kubectl get nodes
if [ $? -ne 0 ]; then
  echo "Error: Could not connect to the Kubernetes cluster with the default kubeconfig file."
  exit 1
fi

echo "kubectl is installed and k3s is reachable. Proceeding with user creation..."
echo "##########################################"

echo "Please enter the username:"
read USERNAME
echo "Okay, $USERNAME, let's create your user in Kubernetes."

# create a ssl certificate for the user
openssl genrsa -out certs/$USERNAME.key 2048
# create a certificate signing request (CSR)
openssl req -new -key certs/$USERNAME.key -out certs/$USERNAME.csr -subj "/CN=$USERNAME"
# encode base64
cat certs/$USERNAME.csr | base64 | tr -d "\n" > certs/$USERNAME-base64.csr

# Submit the CSR to the Kubernetes API server
echo "Certificate Signing Request (CSR) created for user $USERNAME."

kubectl apply -f - <<EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $USERNAME
spec:
  groups:
  - system:authenticated  
  request: $(cat certs/$USERNAME-base64.csr)
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 864000  # ten days
  usages:
  - client auth
EOF

echo "Sleep for 30 seconds to allow the CSR to be processed..."
sleep 30

# Approve the CSR
kubectl certificate approve $USERNAME

# wait for the CSR to be approved
echo "Waiting for the CSR to be approved..."

# check if the CSR is approved
while true; do
  STATUS=$(kubectl get csr $USERNAME -o jsonpath='{.status.conditions[?(@.type=="Approved")].status}')
  if [ "$STATUS" == "True" ]; then
    echo "CSR approved"
    break
  else
    echo "$STATUS"
    echo "Waiting for CSR to be approved..."
    sleep 5
  fi
done

# Get the csr and extract the certificate
kubectl get csr $USERNAME -o jsonpath='{.status.certificate}' | base64 --decode > certs/$USERNAME.crt

# Create a kubeconfig file for the user
echo "Creating kubeconfig file for user $USERNAME..."

# Replace PUBLICIP with the actual public IP of your k3s server - k3s was setted up with public ip as the internal ip 
PUBLICIP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
if [ -z "$PUBLICIP" ]; then
  echo "Error: Could not find the public IP of the k3s server."
  exit 1
fi
echo "Public IP of k3s server: $PUBLICIP"

# Create the kubeconfig file
cat << EOF > configs/$USERNAME.conf
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $(kubectl config view --raw -o jsonpath='{.clusters[?(@.name == "default")].cluster.certificate-authority-data}')
    server: https://$PUBLICIP:6443
  name: k3s
contexts:
- context:
    cluster: k3s
    user: $USERNAME
    namespace: $USERNAME
  name: $USERNAME@k3s
current-context: $USERNAME@k3s
kind: Config
preferences: {}
users:
- name: $USERNAME
  user:
    client-certificate-data: $(base64 -i certs/$USERNAME.crt)
    client-key-data: $(base64 -i certs/$USERNAME.key)
EOF

# Create a namespace for the user
kubectl create namespace $USERNAME

# Maybe this is not needed, but it does not hurt
kubectl config set-context --current --namespace=$USERNAME

# Create a role and rolebinding for the user
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: $USERNAME-role
  namespace: $USERNAME
rules:
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: $USERNAME-rolebinding
  namespace: $USERNAME
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: $USERNAME-role
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: $USERNAME
EOF

# Smoketest the kubeconfig file
echo "Testing the kubeconfig file..."
kubectl --kubeconfig=configs/$USERNAME.conf get pods --namespace $USERNAME
if [ $? -ne 0 ]; then
  echo "Error: Could not connect to the Kubernetes cluster with the kubeconfig file."
  exit 1
fi
echo "Kubeconfig file created successfully for user $USERNAME."
echo "You can now use the kubeconfig file '$USERNAME.conf' to access the Kubernetes cluster as user $USERNAME."
