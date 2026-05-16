from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver

class Mushroom(models.Model):
    TOXICITY_CHOICES = [
        ('Yenen', 'Yenen (Edible)'),
        ('Zehirli', 'Zehirli (Toxic)'),
        ('Ölümcül', 'Ölümcül (Deadly)'),
    ]

    name = models.CharField(max_length=100)
    latin_name = models.CharField(max_length=100, blank=True)
    description = models.TextField()
    toxicity = models.CharField(max_length=20, choices=TOXICITY_CHOICES)
    habitat = models.CharField(max_length=200, blank=True)
    season = models.CharField(max_length=100, blank=True)
    image_url = models.URLField(max_length=500, blank=True)
    source_url = models.URLField(max_length=500, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    money = models.IntegerField(default=100)
    level = models.IntegerField(default=1)
    exp = models.IntegerField(default=0)
    daily_scans_left = models.IntegerField(default=5)
    last_scan_date = models.DateField(auto_now=True)

    def __str__(self):
        return f"{self.user.username} Profili"

# Yeni kullanıcı oluşunca otomatik profil oluştur
@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        Profile.objects.create(user=instance)

class UserScan(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='scans', null=True)
    mushroom = models.ForeignKey(Mushroom, on_delete=models.SET_NULL, null=True, related_name='scans')
    mushroom_name = models.CharField(max_length=100)
    image_url = models.URLField(max_length=500)
    confidence = models.FloatField()
    scanned_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username if self.user else 'Anonim'} - {self.mushroom_name}"
