import os
import shutil
import random
import math


def split_dataset(source_dir, output_dir, train_ratio=0.8, val_ratio=0.1, test_ratio=0.1):
    """
    Veri setini Train, Validation ve Test klasörlerine ayırır.

    Parametreler:
    source_dir: Orijinal veri setinin olduğu ana klasör (içinde 25 mantar klasörü olmalı).
    output_dir: Ayrılmış verilerin kaydedileceği yeni klasör.
    train_ratio: Eğitim verisi oranı (Örn: 0.8).
    val_ratio: Doğrulama verisi oranı (Örn: 0.1).
    test_ratio: Test verisi oranı (Örn: 0.1).
    """

    # Oranların toplamı 1 olmalı kontrolü
    if train_ratio + val_ratio + test_ratio != 1.0:
        print("HATA: Oranların toplamı 1.0 (yani %100) olmalıdır.")
        return

    # Eğer çıktı klasörü varsa temizle (isteğe bağlı, çakışmayı önler)
    if os.path.exists(output_dir):
        response = input(f"UYARI: '{output_dir}' klasörü zaten var. Silip tekrar oluşturulsun mu? (e/h): ")
        if response.lower() == 'e':
            shutil.rmtree(output_dir)
        else:
            print("İşlem iptal edildi.")
            return

    # Türlerin (sınıfların) listesini al
    classes = [d for d in os.listdir(source_dir) if os.path.isdir(os.path.join(source_dir, d))]

    print(f"Toplam {len(classes)} mantar türü bulundu. İşlem başlıyor...\n")

    for class_name in classes:
        print(f"İşleniyor: {class_name}...")

        # Orijinal sınıf klasörünün yolu
        src_path = os.path.join(source_dir, class_name)

        # O klasördeki tüm dosyaları al (sadece resim dosyaları)
        files = [f for f in os.listdir(src_path) if os.path.isfile(os.path.join(src_path, f))]

        # Dosyaları karıştır (Rastgelelik için çok önemli)
        random.shuffle(files)

        # Bölme noktalarını hesapla
        total_files = len(files)
        train_count = int(total_files * train_ratio)
        val_count = int(total_files * val_ratio)
        # Kalanları test'e at (yuvarlama hatalarını önlemek için)
        test_count = total_files - train_count - val_count

        # Dosya listelerini dilimle
        train_files = files[:train_count]
        val_files = files[train_count:train_count + val_count]
        test_files = files[train_count + val_count:]

        # Dosyaları kopyalamak için yardımcı fonksiyon
        def copy_files(file_list, split_type):
            # Hedef klasör: output/train/MantarTuru/
            dest_path = os.path.join(output_dir, split_type, class_name)
            os.makedirs(dest_path, exist_ok=True)

            for file_name in file_list:
                src_file = os.path.join(src_path, file_name)
                dest_file = os.path.join(dest_path, file_name)
                shutil.copy2(src_file, dest_file)  # copy2 metadataları (tarih vb.) korur

        # Kopyalama işlemlerini yap
        copy_files(train_files, 'train')
        copy_files(val_files, 'val')
        copy_files(test_files, 'test')

    print("\n✅ İşlem Başarıyla Tamamlandı!")
    print(f"Veriler '{output_dir}' klasörüne şu yapıda kaydedildi:")
    print(f"   ├── train (%{int(train_ratio * 100)})")
    print(f"   ├── val   (%{int(val_ratio * 100)})")
    print(f"   └── test  (%{int(test_ratio * 100)})")


# --- KULLANIM AYARLARI ---
# Burayı kendi bilgisayarındaki yollara göre değiştirmen gerekiyor.

# Örnek: "C:/Kullanicilar/Sen/MantarProjesi/TumVeriler"
SOURCE_PATH = "sınıflar"

# Örnek: "C:/Kullanicilar/Sen/MantarProjesi/AyrilmisVeri"
OUTPUT_PATH = "yenisiniflar"

# Kodu çalıştırmadan önce yukarıdaki yolları güncellediğinden emin ol.
# Eğer yolları henüz girmediysen çalışmaz, bu yüzden bir kontrol koyuyoruz:
if SOURCE_PATH == "buraya_orijinal_veri_klasorunun_yolunu_yaz":
    print("LÜTFEN KODUN EN ALTINDAKİ 'SOURCE_PATH' VE 'OUTPUT_PATH' DEĞİŞKENLERİNİ DÜZENLEYİN.")
else:
    # Oranlar: %80 Train, %10 Validation, %10 Test
    split_dataset(SOURCE_PATH, OUTPUT_PATH, train_ratio=0.8, val_ratio=0.1, test_ratio=0.1)