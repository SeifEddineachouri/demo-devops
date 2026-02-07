# Script de vérification de la configuration SonarCloud
# ========================================================

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Vérification Configuration SonarCloud" -ForegroundColor Cyan
Write-Host "===============================================`n" -ForegroundColor Cyan

# 1. Vérifier les propriétés dans pom.xml
Write-Host "[1] Vérification du pom.xml..." -ForegroundColor Yellow
$pomContent = Get-Content "pom.xml" -Raw

# Extraire les propriétés SonarCloud
$organization = if ($pomContent -match '<sonar\.organization>([^<]+)</sonar\.organization>') { $matches[1] } else { "NON TROUVÉ" }
$projectKey = if ($pomContent -match '<sonar\.projectKey>([^<]+)</sonar\.projectKey>') { $matches[1] } else { "NON TROUVÉ" }
$hostUrl = if ($pomContent -match '<sonar\.host\.url>([^<]+)</sonar\.host\.url>') { $matches[1] } else { "NON TROUVÉ" }

Write-Host "   ✓ Organization: $organization" -ForegroundColor Green
Write-Host "   ✓ Project Key: $projectKey" -ForegroundColor Green
Write-Host "   ✓ Host URL: $hostUrl`n" -ForegroundColor Green

# 2. Vérifier le token
Write-Host "[2] Vérification du token SonarCloud..." -ForegroundColor Yellow
$token = "5663f27cb70d07c457501f90a9555f8b8aa97386"
Write-Host "   ✓ Token fourni: $($token.Substring(0,10))...`n" -ForegroundColor Green

# 3. Vérifier la connexion à SonarCloud
Write-Host "[3] Test de connexion à SonarCloud..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://sonarcloud.io/api/system/status" -Method GET -TimeoutSec 10
    Write-Host "   ✓ SonarCloud est accessible`n" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Impossible de se connecter à SonarCloud: $($_.Exception.Message)`n" -ForegroundColor Red
}

# 4. Vérifier si le projet existe sur SonarCloud
Write-Host "[4] Vérification de l'existence du projet..." -ForegroundColor Yellow
$base64Token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${token}:"))
$headers = @{
    "Authorization" = "Basic $base64Token"
}

try {
    $projectUrl = "https://sonarcloud.io/api/projects/search?organization=$organization&q=$projectKey"
    $projectResponse = Invoke-RestMethod -Uri $projectUrl -Headers $headers -Method GET -TimeoutSec 10

    if ($projectResponse.components.Count -gt 0) {
        Write-Host "   ✓ Le projet existe sur SonarCloud !`n" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Le projet N'EXISTE PAS sur SonarCloud`n" -ForegroundColor Red
        Write-Host "   SOLUTION:" -ForegroundColor Magenta
        Write-Host "   ─────────────────────────────────────────────────────" -ForegroundColor Magenta
        Write-Host "   Vous devez créer le projet manuellement :" -ForegroundColor White
        Write-Host "   1. Allez sur: https://sonarcloud.io" -ForegroundColor White
        Write-Host "   2. Connectez-vous avec votre compte" -ForegroundColor White
        Write-Host "   3. Cliquez sur '+' puis 'Analyze new project'" -ForegroundColor White
        Write-Host "   4. Sélectionnez 'Create project manually'" -ForegroundColor White
        Write-Host "   5. Remplissez:" -ForegroundColor White
        Write-Host "      - Organization: $organization" -ForegroundColor Cyan
        Write-Host "      - Project key: $projectKey" -ForegroundColor Cyan
        Write-Host "      - Display name: devops-lab" -ForegroundColor Cyan
        Write-Host "   6. Cliquez sur 'Set Up'`n" -ForegroundColor White
    }
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "   ✗ Token invalide ou expiré`n" -ForegroundColor Red
        Write-Host "   SOLUTION:" -ForegroundColor Magenta
        Write-Host "   ─────────────────────────────────────────────────────" -ForegroundColor Magenta
        Write-Host "   1. Allez sur: https://sonarcloud.io/account/security" -ForegroundColor White
        Write-Host "   2. Générez un nouveau token" -ForegroundColor White
        Write-Host "   3. Mettez à jour votre commande avec le nouveau token`n" -ForegroundColor White
    } else {
        Write-Host "   ✗ Erreur lors de la vérification: $($_.Exception.Message)`n" -ForegroundColor Red
    }
}

# 5. Vérifier JAVA_HOME
Write-Host "[5] Vérification de JAVA_HOME..." -ForegroundColor Yellow
$javaHome = $env:JAVA_HOME
if ($javaHome) {
    Write-Host "   ✓ JAVA_HOME: $javaHome" -ForegroundColor Green
    $javaVersion = & "$javaHome\bin\java.exe" -version 2>&1 | Select-Object -First 1
    Write-Host "   ✓ Java version: $javaVersion`n" -ForegroundColor Green
} else {
    Write-Host "   ✗ JAVA_HOME n'est pas défini" -ForegroundColor Red
    Write-Host "   Exécutez: `$env:JAVA_HOME = 'C:\Users\$env:USERNAME\.jdks\ms-21.0.8'`n" -ForegroundColor Yellow
}

# 6. Résumé
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  RÉSUMÉ" -ForegroundColor Cyan
Write-Host "===============================================`n" -ForegroundColor Cyan

Write-Host "Configuration dans pom.xml:" -ForegroundColor White
Write-Host "  Organization: $organization" -ForegroundColor Cyan
Write-Host "  Project Key: $projectKey" -ForegroundColor Cyan
Write-Host "  Host URL: $hostUrl`n" -ForegroundColor Cyan

Write-Host "Commande à exécuter une fois le projet créé:" -ForegroundColor White
Write-Host "  Set JAVA_HOME and run Maven command" -ForegroundColor Green
Write-Host "  .\mvnw.cmd clean verify sonar:sonar -Dsonar.token=$token`n" -ForegroundColor Green

Write-Host "===============================================`n" -ForegroundColor Cyan

