import os
from django.shortcuts import render
from django.core.files.storage import FileSystemStorage
from django.conf import settings

# Yapay Zeka Motorunu Çağırıyoruz (Profesyonel Dokunuş)
from ml_engine.predictor import MushroomPredictor

def index(request):
    """
    Hem ana sayfayı gösterir hem de POST gelirse tahmini yapar.
    """
    if request.method == 'POST' and request.FILES.get('image'):
        try:
            # 1. Dosyayı Kaydet
            image_file = request.FILES['image']
            fs = FileSystemStorage()
            filename = fs.save(image_file.name, image_file)
            file_url = fs.url(filename)
            file_path = fs.path(filename) # Diskteki tam yol

            # 2. ML Engine'e Gönder (Tek satırda iş biter)
            result = MushroomPredictor.predict(file_path)

            # 3. Sonuçları Result Sayfasına Gönder
            context = {
                'image_url': file_url,
                'prediction': result['class'],
                'confidence': result['confidence']
            }
            return render(request, 'result.html', context)

        except Exception as e:
            # Hata olursa sayfaya yazdır
            return render(request, 'index.html', {'error': str(e)})

    # Sayfa ilk açıldığında (GET isteği) burası çalışır
    return render(request, 'index.html')