$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Brak Docker CLI. Zainstaluj Docker Desktop.' }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Brak Git. Zainstaluj Git for Windows.' }
docker info | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Uruchom Docker Desktop (silnik Linux/WSL2).' }
docker compose version | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Brak Docker Compose.' }
if (-not (Test-Path 'backend-commit.txt')) { throw 'Brak backend-commit.txt; autor nie przygotowal wydania.' }
$rev = (Get-Content 'backend-commit.txt' -Raw).Trim()
if ($rev -notmatch '^[0-9a-fA-F]{40}$') { throw 'Nieprawidlowy commit w backend-commit.txt.' }
if (-not (Test-Path 'backend/deepface/.git')) {
    if (Test-Path 'backend/deepface') { throw 'Katalog backend/deepface juz istnieje, ale nie jest repo Git.' }
    git clone https://github.com/serengil/deepface.git backend/deepface
    if ($LASTEXITCODE -ne 0) { throw 'Blad git clone DeepFace.' }
}
$cur = (git -C backend/deepface rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0) { throw 'Blad git rev-parse.' }
if ($cur -ne $rev) {
    git -C backend/deepface fetch origin $rev
    if ($LASTEXITCODE -ne 0) {
        git -C backend/deepface fetch origin
        if ($LASTEXITCODE -ne 0) { throw 'Blad pobierania kodu DeepFace.' }
    }
    git -C backend/deepface checkout --detach $rev
    if ($LASTEXITCODE -ne 0) { throw 'Nie moge przejsc na przypiety commit DeepFace.' }
}
docker compose up -d --build
if ($LASTEXITCODE -ne 0) { throw 'Blad Docker Compose.' }
Write-Host 'GUI: http://127.0.0.1:8080'
