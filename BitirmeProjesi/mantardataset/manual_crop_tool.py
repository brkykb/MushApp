import cv2
import numpy as np
import os
import tkinter as tk
from tkinter import filedialog

# --- Ayarlar ---
output_dir = "output_crops"
target_size = 224
counter_file = "crop_counter.txt"
os.makedirs(output_dir, exist_ok=True)

# --- Global değişkenler ---
ref_point = []
drawing = False
crop_count = 0
original_image = None
display_image = None
current_x, current_y = -1, -1
selected_image_path = None


def load_crop_count():
    if os.path.exists(counter_file):
        with open(counter_file, "r") as f:
            try:
                return int(f.read().strip())
            except ValueError:
                return 0
    return 0


def save_crop_count(count):
    with open(counter_file, "w") as f:
        f.write(str(count))


def add_padding_and_resize(image, size=224):
    h, w = image.shape[:2]
    scale = size / max(w, h)
    new_w, new_h = int(w * scale), int(h * scale)
    resized = cv2.resize(image, (new_w, new_h))
    top = (size - new_h) // 2
    bottom = size - new_h - top
    left = (size - new_w) // 2
    right = size - new_w - left
    padded = cv2.copyMakeBorder(resized, top, bottom, left, right,
                                cv2.BORDER_CONSTANT, value=[0, 0, 0])
    return padded


def click_event(event, x, y, flags, param):
    global ref_point, drawing, crop_count, original_image, current_x, current_y

    if event == cv2.EVENT_LBUTTONDOWN:
        ref_point = [(x, y)]
        drawing = True

    elif event == cv2.EVENT_MOUSEMOVE:
        current_x, current_y = x, y

    elif event == cv2.EVENT_LBUTTONUP:
        ref_point.append((x, y))
        drawing = False
        cv2.rectangle(param, ref_point[0], ref_point[1], (0, 0, 255), 2)
        x1, y1 = min(ref_point[0][0], ref_point[1][0]), min(ref_point[0][1], ref_point[1][1])
        x2, y2 = max(ref_point[0][0], ref_point[1][0]), max(ref_point[0][1], ref_point[1][1])
        roi = original_image[y1:y2, x1:x2]

        if roi.size > 0:
            padded = add_padding_and_resize(roi, target_size)
            save_path = os.path.join(output_dir, f"image_{crop_count:04d}.jpg")
            cv2.imwrite(save_path, padded)
            print(f"[+] Kaydedildi: {save_path}")
            crop_count += 1
            save_crop_count(crop_count)


def select_new_image():
    """File dialogdan yeni fotoğraf seç."""
    root = tk.Tk()
    root.withdraw()
    img_path = filedialog.askopenfilename(
        title="Bir fotoğraf seçin",
        filetypes=[("Resim Dosyaları", "*.jpg *.jpeg *.png")]
    )
    root.destroy()
    return img_path


def process_image_loop():
    """Seçilen fotoğrafla crop döngüsünü başlat."""
    global original_image, display_image, selected_image_path

    while True:
        image = cv2.imread(selected_image_path)
        if image is None:
            print(f"⚠️ Görsel okunamadı: {selected_image_path}")
            selected_image_path = select_new_image()
            if not selected_image_path:
                print("⚠️ Yeni fotoğraf seçilmedi. Çıkılıyor.")
                break
            continue

        original_image = image.copy()
        display_image = image.copy()

        cv2.namedWindow("Image", cv2.WINDOW_NORMAL)
        cv2.setMouseCallback("Image", click_event, display_image)

        print("\n📌 Fareyle crop yapın. ESC ile çık, 'n' tuşuyla resmi silip yeni seçin.\n")

        while True:
            temp_display = display_image.copy()
            if drawing and len(ref_point) == 1:
                cv2.rectangle(temp_display, ref_point[0], (current_x, current_y), (0, 0, 255), 2)
            cv2.imshow("Image", temp_display)

            key = cv2.waitKey(1) & 0xFF
            if key == 27:  # ESC
                cv2.destroyAllWindows()
                return  # tamamen çık
            elif key == ord('n'):  # yeni fotoğraf
                cv2.destroyAllWindows()
                if os.path.exists(selected_image_path):
                    os.remove(selected_image_path)
                    print(f"🗑️ Silindi: {selected_image_path}")
                selected_image_path = select_new_image()
                if not selected_image_path:
                    print("⚠️ Yeni fotoğraf seçilmedi. Çıkılıyor.")
                    return
                break  # iç döngüden çık, yeni resme geç


# --- Başlat ---
crop_count = load_crop_count()
print(f"🔢 Başlangıç crop sayısı: {crop_count}")

selected_image_path = select_new_image()
if not selected_image_path:
    print("⚠️ Fotoğraf seçilmedi, çıkılıyor.")
    exit()

process_image_loop()
cv2.destroyAllWindows()
