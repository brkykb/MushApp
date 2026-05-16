import os
import django
import random

# Django ayarlarını yükle
os.environ.setdefault('FORKED_BY_ANTIGRAVITY', 'true')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'Mantar.settings')
django.setup()

from api.models import Mushroom

MUSHROOM_DATA = [
    {"name": "Kültür Mantarı", "latin_name": "Agaricus bisporus", "toxicity": "Yenen", "image_id": "8023164"},
    {"name": "Sinek Mantarı", "latin_name": "Amanita muscaria", "toxicity": "Zehirli", "image_id": "11414921"},
    {"name": "Panter Mantarı", "latin_name": "Amanita pantherina", "toxicity": "Zehirli", "image_id": "12841491"},
    {"name": "Ölüm Meleği", "latin_name": "Amanita phalloides", "toxicity": "Zehirli", "image_id": "12841492"},
    {"name": "Çörek Mantarı", "latin_name": "Boletus edulis", "toxicity": "Yenen", "image_id": "12841493"},
    {"name": "İmparator Mantarı", "latin_name": "Amanita caesarea", "toxicity": "Yenen", "image_id": "12841494"},
    {"name": "İstiridye Mantarı", "latin_name": "Pleurotus ostreatus", "toxicity": "Yenen", "image_id": "12841495"},
    {"name": "Kuzu Göbeği", "latin_name": "Morchella esculenta", "toxicity": "Yenen", "image_id": "12841496"},
    {"name": "Borazan Mantarı", "latin_name": "Craterellus cornucopioides", "toxicity": "Yenen", "image_id": "12841497"},
    {"name": "Civciv Mantarı", "latin_name": "Cantharellus cibarius", "toxicity": "Yenen", "image_id": "12841498"},
    {"name": "Müshil Mantarı", "latin_name": "Russula emetica", "toxicity": "Zehirli", "image_id": "12841499"},
    {"name": "Pösteki Mantarı", "latin_name": "Coprinus comatus", "toxicity": "Yenen", "image_id": "12841500"},
    {"name": "Sığırdili Mantarı", "latin_name": "Hydnum repandum", "toxicity": "Yenen", "image_id": "12841501"},
    {"name": "Kanlıca Mantarı", "latin_name": "Lactarius deliciosus", "toxicity": "Yenen", "image_id": "12841502"},
    {"name": "Şemsiye Mantarı", "latin_name": "Macrolepiota procera", "toxicity": "Yenen", "image_id": "12841503"},
    {"name": "Bal Mantarı", "latin_name": "Armillaria mellea", "toxicity": "Yenen", "image_id": "12841504"},
    {"name": "Cinci Mantarı", "latin_name": "Calocybe gambosa", "toxicity": "Yenen", "image_id": "12841505"},
    {"name": "Geyik Mantarı", "latin_name": "Pluteus cervinus", "toxicity": "Yenen", "image_id": "12841506"},
    {"name": "Trüf Mantarı", "latin_name": "Tuber melanosporum", "toxicity": "Yenen", "image_id": "12841507"},
    {"name": "Kükürtlü Mantar", "latin_name": "Hypholoma fasciculare", "toxicity": "Zehirli", "image_id": "12841508"},
    {"name": "Yalancı Kuzu Göbeği", "latin_name": "Gyromitra esculenta", "toxicity": "Zehirli", "image_id": "12841509"},
    {"name": "Ölümcül Galerina", "latin_name": "Galerina marginata", "toxicity": "Zehirli", "image_id": "12841510"},
    {"name": "Ağulu Mantar", "latin_name": "Omphalotus olearius", "toxicity": "Zehirli", "image_id": "12841511"},
    {"name": "Saman Mantarı", "latin_name": "Volvariella volvacea", "toxicity": "Yenen", "image_id": "12841512"},
    {"name": "Dede Mantarı", "latin_name": "Agaricus campestris", "toxicity": "Yenen", "image_id": "12841513"},
]

def seed():
    print("Veritabanı dolduruluyor...")
    for data in MUSHROOM_DATA:
        # Pexels veya Unsplash üzerinden rastgele kaliteli mantar resimleri
        # Not: Gerçekte her biri için farklı bir ID bulmak en iyisidir, şimdilik rastgele mantar kategorisinden çekiyoruz
        image_url = f"https://images.pexels.com/photos/{data['image_id']}/pexels-photo-{data['image_id']}.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"
        # Eğer bu ID'ler patlarsa genel bir mantar resmi koyalım
        if int(data['image_id']) > 12000000:
             image_url = f"https://source.unsplash.com/featured/?mushroom,{data['latin_name'].replace(' ', ',')}"

        Mushroom.objects.update_or_create(
            latin_name=data['latin_name'],
            defaults={
                "name": data['name'],
                "toxicity": data['toxicity'],
                "description": f"{data['name']} ({data['latin_name']}) doğada sıkça rastlanan bir {data['toxicity'].lower()} türüdür. Lütfen uzman onayı olmadan tüketmeyin.",
                "image_url": image_url,
            }
        )
    print("İşlem tamam! 25 mantar eklendi.")

if __name__ == "__main__":
    seed()
