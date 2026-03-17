FROM python:3.11-slim

# Sistem bağımlılıklarını kur (Görüntü işleme kütüphaneleri gerekebilir)
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Kütüphaneleri kur
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Kodları kopyala
COPY . .

# Cloud Run 8080 portunu bekler
EXPOSE 8080

# Uygulamayı başlat (FastAPI/Flask ne kullanıyorsan ona göre güncelle)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
