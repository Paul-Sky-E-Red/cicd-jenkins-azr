# cicd-jenkins-azr

Beispiel für eine CI/CD-Pipeline mit Jenkins, Azure, Docker, Kubernetes und Helm.

---

## Für Schüler: CI/CD Installation

1. **Repository anlegen**  
   Erstelle ein neues GitHub-Repository, z.B. `<dein-name>-cicd`  
   *(Alternativ kannst du dieses Repo forken)*

2. **Jenkins Pipeline erstellen**  
   Lege in Jenkins im Ordner `Kurs 1` eine neue Pipeline an, z.B. `<dein-name>-cicd`.

3. **Pipeline konfigurieren**  
   Passe die Pipeline so an, dass sie auf dein GitHub-Repo zeigt.  
   **Wichtig:** In Zeile 7 der Pipeline `CREATOR` auf deinen Namen setzen.

4. **Manifeste generieren**  
   Am Ende der Jenkins-Ausgabe findest du drei Kubernetes-Manifeste (Flux, Helm, Kubernetes).

5. **Kubeconfig erhalten**  
   Hole dir die Kubeconfig vom Lehrer (siehe unten, Schritt 8).

6. **Deployment**  
   - Entweder Helmcharts verwenden  
   - Oder die Kubernetes-Manifeste per `kubectl apply -f <datei>` ausrollen

7. **Deployment prüfen**  
   Kontrolliere, ob dein Container läuft:
   ```bash
   kubectl get pods
   ```

8. **Webapp aufrufen**  
   Wenn alles läuft, erreichst du deine App z.B. unter:  
   `https://k3s-master01.westus2.cloudapp.azure.com/paul-sky-webapp`

---

## Für Lehrer: Infrastruktur-Installation

1. **Azure Container Registry (ACR) erstellen**
   ```bash
   az login
   az acr create --resource-group DevOps-Kurs-RG --name tempregistrykurs1 --sku Standard --role-assignment-mode 'rbac-abac'
   ```

2. **Zwei Credentials für die Registry erzeugen**  
   - Einmal mit Push-Berechtigung (für Jenkins)
   - Einmal mit Pull-Berechtigung (für Kubernetes)

3. **Azure ACR Credentials in Jenkins hinterlegen**  
   Im Ordner `Kurs_1` ablegen, damit sie in den Projekten genutzt werden können.

4. **Zugang testen**  
   Prüfen, ob ein Image erfolgreich gepusht werden kann.

5. **VM für k3s-Master in Azure erstellen**
   ```bash
   az network vnet create --address-prefixes 10.0.0.0/16 --name kurs1-vnet --resource-group DevOps-Kurs-RG --subnet-name kurs1-sub-a --subnet-prefixes 10.0.0.0/24
   az network nsg create --resource-group DevOps-Kurs-RG --name kurs1-nsg
   az network vnet subnet update --resource-group DevOps-Kurs-RG --vnet-name kurs1-vnet --name kurs1-sub-a --network-security-group kurs1-nsg
   az network nsg rule create -g DevOps-Kurs-RG --nsg-name kurs1-nsg -n allow-k3s-in --priority 4096 --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 22 80 443 6443 --access Allow --protocol Tcp --description "Allow in from Internet to k3s"
   az vm create --size Standard_B2s --resource-group DevOps-Kurs-RG --name k3s-master01 --image Debian11 --vnet-name kurs1-vnet --subnet kurs1-sub-a --public-ip-address-dns-name k3s-master01 --generate-ssh-keys --output json --verbose
   ```

6. **VM mit Ansible einrichten**

7. **Kubernetes testen**

8. **Kursuser provisionieren**  
   Mit dem Skript `infrastructure/k8s/create-user.sh` für jeden Teilnehmer einen User anlegen.

9. **Let's Encrypt einrichten**  
   YAML `infrastructure/k8s/cert-manager.yaml` anpassen und ausrollen.

---

**Viel Erfolg beim Arbeiten mit CI/CD, Jenkins, Azure und Kubernetes!**


