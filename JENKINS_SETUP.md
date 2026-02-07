# Guide de Configuration Jenkins pour demo-devops

## 🔧 Problème rencontré

Erreur : `Tool type "maven" does not have an install of "Maven 3.9.6" configured`

Cela signifie que Jenkins n'a pas les outils Maven et JDK configurés avec les noms exacts utilisés dans le Jenkinsfile.

## ✅ Solutions proposées

### Solution 1 : Utiliser Maven Wrapper (Recommandé pour Windows)

Le **Jenkinsfile** a été mis à jour pour utiliser `mvnw.cmd` (Maven Wrapper) au lieu de Maven système. 

**Avantages :**
- ✅ Pas besoin de configurer Maven dans Jenkins
- ✅ Version Maven garantie dans le projet
- ✅ Fonctionne sur Windows avec des commandes `bat`

**Le Jenkinsfile actuel utilise cette approche.**

### Solution 2 : Configurer les outils dans Jenkins

Si vous préférez configurer Maven et JDK dans Jenkins :

#### Étape 1 : Configurer JDK

1. Accédez à **Dashboard** → **Manage Jenkins** → **Global Tool Configuration**
2. Scrollez jusqu'à **JDK**
3. Cliquez sur **Add JDK**
4. **Nom** : `JDK 17` (exactement ce nom)
5. Décochez **Install automatically** si vous avez déjà Java installé
6. **JAVA_HOME** : Chemin vers votre installation Java 17 (ex: `C:\Program Files\Java\jdk-17`)
7. Ou cochez **Install automatically** et sélectionnez une version Java 17

#### Étape 2 : Configurer Maven

1. Dans la même page **Global Tool Configuration**
2. Scrollez jusqu'à **Maven**
3. Cliquez sur **Add Maven**
4. **Nom** : `Maven 3.9.6` (exactement ce nom) OU `Maven-3.9` (si vous voyez ce nom suggéré)
5. Cochez **Install automatically**
6. **Version** : Sélectionnez `3.9.6` dans la liste

#### Étape 3 : Sauvegarder

Cliquez sur **Save** en bas de la page.

### Solution 3 : Utiliser Docker Agent (Recommandé pour Linux/Production)

Un fichier **Jenkinsfile.docker** a été créé qui utilise un conteneur Docker Maven.

**Avantages :**
- ✅ Environnement de build isolé et reproductible
- ✅ Pas besoin de configurer Maven/JDK dans Jenkins
- ✅ Portable entre différents environnements

**Pour l'utiliser :**
1. Renommez `Jenkinsfile` en `Jenkinsfile.windows`
2. Renommez `Jenkinsfile.docker` en `Jenkinsfile`
3. Assurez-vous que Docker est installé et accessible depuis Jenkins

## 📋 Credentials requis dans Jenkins

### 1. SONAR_TOKEN

1. Accédez à **Dashboard** → **Manage Jenkins** → **Manage Credentials**
2. Cliquez sur **(global)** domain
3. Cliquez sur **Add Credentials**
4. **Kind** : Secret text
5. **Scope** : Global
6. **Secret** : Collez votre token SonarCloud (`5899ab375b6498dbe0c00d606c350087c214f5b3`)
7. **ID** : `sonar-token` (exactement ce nom)
8. **Description** : SonarCloud Token
9. Cliquez sur **Create**

### 2. GitHub Credentials (optionnel pour private repos)

1. **Kind** : Username with password
2. **Username** : Votre nom d'utilisateur GitHub
3. **Password** : Personal Access Token GitHub
4. **ID** : `github-credentials`
5. **Description** : GitHub Access Token

## 🚀 Créer un Job Jenkins

### Méthode 1 : Pipeline depuis SCM (Recommandé)

1. **Dashboard** → **New Item**
2. **Nom** : `demo-devops`
3. **Type** : Pipeline
4. Cliquez sur **OK**
5. Dans la section **Pipeline** :
   - **Definition** : Pipeline script from SCM
   - **SCM** : Git
   - **Repository URL** : `https://github.com/SeifEddineachouri/demo-devops.git`
   - **Credentials** : (laisser vide si public)
   - **Branch Specifier** : `*/main`
   - **Script Path** : `Jenkinsfile`
6. Cliquez sur **Save**

### Méthode 2 : Multibranch Pipeline

1. **Dashboard** → **New Item**
Choisissez celui qui correspond à votre environnement Jenkins.

- **Jenkinsfile.docker** - Version Docker Agent (pour Linux/Production)
- **Jenkinsfile** - Version Windows avec Maven Wrapper (par défaut)

## 📝 Fichiers disponibles

- Les propriétés dans `pom.xml` correspondent à votre projet SonarCloud
- Le token est valide dans SonarCloud
- Le credential `sonar-token` existe dans Jenkins
Vérifiez que :

### Erreur SonarCloud

- Ajoutez l'utilisateur Jenkins au groupe docker (Linux)
- Vérifiez que Docker est installé sur le serveur Jenkins
Si vous utilisez Jenkinsfile.docker :

### Erreur : "Docker not found"

Assurez-vous que les fichiers `mvnw.cmd` et `.mvn/` sont bien dans le repository.

### Erreur : "mvnw.cmd is not recognized"

## 🐛 Dépannage

3. Observez la console output
2. Cliquez sur **Build Now**
1. Accédez à votre job `demo-devops`

Après configuration, lancez le build :

## 📊 Vérification

4. Cliquez sur **Install without restart**
3. Recherchez et cochez les plugins ci-dessus
2. Onglet **Available**
1. **Dashboard** → **Manage Jenkins** → **Manage Plugins**

### Installation des plugins :

7. **SonarQube Scanner** - Pour l'intégration SonarCloud (optionnel)
6. **Docker Pipeline** - Si vous utilisez Jenkinsfile.docker
5. **JaCoCo Plugin** - Pour la couverture de code
4. **JUnit Plugin** - Pour publier les résultats de tests
3. **Pipeline: Stage View** - Pour visualiser les stages
2. **Pipeline** - Pour exécuter les Jenkinsfiles
1. **Git Plugin** - Pour cloner depuis GitHub

Assurez-vous d'avoir ces plugins installés :

## 🔍 Plugins Jenkins requis

7. Cliquez sur **Save**
   - **Script Path** : `Jenkinsfile`
   - **Mode** : by Jenkinsfile
6. Dans **Build Configuration** :
   - **Credentials** : (si nécessaire)
   - **Project Repository** : `https://github.com/SeifEddineachouri/demo-devops.git`
   - Cliquez sur **Add source** → **Git**
5. Dans **Branch Sources** :
4. Cliquez sur **OK**
3. **Type** : Multibranch Pipeline
2. **Nom** : `demo-devops-multibranch`
