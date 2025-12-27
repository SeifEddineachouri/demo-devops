# Script pour pousser vers GitHub
Write-Host "=== Pushing to GitHub: devops-lab ===" -ForegroundColor Cyan

# Configuration
$repoUrl = "https://github.com/SeifEddineachouri/devops-lab.git"

# Étape 1: Vérifier Git
Write-Host "`n[1/6] Checking Git installation..." -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host "✓ Git found: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Git not found. Please install Git first." -ForegroundColor Red
    exit 1
}

# Étape 2: Initialiser le repo si nécessaire
Write-Host "`n[2/6] Initializing repository..." -ForegroundColor Yellow
if (-not (Test-Path ".git")) {
    git init
    Write-Host "✓ Repository initialized" -ForegroundColor Green
} else {
    Write-Host "✓ Repository already initialized" -ForegroundColor Green
}

# Étape 3: Configurer le remote
Write-Host "`n[3/6] Configuring remote..." -ForegroundColor Yellow
$existingRemote = git remote get-url origin 2>$null
if ($existingRemote) {
    git remote set-url origin $repoUrl
    Write-Host "✓ Remote updated to: $repoUrl" -ForegroundColor Green
} else {
    git remote add origin $repoUrl
    Write-Host "✓ Remote added: $repoUrl" -ForegroundColor Green
}

# Étape 4: Ajouter tous les fichiers
Write-Host "`n[4/6] Adding files..." -ForegroundColor Yellow
git add -A
$status = git status --short
if ($status) {
    Write-Host "✓ Files added:" -ForegroundColor Green
    $status | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
} else {
    Write-Host "✓ No changes to add" -ForegroundColor Green
}

# Étape 5: Commit
Write-Host "`n[5/6] Creating commit..." -ForegroundColor Yellow
$commitMsg = @"
feat: Add SonarCloud and GitHub Actions CI/CD

- Replace @MockBean with @MockitoBean (Spring Boot 3.4+)
- Add @Component to UserStepDefinitions
- Configure Mockito agent for Java 21+
- Fix H2Dialect in test properties
- Add SonarCloud integration with JaCoCo
- Create GitHub Actions workflow
- Add comprehensive documentation
"@

git commit -m $commitMsg 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Commit created successfully" -ForegroundColor Green
} else {
    Write-Host "ℹ No changes to commit or already committed" -ForegroundColor Cyan
}

# Renommer la branche en main
git branch -M main

# Étape 6: Push vers GitHub
Write-Host "`n[6/6] Pushing to GitHub..." -ForegroundColor Yellow
Write-Host "Repository: $repoUrl" -ForegroundColor Gray
Write-Host ""

# Demander confirmation
$confirm = Read-Host "Continue with push? (Y/n)"
if ($confirm -eq "" -or $confirm -eq "Y" -or $confirm -eq "y") {
    Write-Host "Pushing..." -ForegroundColor Yellow
    git push -u origin main --force 2>&1 | ForEach-Object {
        Write-Host $_ -ForegroundColor Gray
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✓ Successfully pushed to GitHub!" -ForegroundColor Green
        Write-Host "`nNext steps:" -ForegroundColor Cyan
        Write-Host "1. Go to: https://github.com/SeifEddineachouri/devops-lab" -ForegroundColor White
        Write-Host "2. Configure SONAR_TOKEN secret in GitHub Actions" -ForegroundColor White
        Write-Host "3. Check Actions tab for workflow execution" -ForegroundColor White
    } else {
        Write-Host "`n✗ Push failed. Please check your credentials." -ForegroundColor Red
        Write-Host "You may need to:" -ForegroundColor Yellow
        Write-Host "- Configure Git credentials: git config credential.helper store" -ForegroundColor White
        Write-Host "- Use a Personal Access Token instead of password" -ForegroundColor White
    }
} else {
    Write-Host "`nPush cancelled." -ForegroundColor Yellow
}

Write-Host "`n=== Done ===" -ForegroundColor Cyan

