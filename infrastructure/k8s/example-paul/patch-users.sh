#!/bin/zsh
set -e

echo "Patching user permissions in Kubernetes..."
for USER in arthur bilal cihat enes hasibullah muhammed stephan talha;do
    echo "Patching permissions for user: $USER"
  kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: $USER-role
  namespace: $USER
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
  name: $USER-rolebinding
  namespace: $USER
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: $USER-role
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: $USER
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: $USER-clusterrolebinding
  namespace: $USER
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kurs1-developer
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: $USER
EOF
    echo "Permissions patched for user: $USER"
    done
