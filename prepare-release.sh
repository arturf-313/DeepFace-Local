#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
SOURCE="../deepface"
if [ ! -f "$SOURCE/Dockerfile" ] || [ ! -d "$SOURCE/.git" ]; then
  echo 'Brak repozytorium Git w ../deepface. Uruchom projekt z ~/Projekty/docker/DeepFace-Local obok katalogu deepface.' >&2
  exit 1
fi
if [ -n "$(git -C "$SOURCE" status --porcelain --untracked-files=no)" ]; then
  echo 'Kod DeepFace ma niezapisane zmiany. Najpierw je przeanalizuj, bo sam commit ich nie odtworzy.' >&2
  exit 1
fi
REF="$(git -C "$SOURCE" rev-parse --verify HEAD)"
# Make sure this revision is retrievable from official GitHub repo.
if ! git ls-remote https://github.com/serengil/deepface.git | grep -qi "^${REF}[[:space:]]"; then
  echo 'Uwaga: commit nie jest końcówką gałęzi lub taga na GitHubie. Sprawdź, czy jest dostępny publicznie.' >&2
  echo 'Dla bezpieczeństwa zostawiam ref; clone + checkout przy uruchomieniu zweryfikuje jego dostępność.' >&2
fi
printf '%s\n' "$REF" > backend-commit.txt
echo "Przypięto DeepFace: $REF"
echo 'Dodaj backend-commit.txt do Git przed publikacją.'
