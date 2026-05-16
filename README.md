# Heltigo — AI-Powered Personal Health & Fitness

Aplikasi mobile yang menyediakan rekomendasi workout & meal personal berbasis AI, serta adaptive weekly replanning. Dibangun untuk Hackathon MSU iREX 2026.

**Arsitektur Utama:**
1. **Mobile Frontend:** Flutter (`frontend/heltigo`)
2. **REST API Backend:** Node.js + Express.js (`backend/`)
3. **Machine Learning Microservice:** Python + FastAPI (`machine-learning/ml-service/`)

---

## 🛠 Prasyarat Sistem
Pastikan perangkat Anda sudah terinstal perangkat lunak berikut sebelum menjalankan proyek:
- [Node.js](https://nodejs.org/) (Versi 18+ direkomendasikan)
- [Python](https://www.python.org/) (Versi 3.10 hingga 3.13)
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- MySQL Server (untuk database lokal)

---

## 🚀 Panduan Menjalankan Proyek (Langkah demi Langkah)

Untuk menjalankan seluruh sistem secara lokal, **sangat disarankan** untuk menjalankan servis secara berurutan mulai dari ML Service, Backend, dan terakhir Frontend.

### Langkah 1: Persiapan Pre-Trained Models (.pkl, .npy)
Karena limitasi ukuran file di GitHub, file model berukuran besar (seperti `.pkl` dan `.npy`) **tidak ikut ter-push**. Anda harus mengunduhnya secara manual sebelum menjalankan ML Service.

1. Download kumpulan model Heltigo melalui link berikut:
   👉 **[LINK DOWNLOAD MODELS (.ZIP) - (MASUKKAN LINK DISINI)]** 
   *(Catatan untuk dev: Upload folder `training_model` ke Google Drive / GitHub Releases, lalu taruh link-nya di sini).*
2. Ekstrak file `.zip` tersebut.
3. *Copy-paste* seluruh folder (timpa folder yang ada) ke dalam direktori:
   `machine-learning/notebook/training_model/`
   
Pastikan file seperti `food_name_matrix.npy` dan `workout_xgb_v3_type.pkl` sudah berada di dalam subfolder masing-masing model.

### Langkah 2: Menjalankan Machine Learning Service (FastAPI)
Service ini menangani komputasi AI (Food Scan, Meal Plan, Workout Plan, dll) dan berjalan di port `8001`.

1. Buka terminal baru dan masuk ke folder `ml-service`:
   ```bash
   cd machine-learning/ml-service
   ```
2. Buat Python Virtual Environment:
   ```bash
   python -m venv venv
   ```
3. Aktifkan Virtual Environment:
   - **Windows:** `.\venv\Scripts\activate`
   - **Mac/Linux:** `source venv/bin/activate`
4. Install semua dependensi:
   ```bash
   pip install -r requirements.txt
   ```
5. Salin dan sesuaikan konfigurasi environment:
   ```bash
   cp .env.example .env
   ```
   *(Pastikan variabel `GEMINI_API_KEY` dan `ML_SERVICE_KEY` sudah terisi di dalam `.env`)*
6. Jalankan ML service:
   ```bash
   python main.py
   # Service akan aktif di http://localhost:8001
   ```

### Langkah 3: Menjalankan Backend Express.js
Backend bertindak sebagai jembatan yang menghubungkan request mobile (Frontend) menuju ML Service dan juga mengatur Database/Auth. Backend berjalan di port `3000`.

1. Buka terminal baru dan masuk ke folder `backend`:
   ```bash
   cd backend
   ```
2. Install semua modul Node.js:
   ```bash
   npm install
   ```
3. Konfigurasi file environment (Pastikan `ML_SERVICE_URL` mengarah ke `http://localhost:8001`):
   ```bash
   cp .env.example .env
   ```
4. Generate Prisma Client (ORM):
   ```bash
   npx prisma generate
   ```
5. Mulai Server Mode Development:
   ```bash
   npm run dev
   # Service akan aktif di http://localhost:3000
   ```

### Langkah 4: Menjalankan Frontend Flutter
Ini adalah aplikasi antarmuka bagi end-user yang bisa dijalankan melalui Emulator Android, Simulator iOS, atau Chrome.

1. Buka terminal baru dan masuk ke folder flutter:
   ```bash
   cd frontend/heltigo
   ```
2. Tarik semua dependensi pub package:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi (pilih target device Anda ketika diminta, misalnya emulator):
   ```bash
   flutter run
   ```

---

## 🔑 Environment Variables (Daftar Kunci .env)

### `backend/.env`
- `PORT`: 3000
- `DATABASE_URL`: URI koneksi MySQL lokal
- `JWT_SECRET`: Secret key bebas, minimal 32 karakter
- `ML_SERVICE_URL`: `http://localhost:8001` *(wajib)*
- `ML_SERVICE_KEY`: Key unik (contoh: `dev-shared-secret-change-in-prod`) yang harus cocok dengan milik ML Service.

### `machine-learning/ml-service/.env`
- `PORT`: 8001
- `ML_SERVICE_KEY`: Key unik yang sama dengan `backend/.env`
- `GEMINI_API_KEY`: API Key Gemini Google (didapatkan dari Google AI Studio) untuk fitur Food Scan.

---

## 🎯 3 Model Machine Learning
Kami memiliki beragam model spesifik di dalam folder `notebook/training_model/`:
1. **Rekomendasi Latihan:** Memakai XGBoost Classifier (multi-output)
2. **Perencana Makan:** Memakai Knapsack Algorithm + Genetic Algorithm (DEAP)
3. **Adaptif Perencanaan Ulang:** Rule-based + XGBoost Regressor + Thompson Sampling
4. **Food Analyzer:** Gemini Vision API + TF-IDF Vectorizer

## 💾 Keterangan Dataset (Opsional - Jika ingin Train Model Sendiri)
Jika Anda ingin melatih ulang (retrain) model dari Jupyter Notebook yang ada di folder `notebook/`, perhatikan bahwa file **`programs_detailed_boostcamp_kaggle.csv` (282MB)** tidak di-push ke GitHub karena melebihi batas 100MB.

Cara mengunduhnya:
1. Kunjungi [Kaggle Dataset](https://www.kaggle.com/datasets/) dan cari "600K+ Fitness Exercise & Workout Program Dataset" (Boostcamp).
2. Letakkan file `.csv` tersebut di: 
   `notebook/dataset/Model_rekomendasi_Pelatihan/600K+ Fitness Exercise & Workout Program Dataset/`

---

## 📖 Dokumentasi Lengkap
Untuk pemahaman mendalam tentang alur data, rancangan arsitektur, dan referensi UI, kunjungi:
- 📝 [Master Plan & Arsitektur](docs/)
- 🎨 [Desain Antarmuka Frontend (47 Screens)](docs/frontend/README.md)
- ⚙️ [Spesifikasi Model ML](docs/machine-learning/README.md)

---