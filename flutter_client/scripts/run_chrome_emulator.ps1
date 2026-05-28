$ErrorActionPreference = "Stop"

Set-Location (Split-Path $PSScriptRoot -Parent)

$baseUrl = "http://127.0.0.1:5002/projetointegrador3-grupo18/southamerica-east1/api/"

Write-Host "Running Flutter on Chrome with API_BASE_URL=$baseUrl" -ForegroundColor Cyan
flutter run -d chrome --dart-define=API_BASE_URL=$baseUrl

