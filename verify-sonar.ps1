# Script de verification de la configuration SonarCloud
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Verification Configuration SonarCloud" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verifier les proprietes dans pom.xml
Write-Host "[1] Verification du pom.xml..." -ForegroundColor Yellow
$pomContent = Get-Content "pom.xml" -Raw

$organization = if ($pomContent -match '<sonar\.organization>([^<]+)</sonar\.organization>') { $matches[1] } else { "NON TROUVE" }
$projectKey = if ($pomContent -match '<sonar\.projectKey>([^<]+)</sonar\.projectKey>') { $matches[1] } else { "NON TROUVE" }
$hostUrl = if ($pomContent -match '<sonar\.host\.url>([^<]+)</sonar\.host\.url>') { $matches[1] } else { "NON TROUVE" }

Write-Host "   Organization: $organization" -ForegroundColor Green
Write-Host "   Project Key: $projectKey" -ForegroundColor Green
Write-Host "   Host URL: $hostUrl" -ForegroundColor Green
Write-Host ""

# 2. Verifier le token
Write-Host "[2] Information sur le token SonarCloud..." -ForegroundColor Yellow
$token = "5663f27cb70d07c457501f90a9555f8b8aa97386"
Write-Host "   Token fourni (10 premiers caracteres): $($token.Substring(0,10))..." -ForegroundColor Green
Write-Host ""

# 3. Test de connexion a SonarCloud
Write-Host "[3] Test de connexion a SonarCloud..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://sonarcloud.io/api/system/status" -Method GET -TimeoutSec 10 -UseBasicParsing
    Write-Host "   SonarCloud est accessible" -ForegroundColor Green
}
catch {
    Write-Host "   Impossible de se connecter a SonarCloud" -ForegroundColor Red
}
Write-Host ""

# 4. Verifier si le projet existe
Write-Host "[4] Verification de l'existence du projet..." -ForegroundColor Yellow
$base64Token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${token}:"))
$headers = @{
    "Authorization" = "Basic $base64Token"
}

try {
    $projectUrl = "https://sonarcloud.io/api/projects/search?organization=$organization&q=$projectKey"
    $projectResponse = Invoke-RestMethod -Uri $projectUrl -Headers $headers -Method GET -TimeoutSec 10

    if ($projectResponse.components.Count -gt 0) {
        Write-Host "   Le projet existe sur SonarCloud !" -ForegroundColor Green
    }
    else {
        Write-Host "   Le projet N'EXISTE PAS sur SonarCloud" -ForegroundColor Red
        Write-Host ""
        Write-Host "   SOLUTION: Creer le projet manuellement" -ForegroundColor Magenta
        Write-Host "   1. Allez sur: https://sonarcloud.io" -ForegroundColor White
        Write-Host "   2. Connectez-vous avec votre compte" -ForegroundColor White
        Write-Host "   3. Cliquez sur '+' puis 'Analyze new project'" -ForegroundColor White
        Write-Host "   4. Selectionnez 'Create project manually'" -ForegroundColor White
        Write-Host "   5. Remplissez:" -ForegroundColor White
        Write-Host "      - Organization: $organization" -ForegroundColor Cyan
        Write-Host "      - Project key: $projectKey" -ForegroundColor Cyan
        Write-Host "      - Display name: devops-lab" -ForegroundColor Cyan
        Write-Host "   6. Cliquez sur 'Set Up'" -ForegroundColor White
    }
}
catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 401) {
        Write-Host "   Token invalide ou expire" -ForegroundColor Red
        Write-Host "   Allez sur: https://sonarcloud.io/account/security" -ForegroundColor Yellow
        Write-Host "   pour generer un nouveau token" -ForegroundColor Yellow
    }
    else {
        Write-Host "   Erreur lors de la verification: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""

# 5. Verifier JAVA_HOME
Write-Host "[5] Verification de JAVA_HOME..." -ForegroundColor Yellow
$javaHome = $env:JAVA_HOME
if ($javaHome) {
    Write-Host "   JAVA_HOME: $javaHome" -ForegroundColor Green
    try {
        $javaExe = Join-Path $javaHome "bin\java.exe"
        if (Test-Path $javaExe) {
            $javaVersion = & $javaExe -version 2>&1 | Select-Object -First 1
            Write-Host "   Java version: $javaVersion" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "   Impossible de verifier la version Java" -ForegroundColor Yellow
    }
}
else {
    Write-Host "   JAVA_HOME n'est pas defini" -ForegroundColor Red
    Write-Host "   Executez: " -ForegroundColor Yellow
    Write-Host "   Set-Variable -Name JAVA_HOME -Value C:\Users\seifa\.jdks\ms-21.0.8" -ForegroundColor Cyan
}
Write-Host ""

# Resume
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  RESUME" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Configuration dans pom.xml:" -ForegroundColor White
Write-Host "  Organization: " -NoNewline -ForegroundColor White
Write-Host "$organization" -ForegroundColor Cyan
Write-Host "  Project Key: " -NoNewline -ForegroundColor White
Write-Host "$projectKey" -ForegroundColor Cyan
Write-Host "  Host URL: " -NoNewline -ForegroundColor White
Write-Host "$hostUrl" -ForegroundColor Cyan
Write-Host ""

Write-Host "===============================================" -ForegroundColor Cyan

