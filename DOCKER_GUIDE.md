# Guide Docker pour demo-devops

## 📦 Fichiers Docker créés

- **Dockerfile** : Configuration pour construire l'image Docker de l'application
- **.dockerignore** : Fichiers à exclure lors du build Docker
- **docker-compose.yml** : Configuration pour orchestrer l'application avec MySQL

## 🚀 Commandes Docker

### 1. Construire l'image Docker

```powershell
docker build -t demo-devops:latest .
```

### 2. Exécuter le conteneur seul

```powershell
docker run -d -p 8080:8080 --name demo-devops-app demo-devops:latest
```

### 3. Utiliser Docker Compose (Recommandé)

#### Démarrer tous les services (app + MySQL)
```powershell
docker-compose up -d
```

#### Voir les logs
```powershell
docker-compose logs -f
```

#### Arrêter les services
```powershell
docker-compose down
```

#### Arrêter et supprimer les volumes
```powershell
docker-compose down -v
```

### 4. Commandes utiles

#### Lister les conteneurs en cours d'exécution
```powershell
docker ps
```

#### Accéder au conteneur
```powershell
docker exec -it demo-devops-app sh
```

#### Voir les logs de l'application
```powershell
docker logs -f demo-devops-app
```

#### Voir les logs MySQL
```powershell
docker logs -f demo-devops-mysql
```

## 🔗 URLs d'accès

Après le démarrage avec Docker Compose :

- **Application** : http://localhost:8081
- **Swagger UI** : http://localhost:8081/swagger-ui.html
- **API Docs** : http://localhost:8081/v3/api-docs
- **MySQL** : localhost:3306

## 🔧 Configuration MySQL

Lors de l'utilisation de Docker Compose :

- **Host** : mysql (nom du service)
- **Port** : 3306
- **Database** : demo_devops
- **Username** : devops_user
- **Password** : devops_password
- **Root Password** : rootpassword

## 📝 Structure du Dockerfile

Le Dockerfile utilise une approche multi-stage :

1. **Stage Build** : Utilise Maven pour compiler et packager l'application
2. **Stage Runtime** : Utilise une image JRE légère pour exécuter l'application

### Avantages :
- Image finale plus légère (~200 MB au lieu de 700+ MB)
- Meilleure sécurité (pas d'outils de build en production)
- Build reproductible

## 🔐 Sécurité

- L'application s'exécute avec un utilisateur non-root (`spring`)
- Health check configuré pour surveiller l'état de l'application
- Variables d'environnement pour les configurations sensibles

## 🐛 Dépannage

### L'application ne démarre pas
```powershell
# Vérifier les logs
docker-compose logs app

# Vérifier que MySQL est prêt
docker-compose logs mysql
```

### Reconstruire l'image
```powershell
docker-compose up -d --build
```

### Nettoyer complètement
```powershell
docker-compose down -v
docker system prune -a
```

## 🔄 Intégration avec Jenkins

Pour intégrer Docker dans votre pipeline Jenkins, ajoutez ces étapes dans le Jenkinsfile :

```groovy
stage('Build Docker Image') {
    steps {
        script {
            docker.build("demo-devops:${BUILD_NUMBER}")
        }
    }
}

stage('Push Docker Image') {
    steps {
        script {
            docker.withRegistry('https://registry.hub.docker.com', 'docker-credentials') {
                docker.image("demo-devops:${BUILD_NUMBER}").push()
                docker.image("demo-devops:${BUILD_NUMBER}").push('latest')
            }
        }
    }
}
```

## 📊 Monitoring

Le Dockerfile inclut un health check qui vérifie :
- L'endpoint `/actuator/health` toutes les 30 secondes
- Timeout de 3 secondes
- 3 tentatives avant de marquer le conteneur comme unhealthy

Pour vérifier la santé du conteneur :
```powershell
docker inspect --format='{{.State.Health.Status}}' demo-devops-app
```
