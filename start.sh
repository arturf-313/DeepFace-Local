#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
command -v docker >/dev/null || { echo 'Brak Docker CLI' >&2; exit 1; }
docker info >/dev/null 2>&1 || { echo 'Docker nie dziala. Uruchom Docker Engine / Desktop.' >&2; exit 1; }
docker compose version >/dev/null 2>&1 || { echo 'Brak Docker Compose' >&2; exit 1; }
command -v git >/dev/null || { echo 'Brak Git' >&2; exit 1; }
[ -f backend-commit.txt ] || { echo 'Brak backend-commit.txt: autor musi najpierw wykonac bash prepare-release.sh' >&2; exit 1; }
REV="$(tr -d '\r\n ' < backend-commit.txt)"
[[ "$REV" =~ ^[0-9a-fA-F]{40}$ ]] || { echo 'Nieprawidlowy commit w backend-commit.txt' >&2; exit 1; }
if [ ! -d backend/deepface/.git ]; then
  if [ -e backend/deepface ]; then echo 'Katalog backend/deepface istnieje, ale nie jest repo Git' >&2; exit 1; fi
  git clone https://github.com/serengil/deepface.git backend/deepface
fi
CUR="$(git -C backend/deepface rev-parse HEAD)"
if [ "$CUR" != "$REV" ]; then
  git -C backend/deepface fetch origin "$REV" || git -C backend/deepface fetch origin
  git -C backend/deepface checkout --detach "$REV"
fi
docker compose up -d --build
printf '\nGUI: http://127.0.0.1:8080\n'
