from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, generics
from django.core.files.storage import FileSystemStorage
from django.conf import settings
import os
import random

# Modeller ve Serializerlar
from .models import Mushroom, UserScan
from .serializers import MushroomSerializer, UserScanSerializer

# Yapay Zeka Motoru
from ml_engine.predictor import MushroomPredictor

class PredictAPIView(APIView):
    def post(self, request, *args, **kwargs):
        if 'image' not in request.FILES:
            return Response({"error": "Lütfen bir resim gönderin."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            image_file = request.FILES['image']
            fs = FileSystemStorage()
            filename = fs.save(image_file.name, image_file)
            file_path = fs.path(filename)
            image_url = request.build_absolute_uri(fs.url(filename))

            # Tahmin Yap
            result = MushroomPredictor.predict(file_path)
            mushroom_name = result['class']
            confidence = result['confidence']

            # Veritabanında Bu Mantarı Bul (Yoksa isimle kaydet)
            mushroom_obj = Mushroom.objects.filter(name__icontains=mushroom_name).first()

            # Taramayı Kaydet (Koleksiyon için)
            UserScan.objects.create(
                mushroom=mushroom_obj,
                mushroom_name=mushroom_name,
                image_url=image_url,
                confidence=confidence
            )

            return Response({
                "success": True,
                "image_url": image_url,
                "prediction": mushroom_name,
                "confidence": confidence,
                "details": MushroomSerializer(mushroom_obj).data if mushroom_obj else None
            }, status=status.HTTP_200_OK)

        except Exception as e:
            return Response({"success": False, "error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class WikiListView(generics.ListAPIView):
    queryset = Mushroom.objects.all()
    serializer_class = MushroomSerializer

class DailyMushroomView(APIView):
    def get(self, request):
        mushrooms = Mushroom.objects.all()
        if not mushrooms.exists():
            return Response({"error": "Henüz mantar verisi yok."}, status=status.HTTP_404_NOT_FOUND)
        
        # Basitlik için her gün rastgele birini döndürelim (Gerçekte tarihe göre sabitlenir)
        daily = random.choice(mushrooms)
        return Response(MushroomSerializer(daily).data)

class UserCollectionView(generics.ListAPIView):
    queryset = UserScan.objects.all().order_by('-scanned_at')
    serializer_class = UserScanSerializer