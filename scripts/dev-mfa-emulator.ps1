$ErrorActionPreference = "Stop"

Set-Location (Split-Path $PSScriptRoot -Parent)

Write-Host "Installing backend deps (functions)..." -ForegroundColor Cyan
npm.cmd --prefix functions install

Write-Host "Building backend (functions)..." -ForegroundColor Cyan
npm.cmd --prefix functions run build

Write-Host "Starting Firebase emulators (firestore,functions)..." -ForegroundColor Cyan
firebase.cmd emulators:start --only firestore,functions
