from rest_framework import serializers
from .models import Mushroom, UserScan

class MushroomSerializer(serializers.ModelSerializer):
    class Meta:
        model = Mushroom
        fields = '__all__'

class UserScanSerializer(serializers.ModelSerializer):
    mushroom_details = MushroomSerializer(source='mushroom', read_only=True)
    
    class Meta:
        model = UserScan
        fields = ['id', 'mushroom', 'mushroom_name', 'image_url', 'confidence', 'scanned_at', 'mushroom_details']
