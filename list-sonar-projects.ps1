# Script pour lister tous les projets SonarCloud de votre organisation
$token = "5663f27cb70d07c457501f90a9555f8b8aa97386"
$organization = "seifeddineachouri"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Liste des Projets SonarCloud" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Créer l'en-tête d'autorisation
$base64Token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${token}:"))
$headers = @{
    "Authorization" = "Basic $base64Token"
}

try {
    Write-Host "Recuperation des projets de l'organisation '$organization'..." -ForegroundColor Yellow
    Write-Host ""

    $url = "https://sonarcloud.io/api/projects/search?organization=$organization"
    $response = Invoke-RestMethod -Uri $url -Headers $headers -Method GET

    if ($response.components.Count -eq 0) {
        Write-Host "Aucun projet trouve dans l'organisation '$organization'" -ForegroundColor Red
        Write-Host ""
        Write-Host "Verifiez que:" -ForegroundColor Yellow
        Write-Host "1. Vous etes membre de cette organisation" -ForegroundColor White
        Write-Host "2. Le token est valide" -ForegroundColor White
        Write-Host "3. Le nom de l'organisation est correct" -ForegroundColor White
    }
    else {
        Write-Host "Projets trouves: $($response.components.Count)" -ForegroundColor Green
        Write-Host ""
        Write-Host "Liste des projets:" -ForegroundColor White
        Write-Host "─────────────────────────────────────────────────────" -ForegroundColor Gray

        foreach ($project in $response.components) {
            Write-Host ""
            Write-Host "  Nom:  " -NoNewline -ForegroundColor White
            Write-Host $project.name -ForegroundColor Cyan
            Write-Host "  Cle:  " -NoNewline -ForegroundColor White
            Write-Host $project.key -ForegroundColor Green
            Write-Host "  URL:  " -NoNewline -ForegroundColor White
            Write-Host "https://sonarcloud.io/project/overview?id=$($project.key)" -ForegroundColor Gray
        }

        Write-Host ""
        Write-Host "─────────────────────────────────────────────────────" -ForegroundColor Gray
        Write-Host ""

        # Vérifier si le projet demo-devops existe
        $demoProject = $response.components | Where-Object { $_.key -like "*demo-devops*" }

        if ($demoProject) {
            Write-Host "TROUVE: Projet 'demo-devops'" -ForegroundColor Green
            Write-Host ""
            Write-Host "Cle exacte a utiliser dans pom.xml:" -ForegroundColor Yellow
            Write-Host "  <sonar.projectKey>$($demoProject.key)</sonar.projectKey>" -ForegroundColor Cyan
            Write-Host ""

            # Vérifier si la clé correspond
            if ($demoProject.key -eq "seifeddineachouri_demo-devops") {
                Write-Host "La cle dans votre pom.xml est CORRECTE !" -ForegroundColor Green
            }
            else {
                Write-Host "ATTENTION: La cle est differente !" -ForegroundColor Red
                Write-Host "  Pom.xml:  seifeddineachouri_demo-devops" -ForegroundColor White
                Write-Host "  SonarCloud: $($demoProject.key)" -ForegroundColor White
                Write-Host ""
                Write-Host "Mettez a jour votre pom.xml avec la cle correcte" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Le projet 'demo-devops' n'existe PAS" -ForegroundColor Red
            Write-Host ""
            Write-Host "Vous devez creer le projet manuellement:" -ForegroundColor Yellow
            Write-Host "1. Allez sur: https://sonarcloud.io/projects/create" -ForegroundColor White
            Write-Host "2. Selectionnez 'Create project manually'" -ForegroundColor White
            Write-Host "3. Utilisez la cle: seifeddineachouri_demo-devops" -ForegroundColor Cyan
        }
    }

    Write-Host ""
}
catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $errorMessage = $_.Exception.Message

    Write-Host "ERREUR lors de la recuperation des projets" -ForegroundColor Red
    Write-Host ""

    if ($statusCode -eq 401) {
        Write-Host "Token invalide ou expire" -ForegroundColor Red
        Write-Host ""
        Write-Host "Solution:" -ForegroundColor Yellow
        Write-Host "1. Allez sur: https://sonarcloud.io/account/security" -ForegroundColor White
        Write-Host "2. Revoquez l'ancien token" -ForegroundColor White
        Write-Host "3. Generez un nouveau token" -ForegroundColor White
        Write-Host "4. Mettez a jour ce script avec le nouveau token" -ForegroundColor White
    }
    elseif ($statusCode -eq 403) {
        Write-Host "Permissions insuffisantes" -ForegroundColor Red
        Write-Host ""
        Write-Host "Solution:" -ForegroundColor Yellow
        Write-Host "1. Verifiez que vous etes membre de l'organisation '$organization'" -ForegroundColor White
        Write-Host "2. Le token doit avoir les permissions 'Browse'" -ForegroundColor White
    }
    else {
        Write-Host "Erreur HTTP $statusCode" -ForegroundColor Red
        Write-Host "Message: $errorMessage" -ForegroundColor White
    }

    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan

