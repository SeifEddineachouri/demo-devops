# 🚀 Guide Rapide - Push vers GitHub

## Commandes à exécuter dans PowerShell

Ouvrez PowerShell dans le répertoire du projet et exécutez ces commandes :

```powershell
# 1. Aller dans le répertoire du projet
cd C:\Users\seifa\Documents\demo-devops

# 2. Vérifier l'état Git
git status

# 3. Ajouter tous les fichiers
git add -A

# 4. Créer un commit
git commit -m "feat: Add SonarCloud and GitHub Actions CI/CD configuration"

# 5. Configurer le remote (si pas déjà fait)
git remote add origin https://github.com/SeifEddineachouri/devops-lab.git

# Ou mettre à jour le remote existant
git remote set-url origin https://github.com/SeifEddineachouri/devops-lab.git

# 6. Renommer la branche en main
git branch -M main

# 7. Pousser vers GitHub
git push -u origin main
```

## En cas d'erreur d'authentification

Si Git demande vos identifiants :

### Option 1: Personal Access Token (Recommandé)
1. Allez sur GitHub.com → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Générez un nouveau token avec les permissions `repo`
3. Utilisez ce token comme mot de passe quand Git le demande

### Option 2: GitHub CLI
```powershell
# Installer GitHub CLI si pas déjà fait
winget install GitHub.cli

# Se connecter
gh auth login

# Puis pusher
git push -u origin main
```

### Option 3: Push avec force (si le repo existe déjà)
```powershell
git push -u origin main --force
```

## Après le push

### 1. Configurer le secret SonarCloud
- Allez sur: https://github.com/SeifEddineachouri/devops-lab/settings/secrets/actions
- Cliquez sur "New repository secret"
- Name: `SONAR_TOKEN`
- Value: `05327ae2bade09a6628873e93562f6c25987c03f`
- Cliquez sur "Add secret"

### 2. Vérifier le workflow GitHub Actions
- Allez sur: https://github.com/SeifEddineachouri/devops-lab/actions
- Vérifiez que le workflow "Build and Test" s'exécute

### 3. Vérifier SonarCloud
- Allez sur: https://sonarcloud.io
- Cherchez votre projet "demo-devops"
- Vérifiez l'analyse de qualité

## Fichiers qui seront poussés

✅ Fichiers modifiés:
- `pom.xml` - Configuration SonarCloud et Mockito
- `src/test/java/.../UserControllerTest.java` - @MockitoBean
- `src/test/java/.../UserStepDefinitions.java` - @Component
- `src/test/resources/application-test.properties` - H2Dialect

✅ Fichiers créés:
- `.github/workflows/build.yml` - GitHub Actions CI/CD
- `.mvn/jvm.config` - Configuration JVM
- `README.md` - Documentation principale
- `GITHUB_SETUP.md` - Guide GitHub
- `SONARCLOUD_CI_CD.md` - Guide SonarCloud
- `MOCKITO_CONFIG.md` - Guide Mockito
- `SUMMARY.md` - Résumé des modifications
- `GIT_COMMANDS.md` - Ce fichier
- `WORKFLOW_DIAGRAM.md` - Diagramme du workflow
- `push-to-github.ps1` - Script PowerShell

## Vérification rapide

Après le push, vérifiez que tout fonctionne :

```powershell
# Vérifier que le push a réussi
git log --oneline -1

# Vérifier le remote
git remote -v

# Vérifier la branche
git branch -a
```

## Aide supplémentaire

Si vous rencontrez des problèmes :

1. **"fatal: remote origin already exists"**
   ```powershell
   git remote remove origin
   git remote add origin https://github.com/SeifEddineachouri/devops-lab.git
   ```

2. **"rejected - non-fast-forward"**
   ```powershell
   git pull origin main --rebase
   # Ou forcer le push (attention: écrase l'historique distant)
   git push -u origin main --force
   ```

3. **Problème d'authentification**
   - Utilisez un Personal Access Token au lieu du mot de passe
   - Ou utilisez GitHub CLI: `gh auth login`

## 🎯 Résultat attendu

Après un push réussi, vous verrez quelque chose comme :

```
Enumerating objects: 50, done.
Counting objects: 100% (50/50), done.
Delta compression using up to 8 threads
Compressing objects: 100% (40/40), done.
Writing objects: 100% (50/50), 25.5 KiB | 2.5 MiB/s, done.
Total 50 (delta 10), reused 0 (delta 0)
To https://github.com/SeifEddineachouri/devops-lab.git
 * [new branch]      main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

Bonne chance ! 🚀

