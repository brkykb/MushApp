import os
from django.shortcuts import render
from django.core.files.storage import FileSystemStorage
from django.conf import settings

# Yapay Zeka Motorunu Çağırıyoruz (Profesyonel Dokunuş)
from ml_engine.predictor import MushroomPredictor

def index(request):
    """
    Ana sayfayı gösterir. Tüm işlemler client-side JS ile yapılır.
    """
    return render(request, 'index.html')