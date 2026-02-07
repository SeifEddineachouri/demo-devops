# Script PowerShell pour exécuter l'analyse SonarCloud
# ======================================================

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Analyse SonarCloud - demo-devops" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Configuration de JAVA_HOME
Write-Host "[1] Configuration de Java..." -ForegroundColor Yellow
$env:JAVA_HOME = "C:\Users\$env:USERNAME\.jdks\ms-21.0.8"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

if (Test-Path "$env:JAVA_HOME\bin\java.exe") {
    $javaVersion = & "$env:JAVA_HOME\bin\java.exe" -version 2>&1 | Select-Object -First 1
    Write-Host "   Java configuré: $javaVersion" -ForegroundColor Green
} else {
    Write-Host "   ERREUR: Java non trouvé à $env:JAVA_HOME" -ForegroundColor Red
    Write-Host "   Veuillez vérifier le chemin Java" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Configuration du token SonarCloud
Write-Host "[2] Configuration du token SonarCloud..." -ForegroundColor Yellow
$env:SONAR_TOKEN = "5899ab375b6498dbe0c00d606c350087c214f5b3"
Write-Host "   Token configuré: $($env:SONAR_TOKEN.Substring(0,10))..." -ForegroundColor Green
Write-Host ""

# Exécution de l'analyse
Write-Host "[3] Lancement de l'analyse Maven + SonarCloud..." -ForegroundColor Yellow
Write-Host "   Cette opération peut prendre quelques minutes..." -ForegroundColor Gray
Write-Host ""

# Commande Maven correcte
.\mvnw.cmd clean verify sonar:sonar

# Vérification du résultat
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "  SUCCÈS - Analyse terminée !" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Résultats disponibles sur:" -ForegroundColor White
    Write-Host "https://sonarcloud.io/dashboard?id=seifeddineachouri_demo-devops" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Red
    Write-Host "  ERREUR - L'analyse a échoué" -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Consultez les logs ci-dessus pour plus de détails" -ForegroundColor Yellow
    Write-Host ""
}

