# Bugfix Requirements Document

## Introduction

Aplikasi Flutter Heltigo memiliki beberapa bug UI/UX yang mempengaruhi pengalaman pengguna dan responsiveness aplikasi. Bug-bug ini mencakup:
1. Timeline target input yang tidak seharusnya ada (ML yang menentukan timeline)
2. Overflow error pada card statistik di beberapa screen
3. Spacing tidak merata pada bottom navigation bar
4. Text onboarding yang terpotong/tidak responsive
5. Layout yang tidak responsive untuk berbagai ukuran layar

Bug-bug ini menyebabkan tampilan aplikasi tidak profesional, error visual yang mengganggu, dan pengalaman pengguna yang buruk pada berbagai ukuran perangkat.

## Bug Analysis

### Current Behavior (Defect)

#### 1. Timeline Target Input

1.1 WHEN user mengakses setup wizard THEN sistem menampilkan slider "Timeline Target" dengan nilai default "16 Minggu"

1.2 WHEN user mengisi setup wizard THEN sistem meminta user untuk menentukan timeline target secara manual

#### 2. Bottom Overflow Errors

1.3 WHEN user membuka screen "Detail Sesi" (workout_session_detail_screen.dart) THEN sistem menampilkan error "BOTTOM OVERFLOWED BY 0.882 PIXELS" pada card statistik

1.4 WHEN user membuka screen dengan card statistik (28 mnt, 16 set, 156 reps, 245 kkal) THEN sistem menampilkan error "BOTTOM OVERFLOWED BY 5.1 PIXELS"

1.5 WHEN card statistik di-render pada layar kecil THEN overflow error muncul karena konten tidak muat dalam container

#### 3. Bottom Navigation Spacing

1.6 WHEN user melihat bottom navigation bar THEN icon "Latihan" memiliki jarak yang tidak proporsional dibanding icon lainnya (Home, Makan, Progress)

1.7 WHEN bottom navigation bar di-render THEN spacing antar icon tidak merata dan tidak konsisten

#### 4. Onboarding Text Tertutup

1.8 WHEN user membuka halaman onboarding dengan background gym THEN text "Latihan Terbaik Untuk Kamu" dan deskripsi di bawahnya tertutup/terpotong

1.9 WHEN onboarding screen di-render pada layar kecil (small phones) THEN text overlay tidak terlihat penuh

1.10 WHEN onboarding screen di-render pada berbagai ukuran layar THEN text tidak responsive dan posisinya tidak konsisten

#### 5. Responsiveness Issues

1.11 WHEN aplikasi dibuka pada small screens (iPhone SE, small Android) THEN layout tidak menyesuaikan dan terjadi overflow

1.12 WHEN aplikasi dibuka pada medium screens (iPhone 12, Pixel 5) THEN beberapa komponen tidak proporsional

1.13 WHEN aplikasi dibuka pada large screens (iPhone Pro Max, tablet) THEN spacing dan sizing tidak optimal

1.14 WHEN flutter analyze dijalankan THEN muncul warning atau error terkait overflow dan layout issues

### Expected Behavior (Correct)

#### 1. Timeline Target Input - Removal

2.1 WHEN user mengakses setup wizard THEN sistem TIDAK BOLEH menampilkan slider "Timeline Target"

2.2 WHEN user mengisi setup wizard THEN sistem HARUS menghitung timeline secara otomatis berdasarkan target weight dan deficit kalori menggunakan ML

2.3 WHEN setup wizard selesai THEN timeline ditentukan oleh backend/ML tanpa input manual dari user

#### 2. Bottom Overflow Errors - Fixed

2.4 WHEN user membuka screen "Detail Sesi" THEN sistem HARUS menampilkan card statistik tanpa overflow error

2.5 WHEN card statistik di-render THEN sistem HARUS menggunakan layout yang flexible (Flexible, Expanded, atau FittedBox) untuk mencegah overflow

2.6 WHEN konten card terlalu besar untuk container THEN sistem HARUS menyesuaikan ukuran font atau layout secara otomatis

2.7 WHEN screen dengan card statistik dibuka pada layar kecil THEN sistem HARUS menampilkan konten dengan proper wrapping atau scrolling

#### 3. Bottom Navigation Spacing - Fixed

2.8 WHEN user melihat bottom navigation bar THEN semua icon (Home, Latihan, Makan, Progress) HARUS memiliki spacing yang merata dan proporsional

2.9 WHEN bottom navigation bar di-render THEN sistem HARUS menggunakan MainAxisAlignment.spaceEvenly atau spaceAround untuk distribusi merata

2.10 WHEN bottom navigation bar di-render pada berbagai ukuran layar THEN spacing HARUS tetap konsisten dan proporsional

#### 4. Onboarding Text - Responsive

2.11 WHEN user membuka halaman onboarding dengan background gym THEN text "Latihan Terbaik Untuk Kamu" dan deskripsi HARUS terlihat penuh tanpa terpotong

2.12 WHEN onboarding screen di-render pada layar kecil THEN sistem HARUS menyesuaikan ukuran font dan padding agar text terlihat penuh

2.13 WHEN onboarding screen di-render pada berbagai ukuran layar THEN text overlay HARUS responsive menggunakan MediaQuery atau LayoutBuilder

2.14 WHEN text terlalu panjang untuk layar THEN sistem HARUS menggunakan auto-scaling text atau proper line breaks

#### 5. Responsiveness - All Screens

2.15 WHEN aplikasi dibuka pada small screens THEN semua layout HARUS menyesuaikan dengan proper scaling dan tidak ada overflow

2.16 WHEN aplikasi dibuka pada medium screens THEN semua komponen HARUS proporsional dan menggunakan responsive sizing

2.17 WHEN aplikasi dibuka pada large screens THEN spacing dan sizing HARUS optimal dengan max-width constraints jika diperlukan

2.18 WHEN flutter analyze dijalankan THEN TIDAK BOLEH ada warning atau error terkait overflow dan layout issues

2.19 WHEN responsive utilities digunakan THEN sistem HARUS menggunakan MediaQuery.of(context).size atau LayoutBuilder untuk adaptive layouts

### Unchanged Behavior (Regression Prevention)

#### Setup Wizard Flow

3.1 WHEN user mengakses setup wizard steps lainnya (basic info, physical, goal, fitness level, conditions, preferences) THEN sistem HARUS TETAP menampilkan dan memproses input tersebut dengan benar

3.2 WHEN user menyelesaikan setup wizard THEN sistem HARUS TETAP membuat plan dan mengirim data ke backend dengan benar

#### Card Statistik Content

3.3 WHEN card statistik ditampilkan THEN sistem HARUS TETAP menampilkan data yang benar (durasi, set, reps, kalori)

3.4 WHEN user berinteraksi dengan card statistik THEN sistem HARUS TETAP merespons dengan benar (tap, navigation, dll)

#### Bottom Navigation Functionality

3.5 WHEN user tap icon pada bottom navigation THEN sistem HARUS TETAP navigasi ke screen yang benar

3.6 WHEN user berada di screen tertentu THEN icon bottom navigation yang aktif HARUS TETAP ter-highlight dengan benar

3.7 WHEN bottom navigation di-render THEN icon dan label HARUS TETAP sesuai dengan design system yang ada

#### Onboarding Flow

3.8 WHEN user melalui onboarding screens THEN sistem HARUS TETAP menampilkan semua halaman onboarding dengan urutan yang benar

3.9 WHEN user tap tombol "Next" atau "Skip" pada onboarding THEN sistem HARUS TETAP navigasi dengan benar

3.10 WHEN onboarding selesai THEN sistem HARUS TETAP mengarahkan user ke login/register atau main app dengan benar

#### Other Screens

3.11 WHEN user mengakses screens lain yang tidak disebutkan dalam bug (home, meal, progress, profile, dll) THEN sistem HARUS TETAP berfungsi normal tanpa perubahan behavior

3.12 WHEN aplikasi di-build untuk production THEN sistem HARUS TETAP build tanpa error dan warning yang tidak terkait dengan bugfix ini

3.13 WHEN user menggunakan fitur-fitur lain (workout tracking, meal logging, progress tracking) THEN sistem HARUS TETAP berfungsi dengan benar tanpa regresi
