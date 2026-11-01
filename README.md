# DeepFace Local — lokalne GUI do porównania dwóch twarzy

Prosty interfejs Flask + DeepFace API (FaceNet/ONNX). Dwa zdjęcia wybiera się z dysku. Obliczenia są wykonywane lokalnie w Dockerze. Nie udostępniaj portów publicznie.

## Windows 11 — uruchomienie u znajomego

Wymagania: Docker Desktop **z silnikiem Linux i backendem WSL2**, Git for Windows, dostęp do Internetu, port 8080 dostępny. W Docker Desktop musi działać silnik (Linux containers).

W PowerShell:

```powershell
git clone https://github.com/TWOJ-LOGIN/DeepFace-Local.git
cd DeepFace-Local
powershell -ExecutionPolicy Bypass -File .\start.ps1
```

Po pierwszym uruchomieniu otwórz http://127.0.0.1:8080. Skrypt buduje obrazy, tworzy sieć i wolumen. Wagi FaceNet są pobierane przy pierwszym użyciu, o ile nie ma ich w wolumenie. Przetestowane lokalnie na Ubuntu, **nieprzetestowane jeszcze na komputerze z Windows 11**.

Przy kolejnym uruchomieniu: `powershell -ExecutionPolicy Bypass -File .\start.ps1`, ewentualnie `docker compose start` (w folderze projektu). Zatrzymanie: `docker compose stop`. Nie ma automatycznego restartu kontenerów po włączeniu komputera.

## Ubuntu — publikacja przez właściciela projektu

**Nie instaluj projektu u siebie drugi raz.** Obecne kontenery `deepface-v2` i `deepface-gui` zostają bez zmian i uruchamiasz je `docker start deepface-v2 deepface-gui`.

Rozpakuj ten folder do `~/Projekty/docker/DeepFace-Local`, obok obecnego `~/Projekty/docker/deepface`. Wykonaj:

```bash
cd ~/Projekty/docker/DeepFace-Local
bash prepare-release.sh
cat backend-commit.txt
```

Skrypt zapisze SHA commita kodu DeepFace, na którym pracujesz. Pliki źródłowe DeepFace będą pobrane na innym komputerze z oficjalnego GitHuba, z przypięciem właśnie do tego commita. Jeżeli masz niezacommitowane lokalne zmiany w kodzie upstream, skrypt przerwie przygotowanie.

Zobacz, co dodajesz do repozytorium: `git status` oraz `git status --ignored`. Katalog `backend/deepface/`, zdjęcia i modele są ignorowane przez Git. Następnie utwórz puste repo na github.com i wyślij projekt:

```bash
git init
git add .
git commit -m "Initial working DeepFace Local"
git branch -M main
git remote add origin https://github.com/TWOJ-LOGIN/DeepFace-Local.git
git push -u origin main
```

## Co zawiera Compose?

- `api` — DeepFace ONNX, port 5000 w kontenerze, 127.0.0.1:5001 na hoście.
- `gui` — Flask/Gunicorn, port 8080, komunikacja po wewnętrznej sieci pod adresem `http://api:5000`.
- `deepface-models` — nazwany wolumen do zapisywania wag modelu.
- `restart: "no"` — uruchamianie tylko na żądanie.

Pliki obrazów użytkownika nie są trwale zapisywane przez GUI. Porty są przypięte do localhost. Wymagane CPU x86_64; inne architektury nie były testowane. Pierwszy build wymaga Internetu i może potrwać. Backend używa starego środowiska Python 3.8.12 — to lokalny projekt demonstracyjny, a nie system produkcyjny. Nie traktuj wyniku porównania jako dowodu tożsamości.

**Uwaga:** przy posiadaniu ręcznie utworzonych kontenerów o nazwach `deepface-v2` oraz `deepface-gui` Compose nie uruchomi duplikatów. Na nowym komputerze konfliktu nie powinno być; na Twoim Ubuntu nie wywołuj `start.sh` tego projektu bez świadomej migracji.

Licencja DeepFace: obowiązuje licencja w oryginalnym repo https://github.com/serengil/deepface. Przed publiczną publikacją własnego kodu rozważ dodanie własnej licencji.
