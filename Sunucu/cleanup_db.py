import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'Mantar.settings')
django.setup()

from api.models import Mushroom

def cleanup_duplicates():
    all_mushrooms = Mushroom.objects.all()
    seen_latin_names = {}
    duplicates = []

    for m in all_mushrooms:
        lname = m.latin_name.lower().strip()
        if lname not in seen_latin_names:
            seen_latin_names[lname] = m
        else:
            existing = seen_latin_names[lname]
            
            # Eğer existing (eski kayıt) sadece Latince isme sahipse ve m (yeni kayıt) Türkçe bir isme sahipse:
            # Yeni kaydı (m) koruyup, eski kaydı (existing) silinecekler listesine ekle.
            if existing.name.lower() == existing.latin_name.lower() and m.name.lower() != m.latin_name.lower():
                duplicates.append(existing)
                seen_latin_names[lname] = m
            else:
                # Aksi halde yeni gelen kopyayı silinecekler listesine ekle
                duplicates.append(m)

    print(f"Toplam {len(duplicates)} adet kopya bulundu. Siliniyor...")
    for d in duplicates:
        print(f"Siliniyor: ID={d.id} | {d.name} ({d.latin_name})")
        d.delete()

    print("Veritabanı temizlendi! Mevcut benzersiz mantar sayısı:", Mushroom.objects.count())

if __name__ == "__main__":
    cleanup_duplicates()
