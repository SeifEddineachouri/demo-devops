# 🔐 Configuration du Token SonarCloud dans Jenkins

## 📝 Nouveau Token SonarCloud

**Token** : `72ec22fb9f554cefc0287b4f0e067f7e699ed642`

## 🎯 Configuration dans Jenkins

### Étape 1 : Accéder aux Credentials

1. Ouvrez Jenkins : http://localhost:8080
2. Cliquez sur **Manage Jenkins** (dans le menu de gauche)
3. Cliquez sur **Manage Credentials**
4. Cliquez sur **(global)** sous "Stores scoped to Jenkins"
5. Cliquez sur **Add Credentials** (dans le menu de gauche)

### Étape 2 : Ajouter le Token SonarCloud

Remplissez le formulaire avec ces informations **EXACTES** :

| Champ | Valeur |
|-------|--------|
| **Kind** | Secret text |
| **Scope** | Global (Jenkins, nodes, items, all child items, etc) |
| **Secret** | `72ec22fb9f554cefc0287b4f0e067f7e699ed642` |
| **ID** | `sonar-token` ⚠️ **IMPORTANT : ID exact requis** |
| **Description** | SonarCloud Token for demo-devops |

### ⚠️ ATTENTION : L'ID doit être EXACTEMENT `sonar-token`

Le Jenkinsfile utilise cette ligne :
```groovy
SONAR_TOKEN = credentials('sonar-token')
```

Si l'ID est différent, le pipeline échouera !

### Étape 3 : Sauvegarder

1. Cliquez sur **Create** en bas du formulaire
2. Vous devriez voir le credential apparaître dans la liste

### Étape 4 : Vérifier la configuration

Vous devriez voir dans la liste des credentials :
- **Kind** : Secret text
- **ID** : `sonar-token`
- **Description** : SonarCloud Token for demo-devops

## 🚀 Lancer le Pipeline

### Méthode 1 : Utiliser Jenkinsfile.linux (Recommandé)

1. Dans Jenkins, accédez à votre job **mon-projet-springboot**
2. Cliquez sur **Configure**
3. Section **Pipeline** :
   - **Definition** : Pipeline script from SCM
   - **SCM** : Git
   - **Repository URL** : `https://github.com/SeifEddineachouri/demo-devops.git`
   - **Branch Specifier** : `*/main`
   - **Script Path** : `Jenkinsfile.linux` ⬅️ **Changez ici !**
4. Cliquez sur **Save**
5. Cliquez sur **Build Now**

### Méthode 2 : Créer un nouveau Job

1. **Dashboard** → **New Item**
2. **Enter an item name** : `demo-devops-pipeline`
3. Sélectionnez **Pipeline**
4. Cliquez sur **OK**
5. Dans la configuration :
   - Section **Pipeline** :
     - **Definition** : Pipeline script from SCM
     - **SCM** : Git
     - **Repository URL** : `https://github.com/SeifEddineachouri/demo-devops.git`
     - **Branch Specifier** : `*/main`
     - **Script Path** : `Jenkinsfile.linux`
6. **Save** et **Build Now**

## 📊 Ce que le Pipeline va faire

1. ✅ **Checkout** - Cloner le repository GitHub
2. ✅ **Build** - Compiler avec `./mvnw clean compile`
3. ✅ **Test** - Exécuter les tests avec `./mvnw test`
4. ✅ **Package** - Créer le JAR avec `./mvnw package`
5. ✅ **SonarCloud Analysis** - Analyser le code et envoyer à SonarCloud
6. ✅ **Archive Artifacts** - Sauvegarder le JAR dans Jenkins
7. ✅ **Deploy** - Message de déploiement

## 🔍 Vérification SonarCloud

Après le build réussi, vérifiez les résultats sur SonarCloud :

**URL** : https://sonarcloud.io/dashboard?id=seifeddineachouri_demo-devops

Vous devriez voir :
- Code coverage
- Bugs détectés
- Code smells
- Duplications
- Security hotspots

## 📋 Informations du Projet SonarCloud

| Propriété | Valeur |
|-----------|--------|
| **Organization** | seifeddineachouri |
| **Project Key** | seifeddineachouri_demo-devops |
| **Host URL** | https://sonarcloud.io |
| **Token** | 72ec22fb9f554cefc0287b4f0e067f7e699ed642 |

## 🐛 Dépannage

### Erreur : "credentials('sonar-token') not found"

**Solution :**
1. Vérifiez que l'**ID** du credential est exactement `sonar-token` (pas de majuscules, pas d'espaces)
2. Vérifiez que le credential est dans le domaine **(global)**

### Erreur : "Project not found" sur SonarCloud

**Solution :**
1. Vérifiez que le projet existe sur SonarCloud
2. Vérifiez que le token a les permissions nécessaires
3. Vérifiez que l'organization et projectKey sont corrects dans le Jenkinsfile

### Erreur : "mvnw: not found"

**Solution :**
1. Vérifiez que les fichiers `mvnw` et `.mvn/` sont dans le repository
2. Le pipeline devrait exécuter `chmod +x ./mvnw` automatiquement

## ✅ Checklist avant le build

- [ ] Credential `sonar-token` créé dans Jenkins avec l'ID exact
- [ ] Token SonarCloud correct : `72ec22fb9f554cefc0287b4f0e067f7e699ed642`
- [ ] Job configuré pour utiliser `Jenkinsfile.linux`
- [ ] Repository GitHub accessible : https://github.com/SeifEddineachouri/demo-devops.git
- [ ] Branche `main` existe

## 🎉 Résultat attendu

Si tout est correctement configuré, vous verrez :

```
✅ Checkout - SUCCESS
✅ Build - SUCCESS
✅ Test - SUCCESS
✅ Package - SUCCESS
✅ SonarCloud Analysis - SUCCESS
✅ Archive Artifacts - SUCCESS
✅ Deploy - SUCCESS
```

Et dans la console output finale :
```
✅ Pipeline succeeded!
📊 Check SonarCloud: https://sonarcloud.io/dashboard?id=seifeddineachouri_demo-devops
```

Bonne chance ! 🚀
