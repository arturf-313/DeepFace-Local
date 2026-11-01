# DeepFace Local

**A self-hosted face verification application powered by DeepFace, FaceNet, and Docker.**

DeepFace Local provides a lightweight web interface for comparing faces in two uploaded images. Face verification runs locally using the DeepFace API and an ONNX-based FaceNet model.

The application is designed for simple deployment on Linux and Windows 11 using Docker, without requiring a separate Python installation on the host system.

## Features

- **Image upload** — Select and compare two images directly from your computer.
- **Face verification** — Determine whether two detected faces are likely to belong to the same person.
- **Verification results** — View the decision, similarity distance, model threshold, and processing time.
- **Local processing** — Images are processed by locally running Docker containers.
- **Persistent model storage** — Downloaded model weights are retained in a Docker volume.
- **Cross-platform deployment** — Supports Docker Engine on Linux and Docker Desktop with WSL2 on Windows 11.
- **Containerized architecture** — Separate services for the web interface and DeepFace API.

The current release uses **FaceNet with ONNX Runtime**. Support for additional recognition models and further interface improvements is planned.

## Requirements

- Docker Engine with Docker Compose, or Docker Desktop with Linux containers enabled
- Git
- Internet connection for initial setup and model downloads
- Available TCP port `8080`
- x86-64 processor

Windows 11 users should enable the **WSL2 backend** in Docker Desktop.

Other processor architectures have not been tested.

## Installation

### Windows 11

Open PowerShell and run:

```powershell
git clone https://github.com/arturf-313/DeepFace-Local.git
cd DeepFace-Local
powershell -ExecutionPolicy Bypass -File .\start.ps1
```

### Linux

Open a terminal and run:

```bash
git clone https://github.com/arturf-313/DeepFace-Local.git
cd DeepFace-Local
bash start.sh
```

The startup scripts retrieve the required DeepFace source code from the official repository at a pinned Git commit, build the Docker images, and start the application using Docker Compose.

During the first face verification request, FaceNet weights may be downloaded automatically if they are not already available in the persistent Docker volume.

### Open the application

Once the containers are running, open:

**http://127.0.0.1:8080**

Upload two images and select **Compare** to run face verification.

## Managing the application

Run the following commands from the project directory:

| Command | Description |
|---|---|
| `docker compose ps` | Display container status |
| `docker compose start` | Start existing containers |
| `docker compose stop` | Stop running containers |
| `docker compose up -d` | Create or start application services |
| `docker compose logs -f` | View application logs |
| `docker compose down` | Remove application containers and their Compose network |

The application does not start automatically when the computer boots.

Docker volumes persist across ordinary container stops and `docker compose down`. Avoid using `docker compose down -v` unless you intentionally want to remove stored model weights.

## Architecture

DeepFace Local uses two services connected through a private Docker network.

```text
Web Browser
    |
    | http://127.0.0.1:8080
    v
Web Interface (Flask + Gunicorn)
    |
    | HTTP / Internal Docker Network
    v
DeepFace REST API
    |
    v
FaceNet / ONNX Runtime
    |
    v
Persistent Docker Volume
(Model Weights)
```

| Component | Technology | Purpose |
|---|---|---|
| Frontend | Python 3.12, Flask, Gunicorn | Image uploads and result presentation |
| Backend | DeepFace API, Python 3.8, ONNX Runtime | Face detection and verification |
| Recognition model | FaceNet | Facial feature extraction and comparison |
| Orchestration | Docker Compose | Service configuration, networking, and storage |
| Storage | Docker named volume | Persistent AI model weights |

The web interface communicates with the API through the internal Docker service address `http://api:5000`.

The application exposes the following local endpoints:

- **Web interface:** `http://127.0.0.1:8080`
- **DeepFace API:** `http://127.0.0.1:5001`

## Project Structure

```text
DeepFace-Local/
├── backend/
│   └── README.md
├── frontend/
│   ├── app.py
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── static/
│   └── templates/
├── backend-commit.txt
├── compose.yaml
├── prepare-release.sh
├── start.sh
├── start.ps1
├── LICENSE
└── README.md
```

The upstream DeepFace source code is retrieved during installation and is not distributed as part of this repository. `backend-commit.txt` identifies the Git revision used for building the backend.

## Privacy and Security

DeepFace Local is intended for **local, self-hosted use**.

- Face verification is performed locally, without using a third-party recognition API.
- Uploaded images are processed in memory by the web application and are not intentionally stored in a persistent image database.
- Application ports are bound to `127.0.0.1`.
- Model weights are stored in a persistent Docker volume.
- Images and facial verification results are not automatically uploaded to GitHub.

**Important:** Facial recognition results are probabilistic and may be incorrect. They should not be treated as definitive proof of identity or used as the sole basis for security-sensitive decisions.

Only process images you are authorized to use and comply with applicable privacy and data protection laws.

### Security limitations

The current backend uses a legacy Python 3.8 environment and older dependencies for compatibility with the selected DeepFace/ONNX implementation.

This is an experimental, locally deployed application. It is **not hardened for public internet exposure or production authentication systems**.

## License

The custom web interface, Docker configuration, and project-specific scripts are released under the **MIT License**. See [LICENSE](LICENSE).

### Third-party software

This project uses [DeepFace](https://github.com/serengil/deepface), developed by **Sefik Ilkin Serengil and contributors**, and distributed under its own MIT License.

DeepFace is an independent upstream project and is not owned or maintained by this repository.

FaceNet and other third-party models or dependencies may be subject to separate licenses and usage conditions.

## Acknowledgments

- [DeepFace](https://github.com/serengil/deepface) — Face recognition framework
- [FaceNet](https://arxiv.org/abs/1503.03832) — Face embedding methodology
- [ONNX Runtime](https://onnxruntime.ai/) — Machine learning inference engine
- [Docker](https://www.docker.com/) — Containerization platform

---

**DeepFace Local** is an independent community project built around the DeepFace framework.
