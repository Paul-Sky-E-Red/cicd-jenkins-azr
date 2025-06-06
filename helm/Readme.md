# Helmcharts – Anleitung

In diesem Ordner lernst du, wie du ein eigenes Helmchart erstellst und auf einem Kubernetes-Cluster installierst.

---

## Voraussetzungen

**Benötigte Tools:**
- **Bash / WSL**
- **kubectl**  
  [Installationsanleitung](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- **helm**  
  [Installationsanleitung](https://helm.sh/docs/intro/install/#from-script)

---

## Einrichtung von kubectl

Stelle sicher, dass `kubectl` installiert ist und auf dein k3s-Cluster zeigt.  
Du hast zwei Möglichkeiten, deine Kubeconfig zu setzen:

### 1. Standard-Kubeconfig verwenden

```bash
cp ~/.kube/config ~/.kube/config.backup
mv ~/Downloads/$USERNAME.conf ~/.kube/config
kubectl get pods
```

### 2. Umgebungsvariable setzen

Passe `$USERNAME` an deinen Benutzernamen an!

```bash
export KUBECONFIG=/home/$USERNAME/Downloads/$USERNAME.conf
kubectl get pods
```

---

## Einrichtung von Helm

Keine besonderen Schritte notwendig – stelle nur sicher, dass Helm installiert ist.

---

## Schritt-für-Schritt-Anleitung

1. **Werte anpassen**  
   Öffne die Datei `webapp/values.yaml` und passe mindestens den Wert  
   ```namespace``` auf deinen Namen an.  
   Teste vorsichtshalber ob deine Kubeconfig noch funktioniert mit ```kubectl get nodes```.

2. **Helmchart template**
   Schaue ob die Syntax in Ordnung ist und ein Helmchart gebaut werden könnte

   ```bash
   cd helm
   helm template webapp --values webapp/values.yaml
   ```

3. **Helmchart bauen**  
   Erstelle ein Helm-Paket mit z.B. folgenden Werten:

   ```bash
   helm package --app-version "1.0.0" --version "1.0.0" webapp
   ```

   Danach findest du eine Datei wie `webapp-1.0.0.tgz` im Ordner.

4. **Dry Run (Testlauf)**  
   Prüfe, ob das Chart korrekt installiert werden kann:

   ```bash
   helm install webapp webapp-1.0.0.tgz -f webapp/values.yaml --dry-run
   ```

5. **Chart installieren**  
   Wenn keine Fehler auftreten, installiere das Chart ohne `--dry-run`:

   ```bash
   helm install webapp webapp-1.0.0.tgz -f webapp/values.yaml
   ```

6. **Deployment prüfen**  
   Überprüfe, ob deine neue Webapp läuft:

   ```bash
   kubectl get pods -n <dein-namespace>
   ```

---

## Hinweise

- Achte darauf, dass der Namespace in `values.yaml` existiert oder lege ihn ggf. an.
- Weitere Infos zu Helm findest du in der [offiziellen Helm-Dokumentation](https://helm.sh/docs/).

---

Viel Erfolg beim Arbeiten mit Helm und Kubernetes!


