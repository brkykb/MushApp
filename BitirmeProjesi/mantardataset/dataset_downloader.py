import requests
import os

# --- KULLANICI AYARLARI ---
# Bilimsel adını buraya yazın (Örn: "Amanita muscaria", "Boletus edulis")
TUR_ADI = "Cantharellus cibarius"

# İndirilecek maksimum fotoğraf sayısı
INDIRME_LIMITI = 1000

# Fotoğrafların kaydedileceği klasör adı
KLASOR_ADI = TUR_ADI.replace(" ", "_").lower()
# --- AYARLARIN SONU ---


# 1. Adım: Türün bilimsel adından GBIF anahtarını (taxonKey) bulma
print(f"'{TUR_ADI}' için GBIF tür anahtarı aranıyor...")
species_api_url = f"https://api.gbif.org/v1/species/match?name={TUR_ADI}"
response = requests.get(species_api_url)

if response.status_code != 200 or 'usageKey' not in response.json():
    print("Hata: Tür bulunamadı veya API yanıt vermiyor. Lütfen bilimsel adı kontrol edin.")
    exit()

taxon_key = response.json()['usageKey']
print(f"Tür anahtarı bulundu: {taxon_key}")

# 2. Adım: Bulunan tür anahtarı ile fotoğraflı kayıtları (occurrence) arama
print(f"'{TUR_ADI}' için fotoğraflı kayıtlar aranıyor...")
occurrence_api_url = f"https://api.gbif.org/v1/occurrence/search?taxonKey={taxon_key}&mediaType=StillImage&limit={INDIRME_LIMITI}"
response = requests.get(occurrence_api_url)

if response.status_code != 200:
    print("Hata: Kayıtlar aranırken bir sorun oluştu.")
    exit()

results = response.json()['results']

if not results:
    print("Bu tür için fotoğraflı bir kayıt bulunamadı.")
    exit()

# 3. Adım: İndirme klasörünü oluşturma
if not os.path.exists(KLASOR_ADI):
    os.makedirs(KLASOR_ADI)
    print(f"'{KLASOR_ADI}' klasörü oluşturuldu.")

# 4. Adım: Fotoğrafları indirme
image_urls = []
for record in results:
    if 'media' in record and record['media']:
        for media_item in record['media']:
            if media_item.get('type') == 'StillImage' and 'identifier' in media_item:
                image_urls.append(media_item['identifier'])

if not image_urls:
    print("Kayıtlar bulundu ancak geçerli fotoğraf URL'si çıkarılamadı.")
    exit()

print(f"Toplam {len(image_urls)} adet fotoğraf bulundu ve indiriliyor...")

for i, url in enumerate(image_urls):
    try:
        # Dosya adını oluşturma
        dosya_adi = f"{KLASOR_ADI}_{i + 1}.jpg"
        kayit_yolu = os.path.join(KLASOR_ADI, dosya_adi)

        # Fotoğrafı indirme
        img_response = requests.get(url, stream=True)

        if img_response.status_code == 200:
            with open(kayit_yolu, 'wb') as f:
                for chunk in img_response.iter_content(1024):
                    f.write(chunk)
            print(f"({i + 1}/{len(image_urls)}) {dosya_adi} indirildi.")
        else:
            print(f"Hata: {url} indirilemedi. (Status Code: {img_response.status_code})")

    except Exception as e:
        print(f"Bir hata oluştu: {e}")

print("\nİndirme işlemi tamamlandı!")