# Frontend — Spesifikasi 47 Layar

> 📌 **Update 2026-05-15** — Total layar **47** (sebelumnya 35). Tambahan & perubahan:
>
> ### Screen baru yang sudah ada di kode tapi belum di-doc sebelumnya:
> - **S-21b Workout Session Detail** — recap sesi latihan yang sudah selesai, dipanggil dari S-21 tap "Lihat Detail". Path: `/workout/session/:sessionId`.
> - **S-23b Meal Swap** — UI alternatif makan saat user tap "Minta Alternatif" di S-23. Path: `/meal/swap/:mealId`.
> - **S-25b Meal Log History** — riwayat catatan makan harian. Path: `/meal/log/:mealId`.
> - **S-38 Health Metrics Detail** — full history tinggi/berat/BMI. Path: `/profile/health-metrics`.
> - **S-39 Plan History** — list plan masa lalu. Path: `/profile/plan-history`.
> - **Error & Offline screens** — generic error page + offline indicator.
>
> ### Replanning flow diperluas dari 2 → 4 screen:
> - **S-34** Replanning Evaluation (`/replanning/evaluation`)
> - **S-34b** Replanning Update Data (`/replanning/update`)
> - **S-34c** Replanning Choose (`/replanning/choose`)
> - **S-35** Replanning Ready (`/replanning/ready`)
>
> ### Screen yang sudah dirombak dari spec lama:
> - **S-16 Program Latihanku** — dari "carousel 7 hari" → **vertical list 7 hari** dengan card progress teal + sticky CTA "Mulai Hari Ini".
> - **S-17 Workout Day Detail** — dari "big card per exercise" → **compact checkbox row** (`_ExerciseCheckRow`) dengan hero card teal kecil + sticky CTA.
>
> ### Endpoint mapping per screen:
> Lihat tabel di [`docs/backend/FE_requirement/00_API_REQUIREMENTS.md`](../backend/FE_requirement/00_API_REQUIREMENTS.md) §11 — Screen→Endpoints Matrix lengkap.

---

Sumber utama: `Heltigo_UI_Screens.docx` §3-§10 + kode aktual di `frontend/heltigo/lib/screens/`. Dokumen ini menambahkan **kontrak API** dan **state Riverpod** per layar.

> **Catatan implementasi:** Project sekarang pakai **Provider + GetIt** (bukan Riverpod) sesuai keputusan terbaru — lihat `02_PROJECT_STRUCTURE.md`. Reference "State Riverpod" di doc ini = "State Provider" di kode.

Format per layar:
- **Tujuan**, **Layout/Elemen**, **Interaksi**, **Navigasi**, **API yang dipanggil**, **State Provider**.

Endpoint API merujuk ke **[`docs/backend/FE_requirement/00_API_REQUIREMENTS.md`](../backend/FE_requirement/00_API_REQUIREMENTS.md)** (source of truth). Dokumen lama `04_API_ENDPOINTS.md` sudah deprecated.

---

## BAGIAN A — Onboarding (5 layar)

### S-01 — Splash Screen

**Tujuan:** Layar pertama saat app dibuka, brand impression + boot sequence.

**Layout:**
- Background full `AppColors.primary`
- Logo SVG/PNG putih 120×120dp di tengah, FadeIn + ScaleTransition (1s, easeOut)
- Nama 'HELTIGO' 48sp Bold Inter putih, 16dp di bawah logo
- Tagline 'Smart. Offline. Hemat Budget.' 16sp Regular putih.70%, 8dp di bawah nama
- LinearProgressIndicator 4dp putih.40%, 24dp di bawah tagline
- Status bar: light icons putih
- Tidak ada tombol, tidak ada navbar

**Logic:**
1. Setelah 2.5 detik atau saat init selesai (Hive open + cek auth):
2. Cek `Hive.box('app_state').get('hasProfile')` — jika ada → `/home`
3. Jika tidak → `/onboarding`

**API:** Tidak ada (boot sequence offline)

**State:** `appBootProvider` — `AsyncValue<BootResult>` yang return `{hasProfile, isLoggedIn}`

---

### S-02 — Onboarding Slide 1: AI Personal

**Tujuan:** Slide 1 dari 3, gambaran AI personal.

**Layout:**
- Background `AppColors.background`
- Hero illustration full-width (1:1, dari `assets/images/onboarding_1.png`)
- Dot indicator 3 titik di bawah ilustrasi: aktif lebar 24dp warna primary, pasif 8dp warna `#D3D1C7`
- Badge chip 'AI POWERED' bg `primaryLight` text `primary` 11sp radius 20px
- Judul '90% Program Latihan Gagal Karena Tidak Personal' 26sp Bold maks 2 baris
- Deskripsi 'Heltigo menggunakan AI untuk membuat program yang benar-benar disesuaikan tubuh, jadwal, dan kemampuanmu.' 15sp `textSecondary` center
- `PrimaryButton 'Lanjutkan'` fixed di bawah
- TextButton 'Lewati' di AppBar kanan atas warna `textTertiary`

**Interaksi:**
- Tap 'Lanjutkan' atau swipe kiri → S-03
- Tap 'Lewati' → S-05

**API:** Tidak ada

**State:** Local PageController saja, simpan posisi di `onboardingIndexProvider`.

---

### S-03 — Onboarding Slide 2: Hemat Budget

**Layout:**
- Ilustrasi flat: makanan lokal Indonesia (nasi, tempe, sayur) + ikon koin, dominan orange & hijau
- Badge 'LOKAL INDONESIA' bg `orangeLight` text `energyOrange`
- Judul 'Makanan Bergizi Tidak Harus Mahal' 26sp Bold
- Deskripsi 'AI Heltigo memilihkan 1.346+ menu lokal Indonesia sesuai budget harianmu — mulai dari Rp15.000 per hari.' 15sp `textSecondary`
- Feature chips Row 3: [🍚 1.346+ Menu Lokal | 💰 Budget IDR/MYR | 🥗 Gizi Seimbang], bg `primaryLight`
- `PrimaryButton 'Lanjutkan'`

**Navigasi:** Tap → S-04. Swipe kanan → S-02.

---

### S-04 — Onboarding Slide 3: Offline & Privasi

**Layout:**
- Ilustrasi: ikon perisai/kunci hijau besar + smartphone
- Badge 'HYBRID OFFLINE' bg `primaryLight` text `primary` *(NOTE: dokumen original tertulis '100% OFFLINE' — sesuaikan jadi 'HYBRID OFFLINE' karena pergeseran arsitektur ke backend online)*
- Judul 'Data Kesehatanmu Tetap Privat & Selalu Tersedia' *(sesuaikan dari original 'Data Kesehatanmu Tidak Pernah Meninggalkan Ponselmu')*
- Deskripsi 'Fitur kritis tetap berjalan offline. Data sensitif terenkripsi. Privasi terjamin.'
- 3 feature cards Row: [🔒 Privasi | 📡 Hybrid Offline | ⚡ Instan]
- `PrimaryButton 'Mulai Perjalanan Saya'` (lebih besar, shadow tebal)

**Navigasi:** Tap → S-05.

---

### S-05 — Welcome / Auth Screen

**Tujuan:** Pintu masuk untuk signup atau login. **Note:** dokumen original menyebut "Lanjutkan Tanpa Akun" — di sprint ini di-skip karena auth mandatory.

**Layout:**
- Background gradient vertikal `#1A6B4A` → `#0F6E56`
- Logo + nama 'HELTIGO' putih center, 80dp logo, 36sp nama
- Tagline 'Perjalanan Sehat Dimulai Sekarang' 18sp italic putih.80%
- Kartu bawah radius top 28px, bg putih, padding 32px
- Judul kartu 'Buat Akun atau Masuk' 22sp SemiBold
- `PrimaryButton 'Buat Akun Baru'` → SignupScreen
- `SecondaryButton 'Sudah Punya Akun? Masuk'` → LoginScreen

**API:** Tidak langsung (signup/login di screen turunan).

**State:** `authStateProvider` — observe untuk redirect.

---

### Signup Screen (sub-screen, tidak di dokumen original)

**Layout:**
- AppBar transparent, back button
- Judul 'Buat Akun Heltigo' 26sp Bold
- `InputField 'Email'` (validasi format)
- `InputField 'Password'` (min 8 char, obscureText, suffix toggle visibility)
- `InputField 'Konfirmasi Password'`
- `PrimaryButton 'Daftar'`
- TextButton 'Sudah punya akun? Masuk' → LoginScreen

**API:** `POST /v1/auth/signup` body `{email, password}` → response `{user, token}`

**State:** `signupNotifierProvider` — `StateNotifier<AsyncValue<void>>`

**Sukses:** simpan token ke `flutter_secure_storage`, set `authStateProvider` → push & replace ke `/setup/step1`.

---

### Login Screen (sub-screen)

**Layout sama dengan signup**, tanpa konfirmasi password.

**API:** `POST /v1/auth/login` → `{user, token}`

**Sukses:** simpan token. Cek `user.hasProfile` → `/home` jika true, `/setup/step1` jika false.

---

## BAGIAN B — Setup Profil (9 layar)

Semua menggunakan `SetupScaffold` (lihat `04_NAVIGATION.md` §5).

### S-06 — Setup Step 1/8: Data Dasar

**Layout (di dalam SetupScaffold step=1):**
- Judul 'Hai! Kenalkan dirimu 👋'
- Subjudul 'Kami perlu beberapa informasi dasar untuk mulai.'
- `InputField 'Nama Panggilanmu'` prefix `Icons.person_outline`
- `InputField 'Usiamu (tahun)'` prefix `Icons.cake_outlined` keyboard number, validasi 10-100
- Pilih Gender: Row 2 kartu 50%-50% [Laki-laki | Perempuan]. Terpilih: border primary 2px, bg `primaryLight`, teks bold. Tidak terpilih: border `border`.
- `PrimaryButton 'Lanjutkan →'`

**API:** Tidak langsung (data masih draft, simpan ke Riverpod `setupDraftProvider`).

**Validasi:** semua field wajib, button disabled jika invalid.

**Navigasi:** S-07.

---

### S-07 — Setup Step 2/8: Data Fisik

**Layout:**
- Judul 'Berapa tinggi dan berat badanmu?'
- Toggle Satuan: Segmented kanan: [cm | inch] dan [kg | lbs]
- Input Tinggi: angka besar 40sp Bold primary di atas Slider range 100–250 cm + InputField sinkron
- Input Berat: sama, range 30–200 kg
- Lingkar Pinggang: `InputField 'Lingkar Pinggang (cm)'` opsional
- Caption '💡 Lingkar pinggang digunakan untuk estimasi lemak tubuh yang lebih akurat.' `textTertiary`
- `PrimaryButton 'Hitung BMI Saya →'`

**Logic:** Saat tap → kalkulasi BMI/BMR/TDEE/BFP via `health_calculator.dart` (offline), simpan ke `setupDraftProvider`, navigasi S-08.

---

### S-08 — Setup Step 3/8: Hasil BMI

**Layout:**
- Judul 'Hasil Profil Kesehatanmu' 24sp Bold center
- BMI Card besar gradient hijau full-width: BMI 56sp Bold putih + Label 'INDEKS MASSA TUBUH' + chip kategori (Normal/Lebih/Kurus/Obesitas) warna adaptif
- 4 Metric Cards Grid 2x2: [BMR (kkal/hari) | TDEE (kkal/hari) | % Lemak Tubuh | Berat Ideal (kg)]. Angka besar primary.
- BMI Scale Visual: LinearProgressBar gradient (biru→hijau→kuning→orange→merah). Marker segitiga posisi BMI. Label: Kurus | Normal | Lebih | Obesitas
- Penjelasan 2-3 kalimat (template berdasarkan kategori)
- `PrimaryButton 'Tetapkan Target Saya →'`

**API:** Tidak ada (kalkulasi lokal).

**Navigasi:** S-09.

---

### S-09 — Setup Step 4/8: Target Kesehatan

**Layout:**
- Judul 'Apa tujuan kesehatanmu?'
- 3 Goal Cards stack vertikal: [🔻 Turunkan Berat | ➡️ Jaga Berat | 🔺 Naikkan Massa Otot]. Terpilih: border primary 2px bg `primaryLight`.
- Input Target Berat (muncul jika bukan 'Jaga'): `InputField 'Target Berat (kg)'` nilai awal = berat ideal hasil S-08
- Slider Timeline 4–52 minggu. Label besar 'X Minggu'. Sub: 'Target aman: ±0.5kg/minggu = ±X kg total'
- Kalori Card: '🔥 Target defisit/surplus: X kkal/hari'. Warning amber jika > 600 kkal.
- `PrimaryButton 'Lanjutkan →'`

**Logic:** Hitung kalori adjustment = (target_berat - berat_sekarang) × 7700 / (timeline_weeks × 7), clamp ke ±200..500 normal, ±600 warning.

---

### S-10 — Setup Step 5/8: Kondisi Khusus

**Layout:**
- Judul 'Ada kondisi khusus yang perlu kami ketahui?'
- Subjudul opsional
- CheckboxList: [⚠️ Cedera/Nyeri Sendi | 🤰 Sedang Hamil | 💊 Diabetes Tipe 2 | 🫀 Tekanan Darah Tinggi | 🦴 Masalah Tulang | ✅ Tidak Ada Kondisi Khusus]. Tap 'Tidak Ada' → uncheck semua lainnya.
- Info Card amber: 'Jika memiliki kondisi serius, konsultasikan dengan dokter sebelum memulai program.' Icon `info_outline`.
- `PrimaryButton 'Lanjutkan →'`

---

### S-11 — Setup Step 6/8: Preferensi Latihan

**Layout:**
- Judul 'Atur preferensi latihanmu'
- Mode: 2 kartu [🏠 Home Workout (Tanpa Alat) | 🏋️ Gym (Dengan Alat)]
- Hari/Minggu: Segmented [3 Hari | 4 Hari | 5 Hari]
- Durasi Sesi: Segmented [15 Mnt | 30 Mnt | 45 Mnt | 60 Mnt]
- Waktu Favorit: 4 chip toggle multi-select [🌅 Pagi 05-08 | ☀️ Siang 11-13 | 🌤 Sore 15-18 | 🌙 Malam 19-21]
- Level Kebugaran: Segmented [Pemula | Menengah | Mahir] + deskripsi dinamis
- `PrimaryButton 'Lanjutkan →'`

---

### S-12 — Setup Step 7/8: Diet & Budget

**Layout:**
- Judul 'Preferensi makan dan anggaranmu'
- Toggle [IDR | MYR] di kanan judul field
- `InputField` budget prefix 'Rp'/'RM', placeholder '35000', keyboard number
- Quick chips: [Rp15K | Rp25K | Rp35K | Rp50K | Rp75K]. Tap → isi otomatis.
- Frekuensi Makan: Segmented [2x | 3x | 4x]
- Pantangan Diet: CheckboxList multi-select [🌙 Halal | 🥗 Vegetarian | 🥜 Bebas Kacang | 🥛 Bebas Laktosa]
- Info Card: 'AI memilih dari 1.346+ item lokal Indonesia yang memenuhi gizi dalam budgetmu.'
- `PrimaryButton 'Buat Rencana Saya! →'`

**Logic:** Tap → push ke S-13. Selama push, fire `POST /v1/profile` (simpan profile lengkap) dan `POST /v1/plan/generate`.

---

### S-13 — Setup Step 8/8: AI Processing

**Layout:**
- Background gradient soft hijau→putih
- Lottie animation `assets/lottie/ai_processing.json` 200×200dp center
- Teks utama 'AI sedang membuat rencana personalmu...' 20sp SemiBold center primary
- Step Labels rotating tiap 1.5 detik:
  1. '🏋️ Menganalisis profil fisik...'
  2. '🥗 Memilih makanan dalam budget...'
  3. '📅 Menyusun jadwal minggu pertama...'
  4. '✅ Rencana hampir siap!'
- LinearProgressIndicator 0→100% dalam ~6 detik (ease-out)
- Caption 'Proses berjalan di server kami yang aman.' *(sesuaikan dari "di dalam ponselmu")*
- Tidak ada tombol

**API:** `POST /v1/plan/generate` (sudah di-fire dari S-12). Polling state via Riverpod sampai sukses.

**Navigasi:**
- Sukses → S-14 dengan plan_id.
- Error (timeout / network) → tampilkan dialog "Gagal membuat rencana, coba lagi" + tombol Retry/Batal.

**State:** `planGenerationProvider` — `AsyncValue<Plan>`.

---

### S-14 — Plan Ready Screen

**Layout:**
- Header gradient hijau, animasi konfeti Lottie
- Judul '🎉 Rencana Pertamamu Sudah Siap, [Nama]!' putih 24sp Bold
- Card putih Ringkasan Latihan: 'X hari latihan/minggu | X menit/sesi | Mode: Home/Gym'
- Card putih Ringkasan Makan: 'Rp X/hari | X kali makan | Target: X kkal/hari'
- Card Target: 'X kg → X kg dalam X minggu'. Progress bar horizontal.
- Preview: list 3 latihan hari 1 + 3 menu makan hari 1
- `PrimaryButton 'Ayo Mulai! →'` besar bounce animation
- Caption 'Rencana diperbarui otomatis setiap Minggu malam.'

**API:** Sudah punya plan dari S-13.

**Navigasi:** Tap → push & replace ke `/home`.

---

## BAGIAN C — Tab Beranda

### S-15 — Home Dashboard

**Tujuan:** Ringkasan harian, jantung aplikasi.

**Layout (top-down dalam ScrollView dengan RefreshIndicator):**
1. **AppBar bg primary**: kiri 'Selamat [Pagi/Siang/Sore/Malam], [Nama]!' putih 20sp; kanan icon `Icons.notifications_outlined` + avatar profil (CircleAvatar)
2. **Stats Sticky Bar**: Row 3 stat [🔥 Kalori Sisa: X | 💧 Hidrasi X/8 | 🏃 Streak X Hari]. bg `primaryLight`. Border bawah primary tipis.
3. **Card Latihan Hari Ini**: gradient hijau, nama latihan + 'X sets · X reps · X mnt'. Tombol orange 'Mulai Latihan'. Jika hari istirahat: 'Hari Istirahat Aktif 💆' tanpa tombol.
4. **Card Makan Hari Ini**: Row 3 waktu [Sarapan | Makan Siang | Makan Malam]. Status ✅/⭕ per waktu.
5. **Ringkasan Makro**: 4 progress bar dengan label: Kalori (orange), Protein (hijau), Karbo (kuning), Lemak (ungu)
6. **Streak Card**: bg `purpleLight`. '🔥 Streak X Hari'. Kalimat motivasi dinamis. Badge terakhir.
7. **Jadwal Minggu**: horizontal scroll 7 chip hari. Hari latihan: bg primary putih. Istirahat: bg abu. Selesai: ✓. Hari ini: border orange.
8. **Reminder Card**: bg `amberLight`. Icon alarm. Pengingat berikutnya (makan/latihan).
9. Bottom padding 64dp.

**Greeting dinamis** (`shared/utils/greeting_helper.dart`):
- 05-10 → "Pagi"
- 10-15 → "Siang"
- 15-18 → "Sore"
- 18-24 → "Malam"

**API:**
- `GET /v1/plan/current` → ambil plan minggu ini
- `GET /v1/progress/summary` → kalori sisa, hidrasi, streak

**State:**
- `currentPlanProvider` (FutureProvider)
- `dailySummaryProvider` (FutureProvider, refresh saat pull)

**Pull to refresh:** invalidate kedua provider.

**Navigasi:**
- Tap 'Mulai Latihan' → `/workout/day/<index_hari_ini>/checkin`
- Tap waktu makan → `/nutrition/meal/<id>`
- Tap avatar → `/home/profile`
- Tap notif → `/home/profile/notification-settings` *(temporary)*

---

## BAGIAN D — Tab Latihan (6 layar)

### S-16 — Workout Home Screen

**Layout:**
- AppBar 'Program Latihanku', action `Icons.tune`
- Week Navigator: panah kiri-kanan, 'Minggu ke-X [tanggal]', sub 'X/X sesi selesai', progress ring kecil
- 7-Day List: ListTile 7 hari [Hari & Tanggal | Nama Latihan | Durasi + Jumlah Latihan | Badge status]. Selesai bg `primaryLight` + ✓. Hari ini border primary. Istirahat bg abu. Akan datang bg putih.
- Statistik Minggu: Grid 2x2 [Volume Total | Kalori Estimasi | Waktu Total | Konsistensi %]
- FAB '+ Mulai Latihan Hari Ini' bg primary, hanya muncul jika ada jadwal hari ini

**API:** `GET /v1/plan/current` (cached), `GET /v1/workout/week-stats`

**Navigasi:** Tap day → `/workout/day/:dayIndex`. FAB → `/workout/day/:today/checkin`.

---

### S-17 — Workout Day Screen

**Layout:**
- AppBar '[Nama Hari, Tanggal]' sub 'X Latihan · X Menit · Mode [Home/Gym]'
- Header Card gradient hijau: nama hari, stats row [⏱ X mnt | 🔄 X set | 💪 X latihan]. Tombol 'Mulai Sekarang' orange.
- Fase sections: '🔥 Pemanasan (5 Mnt)' → 'LATIHAN UTAMA' → '❄️ Pendinginan (5 Mnt)'
- Exercise List: ListTile [Nomor | Nama | X sets × X reps · istirahat Xs | icon info]. Swipe kanan: tandai selesai. Swipe kiri: ganti (buka substitusi sheet).
- Checkbox kiri. Saat dicentang: strikethrough, bg `primaryLight`, ✓.
- Bottom sticky `PrimaryButton 'Mulai Latihan'`

**API:**
- Data dari `currentPlanProvider`
- `POST /v1/workout/checklist` saat user centang (optimistic + queue jika offline)

**Navigasi:** Tap exercise → S-18. Tombol → S-19.

---

### S-18 — Exercise Detail Screen

**Layout:**
- Header: nama latihan H2. Badge [Home/Gym] + [Kelompok Otot]. Back button.
- Ilustrasi 200×200dp bg `primaryLight`, icon dumbbell atau gambar gerakan
- Set Info Card: 'X Set × X Repetisi' 28sp Bold primary. Sub 'Istirahat: X detik antar set'.
- Instruksi: numbered list 1-5 langkah, 15sp
- Target Otot: chips [Otot Utama] + [Otot Pendukung]
- Tips AI Card amber: 'Tips Heltigo: [saran spesifik berdasarkan kondisi user]'
- `OutlinedButton 'Ganti Latihan Ini'` → bottom sheet substitusi

**API:** Data dari plan; tips AI dari field `ai_tip` di exercise object.

---

### S-19 — Pre-Workout Check-in

**Layout:**
- Background putih atau `primaryLight` soft
- Judul 'Bagaimana kondisimu hari ini?' 24sp Bold center
- Subjudul 'AI menyesuaikan intensitas latihanmu berdasarkan ini.'
- Mood Selector: 5 emoji 48dp [😞1|😐2|🙂3|😊4|😄5]. Terpilih scale 1.3x bg `primaryLight` rounded. Label di bawah.
- Energy Selector: sama [😴1|🥱2|😐3|⚡4|🚀5]. Label 'Tingkat Energi'.
- Sleep Input: chips [<5 jam|5-6|6-7|7-8|>8 jam]. Aktif bg primary putih.
- AI Preview Card amber (muncul setelah semua diisi): 'AI menyesuaikan: [+10% volume] atau [-20% volume]'. Icon `auto_awesome`.
- `PrimaryButton 'Ayo Mulai! 💪'`

**API:**
- `POST /v1/workout/checkin` body `{plan_id, day_index, mood, energy, sleep_band}` → response `{adjusted_workout}`
- Fallback offline: pakai original workout, tampilkan toast 'Tanpa adaptasi AI (offline)'

**State:** `preWorkoutCheckinProvider` — `StateNotifier` mengelola input + submit.

**Navigasi:** Sukses → S-20 dengan adjusted_workout.

---

### S-20 — Active Workout Screen

**Layout:**
- Mode fullscreen immersive (status bar hidden, no AppBar)
- Tombol kecil 'Selesai Lebih Awal' pojok kanan atas
- Timer besar MM:SS 56sp Bold primary tengah layar. Sub 'Total Waktu Latihan'.
- Exercise Card: [Nama | Set ke-X dari Y | X Reps]. Rep counter dengan haptic feedback saat tap.
- Rest Timer (saat istirahat): bg `primaryLight`, countdown besar, progress ring orange melingkar.
- Kontrol Row: [⏮ Prev 48dp | ⏸/▶ Pause 64dp | ⏭ Next 48dp]
- Thin progress bar bawah X/X latihan
- Wakelock aktif saat di layar ini (`wakelock_plus`)

**API:**
- Tidak ada selama berjalan (semua lokal)
- Saat selesai → `POST /v1/workout/log` dengan summary

**Navigasi:** Selesai semua / tap "Selesai Lebih Awal" → S-21.

---

### S-21 — Workout Complete Screen

**Layout:**
- Header animasi Lottie konfeti, gradient hijau
- Judul 'Luar Biasa! Latihan Selesai 🎉' 26sp Bold putih
- Stats Row: 4 card [⏱ Durasi | 💪 Set Selesai | 🔄 Total Reps | 🔥 Kalori Estimasi]
- Perbandingan: '+X reps, +X mnt vs latihan terakhir'. Hijau jika naik, abu jika sama.
- Badge Baru pop-up jika ada pencapaian baru
- Streak: '🔥 Streak X Hari!' + animasi flame. '+1 hari baru!' jika streak bertambah.
- Mood After: 'Perasaan setelah latihan? 😊😐😔' — 3 opsi cepat
- `PrimaryButton 'Kembali ke Beranda'` + `SecondaryButton 'Lihat Detail'`

**API:** `POST /v1/workout/log` (idempotent dengan UUID), `POST /v1/workout/mood-after`

**Navigasi:** 'Kembali ke Beranda' → `/home`. 'Lihat Detail' → bottom sheet detail full.

---

## BAGIAN E — Tab Nutrisi (4 layar)

### S-22 — Nutrition Home Screen

**Layout:**
- AppBar 'Rencana Makanku'. Action `Icons.settings` + `Icons.calendar_today`.
- Date Navigator: Row [← | Hari Ini, [Tanggal] | →]
- Budget Card gradient orange→kuning: 'Budget: Rp X dari Rp X'. LinearProgressBar adaptif (hijau<80%, orange 80-100%, merah>100%). Sisa budget besar.
- Makro Summary Row 4: [🔥 Kalori | 🥩 Protein | 🍞 Karbo | 🥑 Lemak]. Angka saat ini/target + mini progress bar.
- Meal Sections per waktu makan (2-4x): Header [nama | kalori | status ✅/⭕]. List 2-3 item makanan.
- Hydration Card biru muda: '💧 Minum Air: X/8 gelas'. Row 8 gelas. Tombol '+1 Gelas'.
- `PrimaryButton 'Tandai Semua Selesai'` (abu jika sudah semua tercentang)

**API:**
- `GET /v1/nutrition/day?date=YYYY-MM-DD`
- `POST /v1/nutrition/checklist` (toggle meal selesai)
- `POST /v1/nutrition/hydration` (catat gelas air)

**Navigasi:** Tap meal section → `/nutrition/meal/:id`. Settings → `/nutrition/budget-settings`.

---

### S-23 — Meal Detail Screen

**Layout:**
- AppBar '[Sarapan / Makan Siang / Makan Malam / Cemilan]'. Action `Icons.refresh`.
- Header Card bg `primaryLight`: Row [Waktu | Total kalori | Harga estimasi]. Badge ✅/⭕.
- Food List ListTile [Nama | Porsi | Kalori | Harga]. Trailing: icon info + checkbox.
- Nutrition Breakdown: tabel Kalori/Protein/Karbo/Lemak + stacked color bar
- Penjelasan AI Card hijau muda: 'AI memilih ini karena...' 1-2 kalimat
- `PrimaryButton 'Tandai Sudah Dimakan'` + `SecondaryButton 'Minta Alternatif'` → loading → refresh

**API:**
- `POST /v1/nutrition/checklist` toggle meal
- `POST /v1/nutrition/alternative` body `{meal_id, exclude_food_ids}` → response `{new_meal}`

---

### S-24 — Food Item Detail

**Layout:**
- Header: nama makanan H2, chip kategori, back
- Image 200×200dp bg `primaryLight`, icon fork (atau foto)
- Harga Card bg `orangeLight`: 'Harga estimasi: Rp X per porsi.'
- Nutrition Facts Card: tabel [Kalori|Protein|Karbo|Lemak|Serat] + donut chart makro
- Porsi: 'Porsi standar: X gram / 1 [mangkuk/piring/gelas]'
- Konteks AI Card hijau muda

**API:** `GET /v1/foods/:id`

---

### S-25 — Budget Settings

**Layout:**
- AppBar 'Pengaturan Budget'
- Nilai saat ini 40sp Bold di atas field
- `InputField` besar prefix 'Rp'/'RM'
- Quick Chips Rp15K/25K/35K/50K/75K/100K
- Preview Card: 'Dengan Rp X/hari estimasi: X kkal | protein X g | karbo X g | lemak X g'. Update real-time.
- Toggle IDR ↔ MYR rate konversi otomatis
- `PrimaryButton 'Simpan Budget Baru'`. Caption 'AI membuat ulang rencana besok dengan budget ini.'

**API:** `PUT /v1/profile` field `budget_per_day` & `currency`. Trigger replan untuk hari berikutnya.

---

## BAGIAN F — Tab Progres (4 layar)

### S-26 — Progress Dashboard

**Layout:**
- AppBar 'Progres Saya'. Action [+] (tambah berat) + share.
- Target Card gradient hijau: 'X.X kg dari X kg target'. Progress bar. 'Mulai: X | Sekarang: X | Target: X'. 'Estimasi: X minggu lagi.'
- Weight Chart Card putih: LineChart fl_chart 4 minggu. Garis hijau, dot putih-hijau. Zona target: shaded kuning.
- Stats Grid 2x2: [🏋️ Total Sesi | 🔥 Total Kalori | 📅 Konsistensi % | ⏱ Total Jam]
- Streak Card bg `purpleLight`: '🔥 X Hari Streak'. Mini calendar 4 minggu (hijau=aktif, abu=istirahat, merah=miss).
- Shortcuts Row 3: [+ Catat Timbangan | 🏆 Lencana | 📊 Laporan]

**API:** `GET /v1/progress/summary`, `GET /v1/progress/weight-history?weeks=4`

---

### S-27 — Add Weight Screen (Modal Bottom Sheet)

**Layout:**
- Mode modal bottom sheet, radius top 20px, drag handle
- Tanggal: Row 'Tanggal: [DD MMM YYYY]'. Tap → DatePicker.
- Input Berat: NumberPicker atau InputField besar 40sp. Toggle kg/lbs.
- Catatan: InputField kecil opsional
- Preview Delta real-time: '+0.3 kg dari kemarin' (hijau) / '-0.5 kg' (merah)
- `PrimaryButton 'Simpan'`

**API:** `POST /v1/progress/weight` body `{date, weight_kg, note?}`. Offline: queue.

---

### S-28 — Achievement Badges

**Layout:**
- AppBar 'Lencana Pencapaian' counter 'X/Y Dibuka'
- 'X dari Y lencana dibuka.' + LinearProgressBar primary
- Filter Chips [Semua | Konsistensi | Latihan | Nutrisi | Milestone]
- Grid 3 kolom: per badge icon besar + nama + deskripsi. Terbuka: warna penuh shadow. Terkunci: grayscale 40% + 🔒.
- Tap badge → bottom sheet: judul, cara mendapat, tanggal dibuka.

Contoh: 🔥 Streak 3/7/30 | 💪 Latihan Pertama/10/50 | 🥗 Makan Sesuai 7 Hari | 🎯 Target Kalori 7 Hari | 🌅 Latihan Pagi | 🏆 Target Pertama Tercapai

**API:** `GET /v1/progress/badges`

---

### S-29 — Weekly Report

**Layout:**
- AppBar 'Laporan Minggu ke-X'. Action share.
- Header Card gradient primary: 'Laporan Minggu [range]'. Lingkaran progress besar skor % (hijau >80%, orange 50-80%, merah <50%) animasi count-up.
- Latihan Section: bar chart X/X hari selesai. [✅ X sesi | ⏭ X diskip | 📈 vs minggu lalu]. Latihan paling sering diskip.
- Nutrisi Section: [X/X hari makan sesuai | Rata-rata X% target kalori | Budget rata-rata Rp X/hari]
- Berat: grafik kecil delta '+/-X kg'
- AI Rekomendasi Card hijau muda + bintang: 'Rekomendasi AI Minggu Depan: [teks adaptif]'.
- Preview Baru: 'Rencana minggu depan tersedia!' + tombol 'Lihat Rencana →' → S-35

**API:** `GET /v1/report/weekly?week=N`

---

## BAGIAN G — Profil & Pengaturan (4 layar)

### S-30 — Profile Screen

**Layout:**
- Header gradient hijau: CircleAvatar 80dp. Nama. '[Kategori BMI] · Bergabung [Bulan Tahun]'.
- Stats Row: [Streak Tertinggi | Total Latihan | Lencana | Minggu Aktif]
- Info Card ringkasan profil (TB, BB, BMI, target). Tombol 'Edit Profil'.
- Menu List: [✏️ Edit Profil | 🔔 Notifikasi | 💰 Budget & Diet | 🌙 Tema | ℹ️ Tentang Heltigo | ❓ Bantuan & FAQ | 🚪 Logout]
- Version 'Heltigo v1.0.0 | Flutter' kecil

**API:** `GET /v1/auth/me`, `GET /v1/profile`

---

### S-31 — Edit Profile

**Layout:**
- AppBar 'Edit Profil'. Action TextButton 'Simpan'.
- Data Dasar: [Nama | Usia | Gender toggle]
- Data Fisik: [Tinggi | Berat Terkini | Lingkar Pinggang]. Update berat = catat ke weight log.
- BMI Real-time Card: 'BMI: X.X — [Kategori]'
- Tujuan: edit goal. Warning Card 'Mengubah tujuan akan membuat AI merancang ulang rencana.'
- `PrimaryButton 'Simpan Perubahan'`. Konfirmasi AlertDialog untuk perubahan signifikan (target/goal).

**API:** `PUT /v1/profile`. Jika goal berubah, trigger `POST /v1/plan/replan`.

---

### S-32 — Notification Settings

**Layout:**
- Master Switch besar 'Aktifkan Semua Notifikasi'
- Notif Latihan: SwitchListTile + TimePicker. Sub-toggle 'Peringatan Pemanasan 15 Mnt'.
- Notif Makan: SwitchListTile per waktu + TimePicker. Sub-toggle '10 Mnt Sebelum'.
- Notif Hidrasi: SwitchListTile. Dropdown frekuensi [1 Jam | 2 Jam | 3 Jam].
- Notif Laporan: SwitchListTile + TimePicker.
- `PrimaryButton 'Simpan Pengaturan'`

**API:** `PUT /v1/profile/notification-prefs`

**Logic:** Update `flutter_local_notifications` schedule local sesuai pengaturan.

---

### S-33 — App Settings (P2 — opsional)

**Layout:**
- Dark Mode SwitchListTile
- Satuan DropdownListTile [Metrik | Imperial]
- Bahasa DropdownListTile [Indonesia | English]
- Reset Data ListTile merah → AlertDialog ketik 'RESET'
- Ekspor Data ListTile 'Ekspor CSV' → Share sheet
- Tentang: versi, credits, attributions dataset

**API:** `DELETE /v1/auth/me/data` untuk reset (jika sempat).

---

## BAGIAN H — Replanning (2 layar)

### S-34 — Weekly Review Modal

**Trigger:** auto Sunday 20:00 via local notification ATAU manual dari S-29.

**Layout:**
- Mode full-screen modal
- Header gradient primary: 'Evaluasi Mingguan 📊'. 'Minggu ke-X selesai!'
- Skor: Lingkaran progress 120dp count-up. Hijau >80%, orange 50-80%, merah <50%.
- Breakdown 3 baris: [Latihan X/X ✅ | Makan X/X hari ✅ | Berat +/-X kg]
- AI Analisis Card amber: 'AI menganalisis...' → 'Latihan paling sering diskip: [nama]. Akan diganti otomatis.'
- Processing: 'AI membuat rencana minggu depan...' loading bar singkat
- `PrimaryButton 'Lihat Rencana Minggu Depan →'`
- Dismiss 'Lihat Nanti' kanan atas → notif reminder besok pagi

**API:** `POST /v1/plan/replan` (jika belum ditrigger oleh cron)

---

### S-35 — New Plan Ready

**Layout:**
- Header animasi konfeti bg putih: '🎯 Rencana Minggu Depan Siap!'
- Perubahan AI Card hijau muda: list bullet [latihan diganti, intensitas berubah, budget makan disesuaikan]
- Preview 7 Hari Row horizontal 7 chip
- Target Update: 'Progres: X kg dari X kg. Estimasi baru: X minggu lagi.'
- Motivasi AI dinamis: skor >80% → 'Performamu luar biasa!', skor <50% → 'Tidak apa-apa! Mulai dari yang lebih ringan.'
- `PrimaryButton 'Mulai Minggu Baru!'` → `/home` + reset cache plan

**API:** Sudah punya plan baru dari S-34.

---

## Tabel Ringkasan Prioritas

| Kode | Layar | Tab | Prioritas | Demo wajib? |
|---|---|---|---|---|
| S-01..S-05 | Onboarding + Welcome | — | P0 | ✅ |
| S-06..S-14 | Setup Profile | — | P0 | ✅ |
| S-15 | Home Dashboard | 1 | P0 | ✅ |
| S-16, S-17 | Workout Home + Day | 2 | P0 | ✅ |
| S-18 | Exercise Detail | 2 | P1 | — |
| S-19, S-20, S-21 | Pre-checkin + Active + Complete | 2 | P0 | ✅ |
| S-22, S-23 | Nutrition Home + Meal Detail | 3 | P0 | ✅ |
| S-24 | Food Item Detail | 3 | P1 | — |
| S-25 | Budget Settings | 3 | P1 | — |
| S-26, S-27 | Progress Dashboard + Add Weight | 4 | P0 | ✅ |
| S-28 | Badges | 4 | P1 | — |
| S-29 | Weekly Report | 4 | P1 | ✅ (jika sempat) |
| S-30..S-32 | Profile + Edit + Notif Settings | — | P1 | — |
| S-33 | App Settings | — | P2 | — |
| S-34, S-35 | Replanning Modal + New Plan | — | P0 | ✅ |
