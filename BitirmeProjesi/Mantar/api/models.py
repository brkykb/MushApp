from django.db import models

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

class UserScan(models.Model):
    mushroom = models.ForeignKey(Mushroom, on_delete=models.SET_NULL, null=True, related_name='scans')
    mushroom_name = models.CharField(max_length=100)  # Fallback if Mushroom model doesn't have the entry
    image_url = models.URLField(max_length=500)
    confidence = models.FloatField()
    scanned_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.mushroom_name} - {self.scanned_at}"
