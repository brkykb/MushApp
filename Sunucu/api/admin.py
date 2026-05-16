from django.contrib import admin
from .models import Mushroom, UserScan

@admin.register(Mushroom)
class MushroomAdmin(admin.ModelAdmin):
    list_display = ('name', 'latin_name', 'toxicity', 'created_at')
    search_fields = ('name', 'latin_name')
    list_filter = ('toxicity',)

@admin.register(UserScan)
class UserScanAdmin(admin.ModelAdmin):
    list_display = ('mushroom_name', 'confidence', 'scanned_at')
    readonly_fields = ('scanned_at',)
