# MushApp 🍄

**MushApp** is a state-of-the-art mushroom identification and classification platform. It leverages Deep Learning to help users identify various mushroom species with high accuracy while providing a rich encyclopedia, community features, and a gamified experience.

---

## 📱 Features

### 🔍 AI-Powered Identification
Scan mushrooms in real-time using our custom-trained deep learning models. Get instant results with confidence scores and detailed species information.
> *[Place AI Scanner Screenshot Here]*

### 📖 Mushroom Wiki & Encyclopedia
Explore a comprehensive library of mushrooms with high-quality images, descriptions, edibility status, and ecological roles.
> *[Place Wiki Screenshot Here]*

### 🔐 Secure Authentication
Seamless login and registration system supporting email/password and Firebase authentication.
> *[Place Login/Register Screenshot Here]*

### 🗺️ Mushroom Mapping
Keep track of where you've found specific mushrooms and explore findings around you.
> *[Place Map Screenshot Here]*

### 🛒 In-App Shop & Rewards
Earn XP, level up, and use in-app currency to unlock special features or items.
> *[Place Shop Screenshot Here]*

### 🏠 Personalized Home Dashboard
Stay updated with the "Mushroom of the Day," your recent scans, and quick stats.
> *[Place Dashboard Screenshot Here]*

---

## 🛠️ Technology Stack

### Mobile Frontend
- **Framework:** [Flutter](https://flutter.dev/)
- **State Management:** Provider
- **Networking:** Dio
- **Authentication:** Firebase Auth

### Backend
- **Framework:** [Django](https://www.djangoproject.com/) & Django REST Framework
- **Database:** PostgreSQL (Production) / SQLite (Development)
- **Machine Learning:** TensorFlow / Keras
- **Containerization:** Docker & Docker Compose
- **Server:** Nginx + Gunicorn

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK
- Python 3.10+
- Docker (optional, for backend deployment)

### Backend Setup (Sunucu)
1. Clone the repository and navigate to the `Sunucu` folder.
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Copy `.env.example` to `.env` and fill in your secrets:
   ```bash
   cp .env.example .env
   ```
4. Run migrations:
   ```bash
   python manage.py migrate
   ```
5. Start the server:
   ```bash
   python manage.py runserver
   ```

### Mobile Setup (MushApp)
1. Navigate to the `MushApp` folder.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. (Optional) Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective folders.
4. Run the app:
   ```bash
   flutter run
   ```

---

## 📄 License
This project is for educational/personal use. Please check the LICENSE file for more details.

---

## 👥 Contributors
- **Berkay Karabulut** - *Project Owner & Lead Developer*

---
*Created with ❤️ for mushroom enthusiasts.*
