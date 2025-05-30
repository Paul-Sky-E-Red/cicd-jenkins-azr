# cicd-jenkins-azr
CI/CD pipeline example

Für Schüler:
Installation CI/CD

1. Repo in Github erstellen, z.B. Name: `<dein-name>-cicd` (oder du forkst einfach dieses Repo hier)
2. Jenkins Pipeline in Jenkins im Ordner Kurs 1 erstellen, z.B. Name: `<dein-name>-cicd`
3. Pipeline entsprechend anpassen sodass dein Repo in Github referenziert wird. Wichtig, in Zeile 7 `DOCKERIMAGE`, pass hier deinen Namen an
4. Am Ende der Ausgabe werden zwei Kubernetes Manifests generiert und als Text ausgegeben. Diese benötigen wir gleich
5. Nun benötigt ihr die Kubeconfig vom Lehrer um auf das Kubernetes Cluster zugreifen zu können (Anleitung Lehrer Installation Infrasturktur: Schritt 8)
6. Die beiden YAML's aus Schritt 4 per `kubectl apply -f <datei>` ausrollen
5. Kontrolliere ob dein Container läuft mit: `kubectl get pods -n <dein-name>`oder `kubectl describe pod <dein-name>-sky-webapp -n <dein-name>`
6. Wenn dein Container läuft solltest du ihn nun auch aus dem Internet erreichen können


Für Lehrer:
Installation Infrastruktur

1. Azure AZR erstellen:
```
az login
az acr create --resource-group DevOps-Kurs-RG --name tempregistrykurs1 --sku Standard --role-assignment-mode 'rbac-abac'
```
2. Zwei Credentials für diese neue Registry in Azure erzeugen (einmal push Berechtigungen für Jenkins, einmal pull Berechtigungen für k8s)
3. Azure AZR Credentials in Jenkins im Ordner Kurs_1 hinterlegen, sodass dieses in den Projekten verwendet werden kann
4. Testen ob die Credentials funktionieren und man ein Images pushen kann
5. VM in Azure erzeugen (für k3s-master01)
```
az network vnet create --address-prefixes 10.0.0.0/16 --name kurs1-vnet --resource-group DevOps-Kurs-RG --subnet-name kurs1-sub-a --subnet-prefixes 10.0.0.0/24
az network nsg create --resource-group DevOps-Kurs-RG --name kurs1-nsg
az network vnet subnet update --resource-group DevOps-Kurs-RG --vnet-name kurs1-vnet --name kurs1-sub-a --network-security-group kurs1-nsg
az network nsg rule create -g DevOps-Kurs-RG --nsg-name kurs1-nsg -n allow-k3s-in --priority 4096 --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 22 80 443 6443 --access Allow --protocol Tcp --description "Allow in from Internet to k3s"
az vm create --size Standard_B2s --resource-group DevOps-Kurs-RG --name k3s-master01 --image Debian11 --vnet-name kurs1-vnet --subnet kurs1-sub-a --public-ip-address-dns-name k3s-master01 --generate-ssh-keys --output json --verbose
```
6. VM mit dem Ansible Playbook einrichten
7. Kubernetes testen
8. Jeden Kursuser einzeln mit dem Skript `infrastructure/k8s/create-user.sh` provisionieren und zur Verfügung stellen
9. Lets Encrypt einrichten, YAML `infrastructure/k8s/cert-manager.yaml` anpassen und ausrollen  


