import io
import os

import requests
from flask import Flask, render_template, request
from PIL import Image, UnidentifiedImageError

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 22 * 1024 * 1024
API_URL = os.environ.get('DEEPFACE_API_URL', 'http://deepface-v2:5000').rstrip('/')
MAX_IMAGE_SIZE = 10 * 1024 * 1024


def validated_image(upload):
    if not upload or not upload.filename:
        raise ValueError('Wybierz oba zdjęcia.')
    content = upload.read(MAX_IMAGE_SIZE + 1)
    if not content or len(content) > MAX_IMAGE_SIZE:
        raise ValueError('Każde zdjęcie musi mieć maksymalnie 10 MB.')
    try:
        with Image.open(io.BytesIO(content)) as image:
            if image.format not in ('JPEG', 'PNG', 'WEBP'):
                raise ValueError('Dozwolone formaty: JPG, PNG lub WebP.')
            image.verify()
            fmt = image.format
    except (UnidentifiedImageError, OSError, Image.DecompressionBombError) as exc:
        raise ValueError('Nie udało się odczytać zdjęcia. Wybierz poprawny plik JPG, PNG lub WebP.') from exc
    mime = {'JPEG': 'image/jpeg', 'PNG': 'image/png', 'WEBP': 'image/webp'}[fmt]
    ext = {'JPEG': 'jpg', 'PNG': 'png', 'WEBP': 'webp'}[fmt]
    return (f'zdjecie.{ext}', content, mime)


@app.route('/', methods=['GET', 'POST'])
def index():
    result = None
    error = None
    if request.method == 'POST':
        try:
            img1 = validated_image(request.files.get('img1'))
            img2 = validated_image(request.files.get('img2'))
            # Jedyny model potwierdzony w obecnym kontenerze ONNX.
            response = requests.post(
                f'{API_URL}/verify',
                files={'img1': img1, 'img2': img2},
                data={'model_name': 'Facenet'},
                timeout=(10, 3600),
            )
            response.raise_for_status()
            result = response.json()
            if not isinstance(result, dict) or 'verified' not in result:
                raise ValueError('API zwróciło nieoczekiwaną odpowiedź.')
        except ValueError as exc:
            error = str(exc)
        except requests.Timeout:
            error = 'Przekroczono czas oczekiwania na DeepFace.'
        except requests.RequestException:
            error = 'Nie udało się połączyć z DeepFace API. Sprawdź, czy kontener deepface-v2 działa.'
        except (TypeError, KeyError):
            error = 'Otrzymano nieprawidłową odpowiedź z DeepFace API.'
    return render_template('index.html', result=result, error=error)


@app.errorhandler(413)
def too_large(_):
    return render_template('index.html', result=None, error='Łączny rozmiar przesyłanych danych jest za duży (maks. 22 MB).'), 413
