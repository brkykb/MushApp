import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'Mantar.settings')
django.setup()

from api.models import Mushroom

LOCAL_IMAGES = [
    "agaricus_bisporus.png",
    "amanita_caesarea.png",
    "amanita_muscaria.png",
    "amanita_pantherina.png",
    "amanita_phalloides.png",
    "boletus_edulis.png",
    "morchella_esculenta.png",
    "pleurotus_ostreatus.png"
]

def update():
    print("Yerel resimler güncelleniyor...")
    for filename in LOCAL_IMAGES:
        latin_name = filename.replace(".png", "").replace("_", " ")
        # Latin ismine göre mantarı bul
        mushroom = Mushroom.objects.filter(latin_name__iexact=latin_name).first()
        if mushroom:
            # URL'yi yerel media klasörüne yönlendir
            mushroom.image_url = f"http://127.0.0.1:8000/media/mushrooms/{filename}"
            mushroom.save()
            print(f"Güncellendi: {mushroom.name} -> {filename}")
        else:
            print(f"Uyarı: {latin_name} için veritabanında kayıt bulunamadı.")

if __name__ == "__main__":
    update()
