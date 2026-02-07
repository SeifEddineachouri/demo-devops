# 🐳 Docker-in-Docker pour Jenkins

## 🔴 Problème rencontré

```
docker: not found
```

Votre Jenkins tourne dans un conteneur Docker, mais **Docker n'est pas disponible à l'intérieur** du conteneur Jenkins.

## ✅ Solution 1 : Utiliser Jenkinsfile.linux (Recommandé)

Le fichier **Jenkinsfile.linux** a été créé sans dépendance à Docker. Il utilise Maven Wrapper uniquement.

### Pour l'utiliser :

1. Dans Jenkins, allez dans la configuration du job
2. Section **Pipeline** → **Script Path** : Changez `Jenkinsfile.docker` en `Jenkinsfile.linux`
3. **Save** et **Build Now**

**Avantages :**
- ✅ Pas besoin de Docker
- ✅ Plus simple et rapide
- ✅ Utilise Maven Wrapper (inclus dans le projet)
- ✅ Fonctionne immédiatement

## ✅ Solution 2 : Activer Docker-in-Docker (Avancé)

Si vous avez besoin de Docker pour construire des images dans Jenkins, vous devez recréer le conteneur Jenkins avec Docker.

### Étape 1 : Arrêter et supprimer le conteneur Jenkins actuel

```powershell
docker stop jenkins
docker rm jenkins
```

### Étape 2 : Créer un nouveau conteneur Jenkins avec Docker

```powershell
docker run -d `
  --name jenkins `
  --privileged `
  -p 8080:8080 `
  -p 50000:50000 `
  -v jenkins_home:/var/jenkins_home `
  -v /var/run/docker.sock:/var/run/docker.sock `
  jenkins/jenkins:lts
```

**Explications :**
- `--privileged` : Donne les privilèges nécessaires pour Docker
- `-v /var/run/docker.sock:/var/run/docker.sock` : Monte le socket Docker de l'hôte dans le conteneur

### Étape 3 : Installer Docker dans le conteneur Jenkins

```powershell
# Entrer dans le conteneur
docker exec -it jenkins bash

# Installer Docker CLI
apt-get update
apt-get install -y docker.io

# Donner les permissions à l'utilisateur jenkins
usermod -aG docker jenkins

# Quitter le conteneur
exit
```

### Étape 4 : Redémarrer Jenkins

```powershell
docker restart jenkins
```

### Étape 5 : Tester Docker

Dans Jenkins, créez un Pipeline de test :

```groovy
pipeline {
    agent any
    stages {
        stage('Test Docker') {
            steps {
                sh 'docker --version'
                sh 'docker ps'
            }
        }
    }
}
```

## ✅ Solution 3 : Utiliser un agent Docker externe (Production)

Pour la production, il est recommandé d'utiliser un agent Jenkins séparé avec Docker installé.

### Jenkinsfile avec agent Docker externe :

```groovy
pipeline {
    agent {
        docker {
            image 'maven:3.9.6-eclipse-temurin-17'
            args '-v $HOME/.m2:/root/.m2'
        }
    }
    // ... reste du pipeline
}
```

**Note :** Cette approche nécessite que Docker soit disponible sur le serveur Jenkins.

## 📊 Comparaison des solutions

| Solution | Complexité | Docker requis | Build d'images | Recommandé pour |
|----------|------------|---------------|----------------|-----------------|
| **Jenkinsfile.linux** | ⭐ Simple | ❌ Non | ❌ Non | Débutants, tests |
| **Docker-in-Docker** | ⭐⭐⭐ Avancé | ✅ Oui | ✅ Oui | Production avec CI/CD complet |
| **Agent Docker externe** | ⭐⭐ Moyen | ✅ Oui | ✅ Oui | Production avec infrastructure séparée |

## 🎯 Recommandation

**Pour votre cas :**
1. Utilisez **Jenkinsfile.linux** maintenant pour faire fonctionner le pipeline
2. Plus tard, si vous avez besoin de construire des images Docker dans le pipeline, passez à **Docker-in-Docker**

## 📝 Configuration Jenkins après installation de Docker

Si vous choisissez Docker-in-Docker, vous devez aussi :

1. **Installer le plugin Docker Pipeline** dans Jenkins :
   - Dashboard → Manage Jenkins → Manage Plugins
   - Onglet Available → Rechercher "Docker Pipeline"
   - Installer et redémarrer Jenkins

2. **Configurer Docker dans Jenkins** :
   - Dashboard → Manage Jenkins → Manage Nodes and Clouds → Configure Clouds
   - Add a new cloud → Docker
   - Docker Host URI : `unix:///var/run/docker.sock`

## 🔍 Vérification

Après configuration, testez que Docker fonctionne :

```groovy
pipeline {
    agent any
    stages {
        stage('Docker Version') {
            steps {
                sh 'docker --version'
                sh 'docker info'
            }
        }
    }
}
```

## 📚 Fichiers disponibles

- **Jenkinsfile** - Version Windows avec Maven Wrapper (bat)
- **Jenkinsfile.linux** - Version Linux avec Maven Wrapper (sh) - **SANS Docker** ✅
- **Jenkinsfile.docker** - Version avec tools Maven/JDK configurés

Utilisez **Jenkinsfile.linux** pour résoudre immédiatement votre problème !
