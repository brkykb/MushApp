from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, generics
from django.core.files.storage import FileSystemStorage
from django.conf import settings
import os
import random

# Modeller ve Serializerlar
from .models import Mushroom, UserScan, Profile
from .serializers import MushroomSerializer, UserScanSerializer

# Yapay Zeka Motoru
from ml_engine.predictor import MushroomPredictor

# Firebase ve Django Auth
from firebase_admin import auth as firebase_auth
from django.contrib.auth.models import User

def get_user_from_auth_header(request):
    """Firebase Token'dan Django kullanıcısını bulan yardımcı fonksiyon"""
    auth_header = request.headers.get('Authorization')
    if not auth_header or not auth_header.startswith('Bearer '):
        return None
    token = auth_header.split(' ')[1]
    try:
        decoded_token = firebase_auth.verify_id_token(token)
        uid = decoded_token.get('uid')
        return User.objects.get(username=uid)
    except:
        return None

class FirebaseAuthView(APIView):
    def post(self, request):
        id_token = request.data.get('id_token') or request.data.get('idToken')
        if not id_token:
            return Response({"error": "Token gönderilmedi."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Token doğrulama
            decoded_token = firebase_auth.verify_id_token(id_token)
            uid = decoded_token.get('uid')
            email = decoded_token.get('email')
            name = decoded_token.get('name', '')
            
            # Email yoksa (bazı Apple girişlerinde ilk seferde gelmeyebilir)
            if not email:
                email = f"{uid}@mushapp.dev" # Yedek email

            user, created = User.objects.get_or_create(username=uid, defaults={
                'email': email,
                'first_name': name.split(' ')[0] if name else '',
                'last_name': ' '.join(name.split(' ')[1:]) if name and len(name.split(' ')) > 1 else ''
            })

            # Eğer kullanıcı zaten varsa ama email'i boşsa güncelle
            if not created and not user.email and email:
                user.email = email
                user.save()

            return Response({
                "success": True,
                "user_id": user.id,
                "email": user.email,
                "is_new": created
            }, status=status.HTTP_200_OK)

        except Exception as e:
            print(f"Firebase Auth Error: {str(e)}")
            return Response({"error": f"Kimlik doğrulama hatası: {str(e)}"}, status=status.HTTP_401_UNAUTHORIZED)

class ProfileView(APIView):
    def get(self, request):
        user = get_user_from_auth_header(request)
        if not user:
            return Response({"error": "Yetkisiz erişim."}, status=status.HTTP_401_UNAUTHORIZED)
        
        profile = user.profile
        
        # Günlük hakları yenileme kontrolü
        import datetime
        if profile.last_scan_date < datetime.date.today():
            profile.daily_scans_left = 5
            profile.save()

        return Response({
            "name": f"{user.first_name} {user.last_name}".strip() or user.username,
            "money": profile.money,
            "level": profile.level,
            "exp": profile.exp,
            "max_exp": profile.level * 100,
            "daily_scans_left": profile.daily_scans_left,
            "collection_count": user.scans.count()
        })

class PredictAPIView(APIView):
    def post(self, request, *args, **kwargs):
        user = get_user_from_auth_header(request)
        if not user:
            return Response({"error": "Yetkisiz erişim. Lütfen giriş yapın."}, status=status.HTTP_401_UNAUTHORIZED)

        if 'image' not in request.FILES:
            return Response({"error": "Lütfen bir resim gönderin."}, status=status.HTTP_400_BAD_REQUEST)

        profile = user.profile
        if profile.daily_scans_left <= 0:
            return Response({"error": "Bugünlük tarama hakkınız bitti! Yarın tekrar bekleriz."}, status=status.HTTP_403_FORBIDDEN)

        try:
            image_file = request.FILES['image']
            fs = FileSystemStorage()
            filename = fs.save(image_file.name, image_file)
            file_path = fs.path(filename)
            image_url = request.build_absolute_uri(fs.url(filename))

            # Tahmin
            result = MushroomPredictor.predict(file_path)
            mushroom_name = result['class']
            confidence = result['confidence']

            mushroom_obj = Mushroom.objects.filter(latin_name__icontains=mushroom_name).first()

            # Kullanıcıya XP ve ödül ver
            profile.daily_scans_left -= 1
            profile.exp += 25
            if profile.exp >= profile.level * 100:
                profile.level += 1
                profile.exp = 0
                profile.money += 50 # Seviye atlama ödülü
            profile.save()

            # Koleksiyona Kaydet
            UserScan.objects.create(
                user=user,
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
                "details": MushroomSerializer(mushroom_obj).data if mushroom_obj else None,
                "profile_update": {
                    "level": profile.level,
                    "exp": profile.exp,
                    "daily_scans_left": profile.daily_scans_left
                }
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
        daily = random.choice(mushrooms)
        return Response(MushroomSerializer(daily).data)

class UserCollectionView(generics.ListAPIView):
    serializer_class = UserScanSerializer
    def get_queryset(self):
        user = get_user_from_auth_header(self.request)
        if user:
            return UserScan.objects.filter(user=user).order_by('-scanned_at')
        return UserScan.objects.none()