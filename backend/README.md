# Heltigo Backend API

Backend ini dibangun menggunakan **Node.js (Express.js)** dengan arsitektur microservice. Aplikasi ini bertindak sebagai Orchestrator & API Gateway yang menangani Authentication, CRUD Database dengan MySQL, dan meneruskan *logic* AI ke ML Microservice (FastAPI).

## 🛠 Prerequisites

Sebelum menjalankan aplikasi ini, pastikan Anda telah menginstal:
- **Node.js** (Rekomendasi versi 20 LTS atau terbaru)
- **Local MySQL Server** (Bisa menggunakan XAMPP, Laragon, MAMP, atau MySQL Installer bawaan)

---

## 🚀 Step-by-Step Menjalankan Backend (Local)

### 1. Menyiapkan Database
Nyalakan service **MySQL** lokal Anda (misalnya: buka control panel XAMPP/Laragon, klik Start pada MySQL). 
*(Tidak perlu membuat database secara manual, Prisma akan membuatnya otomatis jika belum ada).*

### 2. Menginstal Dependensi
Buka terminal / command prompt, pastikan Anda berada di direktori `backend/`, lalu jalankan:
```bash
npm install
```

### 3. Mengatur Environment Variables (`.env`)
Di dalam folder `backend/` sudah terdapat file `.env` dengan konfigurasi default. Buka dan sesuaikan baris `DATABASE_URL` jika MySQL Anda memiliki password:
```env
# Default setting XAMPP/Laragon (tanpa password):
DATABASE_URL=mysql://root:@localhost:3306/heltigo

# Jika MySQL Anda menggunakan password (misal passwordnya "12345"):
# DATABASE_URL=mysql://root:12345@localhost:3306/heltigo
```

### 4. Menjalankan Migrasi & Sinkronisasi Prisma
Untuk membuat tabel-tabel sesuai dengan desain di database MySQL, jalankan:
```bash
npx prisma migrate dev --name init
```
Setelah itu, generate ulang Prisma Client agar TypeScript mengenali tipe datanya:
```bash
npx prisma generate
```

### 5. Menjalankan Server Development
Sekarang, jalankan server API lokal Anda dengan perintah:
```bash
npm run dev
```
Jika berhasil, terminal akan menampilkan log:
```
Heltigo API listening on :3000
```
API Anda sekarang berjalan di `http://localhost:3000`. Cek status dengan membuka link: [http://localhost:3000/health](http://localhost:3000/health).

---

## 📦 Build untuk Production

Jika Anda ingin melakukan proses *build* ke versi produksi, jalankan:
```bash
npm run build
npm start
```

## 🔄 Integrasi ML (FastAPI)
Microservice backend ini berkomunikasi dengan ML Microservice. Agar fitur *generative plan* berjalan sempurna, pastikan Anda juga menyalakan FastAPI Machine Learning Anda di port yang disetel di dalam `.env` (`ML_SERVICE_URL=http://localhost:8001`).
