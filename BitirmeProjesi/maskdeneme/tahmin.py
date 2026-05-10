import cv2
import numpy as np
import tensorflow as tf
import matplotlib.pyplot as plt

# --- 1. AYARLAR: Kendi dosya yollarını buraya yaz! ---

# Bir önceki kodla eğittiğin ve kaydettiğin modelin yolu
MODEL_PATH = 'mantar_segmentasyon_unet.keras'

# Test etmek istediğin YENİ mantar fotoğrafının yolu
IMAGE_PATH = 'ple2.jpg'

# Eğitim sırasında kullandığın boyutlarla AYNI OLMALI!
IMG_HEIGHT = 256
IMG_WIDTH = 256
# ----------------------------------------------------


# --- 2. Eğitilmiş Modeli Yükle ---
print(f"'{MODEL_PATH}' adresinden model yükleniyor...")
try:
    model = tf.keras.models.load_model(MODEL_PATH)
    print("Model başarıyla yüklendi.")
except Exception as e:
    print(f"HATA: Model yüklenirken bir sorun oluştu. Dosya yolunu kontrol et.\n{e}")
    exit()  # Model yüklenemezse programı sonlandır


# --- 3. Görüntü İşleme ve Tahmin Fonksiyonları ---

def preprocess_image(image_path):
    """Verilen yoldaki görüntüyü okur, yeniden boyutlandırır ve modele uygun hale getirir."""
    # Görüntüyü OpenCV ile oku
    image = cv2.imread(image_path)
    # OpenCV BGR formatında okur, Matplotlib ve TF RGB kullanır, bu yüzden dönüştür
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

    # Orijinal görüntüyü (boyutlandırılmış halini) daha sonra kullanmak için sakla
    resized_original_image = cv2.resize(image, (IMG_WIDTH, IMG_HEIGHT))

    # Görüntüyü normalize et (0-1 arasına)
    preprocessed_image = resized_original_image / 255.0

    return resized_original_image, preprocessed_image


def predict_mask(model, image_tensor):
    """Modeli kullanarak bir görüntü için maske tahmini yapar."""
    # Model bir grup (batch) resim beklediği için fazladan bir boyut ekliyoruz
    image_tensor_batch = np.expand_dims(image_tensor, axis=0)

    # Tahmini yap
    predicted_mask = model.predict(image_tensor_batch)

    # Tahmin sonucundan eklediğimiz boyutu geri kaldırıyoruz
    predicted_mask = predicted_mask[0]

    # Sigmoid çıktısını (0-1 arası ondalık) ikili (0 veya 1) maskeye çeviriyoruz
    # 0.5'ten büyük pikseller mantar (1), küçükler arka plan (0) kabul edilsin.
    binary_mask = (predicted_mask > 0.5).astype(np.uint8)

    return binary_mask


# --- 4. Ana İşlem Akışı ---

# 1. Görüntüyü ön işle
original_img, processed_img = preprocess_image(IMAGE_PATH)

# 2. Maskeyi tahmin et
predicted_mask = predict_mask(model, processed_img)

# 3. Maskeyi kullanarak arka planı siyah yap
# Orijinal (boyutlandırılmış) görüntüyü maske ile çarpıyoruz.
# Maskede arka plan 0 olduğu için, bu pikseller 0 (siyah) ile çarpılacak.
# Mantar pikselleri 1 olduğu için, bu pikseller 1 ile çarpılıp aynı kalacak.
final_result = original_img * predicted_mask

# --- 5. Sonuçları Göster ---

plt.figure(figsize=(15, 6))

# Orijinal Görüntü
plt.subplot(1, 3, 1)
plt.title("1. Orijinal Görüntü")
plt.imshow(original_img)
plt.axis('off')

# Tahmin Edilen Maske
plt.subplot(1, 3, 2)
plt.title("2. Modelin Bulduğu Maske")
plt.imshow(predicted_mask, cmap='gray')
plt.axis('off')

# Sonuç
plt.subplot(1, 3, 3)
plt.title("3. Sonuç: Arka Planı Silinmiş Mantar")
plt.imshow(final_result)
plt.axis('off')

plt.tight_layout()
plt.show()
# --- 6. Arka planı silinmiş mantar fotoğrafını kaydet ---
output_path = "arka_plani_silinmis_mantar.png"
cv2.imwrite(output_path, cv2.cvtColor(final_result, cv2.COLOR_RGB2BGR))
print(f"✅ Arka planı silinmiş mantar kaydedildi: {output_path}")