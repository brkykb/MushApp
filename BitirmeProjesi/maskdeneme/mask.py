import os
import cv2
import numpy as np
import tensorflow as tf
from tensorflow.keras.layers import Input, Conv2D, MaxPooling2D, Conv2DTranspose, concatenate
from tensorflow.keras.models import Model
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.losses import BinaryCrossentropy
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
import albumentations as A
from tensorflow.keras.callbacks import EarlyStopping

# --- 1. Konfigürasyon ve Ayarlar ---
# Projenin ana klasör yollarını kendi bilgisayarına göre güncelle!
TRAIN_PATH = 'dataset/train/'
VALID_PATH = 'dataset/valid/'
TEST_PATH = 'dataset/test/'

# Modelin kullanacağı görüntü boyutları ve diğer parametreler
IMG_HEIGHT = 256
IMG_WIDTH = 256
IMG_CHANNELS = 3  # Renkli görüntüler için 3
BATCH_SIZE = 8  # GPU belleğinize göre bu değeri artırıp azaltabilirsiniz (örn: 4, 8, 16)
EPOCHS = 50  # Eğitim süresi (deneme için 25-50 ile başlayabilirsiniz)


# --- 2. Veri Yükleme ve Hazırlama Fonksiyonları ---

def load_and_preprocess_data(path):
    """
    Verilen klasördeki resimleri ve maskeleri, dosya adlarındaki desene göre bulan,
    yükleyen ve ön işleyen bir fonksiyon.
    """
    image_paths = []
    mask_paths = []

    # Klasördeki tüm dosyaları listele
    for filename in sorted(os.listdir(path)):
        # Dosya bir maske değilse, o bir resimdir.
        if '_mask.png' not in filename and (filename.endswith('.jpg') or filename.endswith('.png')):
            # Resim yolunu listeye ekle
            image_path = os.path.join(path, filename)

            # Resim dosya adından maske dosya adını oluştur
            # Örnek: '..._jpg.rf.hash.jpg' -> '..._jpg.rf.hash_mask.png'
            base_name = os.path.splitext(filename)[0]
            mask_filename = base_name + '_mask.png'
            mask_path = os.path.join(path, mask_filename)

            # Eğer maske dosyası gerçekten varsa, yolları listelere ekle
            if os.path.exists(mask_path):
                image_paths.append(image_path)
                mask_paths.append(mask_path)

    return image_paths, mask_paths


def parse_image_and_mask(image_path, mask_path):
    """
    Verilen yollardan bir resmi ve maskeyi okur, boyutlandırır ve formatlar.
    """
    # Görüntüyü oku ve renk formatını RGB'ye çevir
    image = tf.io.read_file(image_path)
    image = tf.image.decode_jpeg(image, channels=IMG_CHANNELS)
    image = tf.image.resize(image, [IMG_HEIGHT, IMG_WIDTH])
    image = image / 255.0  # Pikselleri 0-1 arasına normalize et

    # Maskeyi oku
    mask = tf.io.read_file(mask_path)
    mask = tf.image.decode_png(mask, channels=1)  # Maskeler tek kanallıdır
    mask = tf.image.resize(mask, [IMG_HEIGHT, IMG_WIDTH], method='nearest')
    mask = tf.cast(mask > 0, dtype=tf.float32)  # Pikselleri 0 veya 1 yap

    return image, mask


# --- 3. Veri Çoğaltma (Data Augmentation) ---

# Albumentations ile kullanılacak çoğaltma teknikleri
augmenter = A.Compose([
    A.HorizontalFlip(p=0.5),
    A.Rotate(limit=15, p=0.7),
    A.RandomBrightnessContrast(p=0.5),
    A.GaussNoise(p=0.2)
])


def augment_data(image, mask):
    # Görüntü ve maskeyi NumPy formatına çevir
    image_np = image.numpy()
    mask_np = mask.numpy()

    # Augmentation'ı uygula
    augmented = augmenter(image=image_np, mask=mask_np)

    # Tekrar TensorFlow tensörlerine çevir
    aug_image = tf.convert_to_tensor(augmented['image'], dtype=tf.float32)
    aug_mask = tf.convert_to_tensor(augmented['mask'], dtype=tf.float32)

    return aug_image, aug_mask


def tf_augment_data(image, mask):
    # Albumentations fonksiyonunu TensorFlow veri hattında kullanmak için sarmala
    aug_image, aug_mask = tf.py_function(augment_data, [image, mask], [tf.float32, tf.float32])
    aug_image.set_shape([IMG_HEIGHT, IMG_WIDTH, IMG_CHANNELS])
    aug_mask.set_shape([IMG_HEIGHT, IMG_WIDTH, 1])
    return aug_image, aug_mask


# --- 4. TensorFlow Veri Hattı (tf.data.Dataset) ---

def create_dataset(image_paths, mask_paths, augment=False):
    dataset = tf.data.Dataset.from_tensor_slices((image_paths, mask_paths))
    dataset = dataset.map(parse_image_and_mask, num_parallel_calls=tf.data.AUTOTUNE)

    if augment:
        dataset = dataset.map(tf_augment_data, num_parallel_calls=tf.data.AUTOTUNE)

    dataset = dataset.batch(BATCH_SIZE)
    dataset = dataset.prefetch(buffer_size=tf.data.AUTOTUNE)

    return dataset


# Veri yollarını yükle
train_images, train_masks = load_and_preprocess_data(TRAIN_PATH)
valid_images, valid_masks = load_and_preprocess_data(VALID_PATH)

# Veri setlerini oluştur
train_dataset = create_dataset(train_images, train_masks, augment=True)
valid_dataset = create_dataset(valid_images, valid_masks)

print(f"Eğitim için {len(train_images)} görüntü bulundu.")
print(f"Doğrulama için {len(valid_images)} görüntü bulundu.")


# --- 5. U-Net Model Mimarisi ---

def build_unet(input_shape):
    inputs = Input(input_shape)

    # Encoder (Daralan Yol)
    c1 = Conv2D(16, (3, 3), activation='relu', kernel_initializer='he_normal', padding='same')(inputs)
    c1 = Conv2D(16, (3, 3), activation='relu', kernel_initializer='he_normal', padding='same')(c1)
    p1 = MaxPooling2D((2, 2))(c1)

    c2 = Conv2D(32, (3, 3), activation='relu', kernel_initializer='he_normal', padding='same')(p1)
    c2 = Conv2D(32, (3, 3), activation='relu', kernel_initializer='he_normal', padding='same')(c2)
    p2 = MaxPooling2D((2, 2))(c2)

    # Bottleneck
    c5 = Conv2D(64, (3, 3), activation='relu', kernel_initializer='he_normal', padding='same')(p2)
    c5 = Conv2D(64, (3, 3), activation='relu', kernel_initializer='he_normal', padding='same')(c5)

    # Decoder (Genişleyen Yol)
    u6 = Conv2DTranspose(32, (2, 2), strides=(2, 2), padding='same')(c5)
    u6 = concatenate([u6, c2])
    c6 = Conv2D(32, (3, 3), activation='relu', kernel_initializer='he_normal', padding='same')(u6)
    c6 = Conv2D(32, (3, 3), activation='relu', kernel_initializer='he_normal', padding='same')(c6)

    u7 = Conv2DTranspose(16, (2, 2), strides=(2, 2), padding='same')(c6)
    u7 = concatenate([u7, c1])
    c7 = Conv2D(16, (3, 3), activation='relu', kernel_initializer='he_normal', padding='same')(u7)
    c7 = Conv2D(16, (3, 3), activation='relu', kernel_initializer='he_normal', padding='same')(c7)

    # Çıktı katmanı
    outputs = Conv2D(1, (1, 1), activation='sigmoid')(c7)

    model = Model(inputs=[inputs], outputs=[outputs])
    return model


# --- 6. Modelin Derlenmesi ve Eğitilmesi ---
# ... (Kodun önceki kısımları aynı kalacak) ...
 # YENİ: EarlyStopping'i import et


# Modeli oluştur
model = build_unet((IMG_HEIGHT, IMG_WIDTH, IMG_CHANNELS))
model.compile(optimizer=Adam(learning_rate=1e-4), loss=BinaryCrossentropy(), metrics=['accuracy'])
model.summary()

# YENİ: EarlyStopping callback'ini tanımla
# Bu callback, 'val_loss' (doğrulama kaybı) metriğini izleyecek.
# 10 epoch boyunca 'val_loss' değerinde bir iyileşme olmazsa eğitimi durduracak.
# 'restore_best_weights=True' sayesinde, durduğunda en iyi epoch'taki ağırlıkları modele geri yükleyecek.
early_stopping = EarlyStopping(
    monitor='val_loss',
    patience=10,
    restore_best_weights=True,
    verbose=1
)

# Modeli eğit
# YENİ: callbacks parametresini model.fit() fonksiyonuna ekle
history = model.fit(
    train_dataset,
    validation_data=valid_dataset,
    epochs=EPOCHS,
    callbacks=[early_stopping] # Callback'i burada listeye ekliyoruz
)

# Modeli kaydet
model.save('mantar_segmentasyon_unet.keras')

# ... (Kodun geri kalanı ve görselleştirme fonksiyonları aynı kalacak) ...


# --- 7. Sonuçların Görselleştirilmesi ---

def plot_history(history):
    # Kayıp (loss) grafiği
    plt.figure(figsize=(12, 5))
    plt.subplot(1, 2, 1)
    plt.plot(history.history['loss'], label='Eğitim Kaybı')
    plt.plot(history.history['val_loss'], label='Doğrulama Kaybı')
    plt.title('Eğitim ve Doğrulama Kaybı')
    plt.xlabel('Epoch')
    plt.ylabel('Kayıp (Loss)')
    plt.legend()

    # Doğruluk (accuracy) grafiği
    plt.subplot(1, 2, 2)
    plt.plot(history.history['accuracy'], label='Eğitim Doğruluğu')
    plt.plot(history.history['val_accuracy'], label='Doğrulama Doğruluğu')
    plt.title('Eğitim ve Doğrulama Doğruluğu')
    plt.xlabel('Epoch')
    plt.ylabel('Doğruluk (Accuracy)')
    plt.legend()
    plt.show()


def visualize_predictions(dataset, num_samples=3):
    plt.figure(figsize=(15, num_samples * 5))
    for i, (image, true_mask) in enumerate(dataset.unbatch().take(num_samples)):
        pred_mask = model.predict(tf.expand_dims(image, 0))[0]

        plt.subplot(num_samples, 3, i * 3 + 1)
        plt.title("Orijinal Görüntü")
        plt.imshow(image)
        plt.axis('off')

        plt.subplot(num_samples, 3, i * 3 + 2)
        plt.title("Gerçek Maske")
        plt.imshow(true_mask, cmap='gray')
        plt.axis('off')

        plt.subplot(num_samples, 3, i * 3 + 3)
        plt.title("Tahmin Edilen Maske")
        plt.imshow(pred_mask, cmap='gray')
        plt.axis('off')
    plt.tight_layout()
    plt.show()


# Eğitim geçmişini çizdir
plot_history(history)

# Doğrulama setinden birkaç örnek üzerinde tahminleri görselleştir
visualize_predictions(valid_dataset)