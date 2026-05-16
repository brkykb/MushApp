FROM python:3.11-slim

# Sistem bağımlılıkları
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Bağımlılıkları kopyala ve kur
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Proje dosyalarını kopyala
COPY . .

# Gereksiz dosyaları temizle (Sunucuda Flutter dosyalarına ihtiyacımız yok)
RUN rm -rf ios android lib test pubspec.yaml pubspec.lock analysis_options.yaml .dart_tool .metadata

# Gunicorn ile çalıştır
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "Mantar.wsgi:application"]
