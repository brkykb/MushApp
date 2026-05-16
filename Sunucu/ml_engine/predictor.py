import os
import numpy as np
import cv2
from tensorflow.keras.models import load_model
from django.conf import settings

# Ayarlar
IMG_SIZE = 224

# SENİN GERÇEK LİSTEN (Alfabetik olduğundan emin olmalısın)
# Eğitim setindeki klasör isimlerinle birebir aynı olmalı.
CLASS_NAMES = [
    'Agaricus Campestris', 'Amanita Caesarea', 'Amanita Muscaria', 'Amanita Pantherina',
    'Amanita Phalloides', 'Armillaria Mellea', 'Boletus Edulis', 'Chlorophyllum Molybdites',
    'Coprinus Comatus', 'Craterellus Cornucopioides', 'Flammulina Velutipes', 'Ganoderma Lucidum',
    'Gyromitra Esculenta', 'Hericium Erinaceus', 'Lactarius Deliciosus', 'Laetiporus Sulphureus',
    'Lycoperdon Perlatum', 'Macrolepiota Procera', 'Morchella Esculenta', 'Omphalotus Olearius',
    'Pleurotus ostreatus', 'Rubroboletus Satanas', 'Russula Emetica', 'Russula Virencens', 'Suillus Luteus',
]


class MushroomPredictor:
    _model = None

    @classmethod
    def _load_model(cls):
        if cls._model is None:
            # Model dosya ismini kontrol et (model_94_acc.keras vs)
            model_path = os.path.join(settings.BASE_DIR, 'ml_engine', 'models', 'model_94_acc.keras')
            print(f"🧠 Model Yükleniyor... ({model_path})")
            if not os.path.exists(model_path):
                print("❌ HATA: Model dosyası bulunamadı!")
            else:
                cls._model = load_model(model_path, compile=False)
                print("✅ Model Başarıyla Yüklendi!")
        return cls._model

    @staticmethod
    def predict(image_path):
        # Modeli getir
        model = MushroomPredictor._load_model()
        if model is None:
            return {"class": "Model Hatası", "confidence": 0.0}

        # 1. Resmi Oku
        print(f"📂 Okunan Resim: {image_path}")
        img = cv2.imread(image_path)

        if img is None:
            print("❌ HATA: Resim okunamadı! Yol yanlış veya dosya bozuk.")
            return {"class": "Dosya Hatası", "confidence": 0.0}

        # 2. RENK DÜZELTME (BGR -> RGB)
        # OpenCV renkleri Mavi-Yeşil-Kırmızı okur, Model Kırmızı-Yeşil-Mavi ister.
        # Bu satır olmazsa model kırmızı mantarı mavi sanar!
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

        # 3. Ön İşleme
        img = cv2.resize(img, (IMG_SIZE, IMG_SIZE))
        img = np.expand_dims(img.astype(np.float32), axis=0)

        # 4. Tahmin
        preds = model.predict(img, verbose=0)[0]

        # --- DEBUG: Terminal Çıktısı ---
        # Modelin hangi sınıfa ne kadar puan verdiğini görelim
        top_3_indices = preds.argsort()[-3:][::-1]
        print("-" * 40)
        print("🔍 MODELİN TAHMİNİ (TOP 3):")
        for i in top_3_indices:
            print(f"   -> {CLASS_NAMES[i]}: %{preds[i] * 100:.2f}")
        print("-" * 40)
        # -------------------------------

        score = float(np.max(preds))
        class_idx = np.argmax(preds)

        return {
            "class": CLASS_NAMES[class_idx],
            "confidence": round(score * 100, 2)
        }