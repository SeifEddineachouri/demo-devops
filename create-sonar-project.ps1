# Script pour créer automatiquement le projet SonarCloud
$token = "5663f27cb70d07c457501f90a9555f8b8aa97386"
$organization = "seifeddineachouri"
$projectKey = "seifeddineachouri_demo-devops"
$projectName = "demo-devops"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Creation du projet SonarCloud" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Créer l'en-tête d'autorisation
$base64Token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${token}:"))
$headers = @{
    "Authorization" = "Basic $base64Token"
    "Content-Type" = "application/x-www-form-urlencoded"
}

Write-Host "[1] Verification de l'existence du projet..." -ForegroundColor Yellow
try {
    $checkUrl = "https://sonarcloud.io/api/projects/search?organization=$organization&q=$projectKey"
    $response = Invoke-RestMethod -Uri $checkUrl -Headers $headers -Method GET

    if ($response.components.Count -gt 0) {
        Write-Host "   Le projet existe deja sur SonarCloud !" -ForegroundColor Green
        Write-Host ""
        Write-Host "Vous pouvez maintenant executer:" -ForegroundColor White
        Write-Host ".\mvnw.cmd clean verify sonar:sonar -Dsonar.token=$token" -ForegroundColor Green
        exit 0
    }
}
catch {
    Write-Host "   Le projet n'existe pas encore" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[2] Creation du projet sur SonarCloud..." -ForegroundColor Yellow

try {
    $createUrl = "https://sonarcloud.io/api/projects/create"
    $body = @{
        organization = $organization
        project = $projectKey
        name = $projectName
    }

    $bodyString = ($body.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&"

    $createResponse = Invoke-RestMethod -Uri $createUrl -Headers $headers -Method POST -Body $bodyString

    Write-Host "   Projet cree avec succes !" -ForegroundColor Green
    Write-Host "   - Project Key: $projectKey" -ForegroundColor Cyan
    Write-Host "   - Organization: $organization" -ForegroundColor Cyan
    Write-Host "   - Name: $projectName" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "[3] Configuration de la visibilite..." -ForegroundColor Yellow
    try {
        $visibilityUrl = "https://sonarcloud.io/api/projects/update_visibility"
        $visibilityBody = @{
            project = $projectKey
            visibility = "public"
        }
        $visibilityBodyString = ($visibilityBody.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&"
        Invoke-RestMethod -Uri $visibilityUrl -Headers $headers -Method POST -Body $visibilityBodyString -ErrorAction SilentlyContinue | Out-Null
        Write-Host "   Visibilite configuree" -ForegroundColor Green
    }
    catch {
        Write-Host "   Configuration de visibilite ignoree" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  SUCCES !" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Le projet a ete cree sur SonarCloud !" -ForegroundColor Green
    Write-Host "URL du projet: https://sonarcloud.io/project/overview?id=$projectKey" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Prochaine etape:" -ForegroundColor White
    Write-Host "Executez la commande Maven pour envoyer l'analyse:" -ForegroundColor White
    Write-Host ""
    Write-Host "  `$env:JAVA_HOME = `"C:\Users\`$env:USERNAME\.jdks\ms-21.0.8`"" -ForegroundColor Green
    Write-Host "  `$env:PATH = `"`$env:JAVA_HOME\bin;`$env:PATH`"" -ForegroundColor Green
    Write-Host "  .\mvnw.cmd clean verify sonar:sonar -Dsonar.token=$token" -ForegroundColor Green
    Write-Host ""
}
catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $errorMessage = $_.Exception.Message

    Write-Host "   Erreur lors de la creation du projet" -ForegroundColor Red
    Write-Host ""

    if ($statusCode -eq 401) {
        Write-Host "ERREUR: Token invalide ou expire" -ForegroundColor Red
        Write-Host ""
        Write-Host "Solution:" -ForegroundColor Yellow
        Write-Host "1. Allez sur: https://sonarcloud.io/account/security" -ForegroundColor White
        Write-Host "2. Generez un nouveau token" -ForegroundColor White
        Write-Host "3. Mettez a jour le token dans ce script" -ForegroundColor White
    }
    elseif ($statusCode -eq 403) {
        Write-Host "ERREUR: Permissions insuffisantes" -ForegroundColor Red
        Write-Host ""
        Write-Host "Solution:" -ForegroundColor Yellow
        Write-Host "1. Verifiez que vous etes administrateur de l'organisation '$organization'" -ForegroundColor White
        Write-Host "2. Le token doit avoir les permissions 'Administer' sur l'organisation" -ForegroundColor White
    }
    elseif ($statusCode -eq 400) {
        Write-Host "ERREUR: Requete invalide" -ForegroundColor Red
        Write-Host "Details: $errorMessage" -ForegroundColor White
        Write-Host ""
        Write-Host "Le projet existe peut-etre deja. Verifiez sur:" -ForegroundColor Yellow
        Write-Host "https://sonarcloud.io/organizations/$organization/projects" -ForegroundColor Cyan
    }
    else {
        Write-Host "Erreur HTTP $statusCode : $errorMessage" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  SOLUTION MANUELLE" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Creez le projet manuellement:" -ForegroundColor White
    Write-Host "1. Allez sur: https://sonarcloud.io/projects/create" -ForegroundColor White
    Write-Host "2. Selectionnez 'Create project manually'" -ForegroundColor White
    Write-Host "3. Remplissez:" -ForegroundColor White
    Write-Host "   - Organization: $organization" -ForegroundColor Cyan
    Write-Host "   - Project Key: $projectKey" -ForegroundColor Cyan
    Write-Host "   - Display Name: $projectName" -ForegroundColor Cyan
    Write-Host "4. Cliquez sur 'Create project'" -ForegroundColor White
    Write-Host ""
}

