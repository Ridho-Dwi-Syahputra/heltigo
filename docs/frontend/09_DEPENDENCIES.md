# Frontend — Dependencies (pubspec.yaml)

> ⚠️ **Update 2026-05-16:** Dependency baru ditambahkan untuk fitur Food Scan:
> - `image_picker: ^1.1.2` — kamera + galeri untuk scan makanan
> - `permission_handler: ^11.3.1` — request camera/storage permissions
>
> Stack aktual berbeda dari draft di bawah (pakai `provider` + `get_it`, bukan Riverpod; pakai `shared_preferences`, bukan Hive). Lihat `pubspec.yaml` untuk versi aktual.

Versi yang dianjurkan per 2026-05-07. Boleh upgrade jika ada release stabil terbaru selama tidak breaking.

## 1. Full pubspec.yaml

```yaml
name: heltigo
description: Heltigo — AI-Powered Personal Health & Fitness App.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ">=3.4.0 <4.0.0"
  flutter: ">=3.22.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.1

  # Routing
  go_router: ^14.2.0

  # Networking
  dio: ^5.5.0

  # Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.2.2

  # UI
  google_fonts: ^6.2.1
  fl_chart: ^0.68.0
  lottie: ^3.1.2
  cupertino_icons: ^1.0.8

  # Notifications
  flutter_local_notifications: ^17.2.1
  timezone: ^0.9.4

  # Connectivity
  connectivity_plus: ^6.0.3

  # Utilities
  intl: ^0.19.0
  uuid: ^4.4.0
  collection: ^1.18.0
  wakelock_plus: ^1.2.5  # Untuk Active Workout Screen (S-20)
  share_plus: ^9.0.0     # Share weekly report

  # Optional, opsional jika sempat
  shimmer: ^3.0.0        # Loading skeleton
  flutter_svg: ^2.0.10   # Logo SVG

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.11
  mocktail: ^1.0.4       # Untuk unit test repository

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/lottie/
  # Tidak perlu assets/fonts/ karena pakai google_fonts (download dari internet pertama kali)

# Flutter generator untuk Hive adapters:
# flutter pub run build_runner build --delete-conflicting-outputs
```

## 2. Penjelasan Tiap Dependency

### State & Routing
- **flutter_riverpod 2.5+** — modern Riverpod, support Notifier API yang lebih bersih dari StateNotifier lama. Lihat `06_STATE_MANAGEMENT.md`.
- **go_router 14+** — declarative routing dengan `StatefulShellRoute` untuk bottom nav. Lihat `04_NAVIGATION.md`.

### Networking
- **dio 5+** — HTTP client mature dengan interceptor. Lihat `08_API_INTEGRATION.md`.

### Storage
- **hive + hive_flutter** — TypedBox local storage. Cepat, tanpa SQL. Generate adapters dengan `build_runner`.
- **flutter_secure_storage** — Untuk simpan JWT token aman (Keychain di iOS, EncryptedSharedPreferences di Android).

### UI
- **google_fonts** — Inter font sesuai spec. Download otomatis pertama kali, cache lokal.
- **fl_chart** — LineChart, BarChart untuk weight chart, makro, weekly report.
- **lottie** — Animasi splash, AI processing, celebration.
- **cupertino_icons** — Default Flutter, iOS-style icons jika perlu.

### Notifications
- **flutter_local_notifications 17+** — Pengingat makan, latihan, hidrasi offline.
- **timezone** — Mandatory untuk schedule notifikasi yang tepat di zona waktu user.

### Connectivity
- **connectivity_plus 6+** — Detect online/offline untuk trigger sync drain.

### Utilities
- **intl** — Format tanggal `DateFormat('EEEE, dd MMM yyyy', 'id_ID')`.
- **uuid** — Generate UUID v4 untuk SyncItem id (idempotent).
- **collection** — Helper `groupBy`, `firstWhereOrNull`, dll.
- **wakelock_plus** — Cegah layar mati saat Active Workout (S-20).
- **share_plus** — Share weekly report sebagai image/text.

### Optional (P1 / P2)
- **shimmer** — Skeleton loading animasi shimmering.
- **flutter_svg** — Render SVG logo.

### Dev
- **flutter_lints 4** — Linter rules default (recommended).
- **hive_generator** + **build_runner** — Generate Hive adapters.
- **mocktail** — Mock untuk unit test repository (opsional, manual mock juga ok).

## 3. analysis_options.yaml

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  errors:
    invalid_annotation_target: ignore
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    prefer_const_constructors_in_immutables: true
    avoid_print: true
    require_trailing_commas: true
    prefer_single_quotes: true
    sort_pub_dependencies: true
```

## 4. Setup Awal

```bash
cd frontend/heltigo
flutter pub get

# Setup timezone database (sekali saja)
# Sudah otomatis terinit di main.dart

# Generate Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs

# Run di emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/v1
```

## 5. Konfigurasi Platform-Specific

### Android (`android/app/build.gradle`)

- `minSdkVersion 21` (Android 5.0)
- `compileSdkVersion` dan `targetSdkVersion` sesuai Flutter latest (33+)

### Android Permission (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
```

### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoadsForMedia</key>
  <true/>
  <!-- Untuk dev http://localhost — production wajib HTTPS -->
  <key>NSAllowsLocalNetworking</key>
  <true/>
</dict>
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

## 6. Versi Locking

Setelah hackathon mulai, **lock semua versi dengan `flutter pub get` dan commit `pubspec.lock`**. Jangan upgrade kecuali ada bug fix kritis. Stabilitas > fitur baru di sprint 2 minggu.

## 7. Catatan Performa

- **fl_chart** bisa lambat jika banyak data point. Untuk weight chart batasi ke 30 hari atau aggregasi mingguan.
- **lottie** file harus dikompresi (gunakan LottieFiles optimizer atau manual prune di After Effects).
- **google_fonts** download saat runtime — cache di local storage, jadi hanya satu kali per font.

## 8. Reference Setup main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/storage/hive_setup.dart';
import 'core/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Locale ID untuk DateFormat
  await initializeDateFormatting('id_ID');

  // Hive
  await initHive();

  // Timezone untuk scheduled notifications
  tz.initializeTimeZones();

  // Notification service
  await NotificationService.instance.init();

  runApp(const ProviderScope(child: HeltigoApp()));
}
```

## 9. Versi Tools yang Direkomendasikan

- Flutter SDK: **3.22.x** (stable channel)
- Dart: **3.4.x** (bundled dengan Flutter)
- Android Studio: **Hedgehog 2023.1+** atau VS Code dengan Flutter extension
- Xcode (untuk iOS build): **15.x+**

Semua tim FE WAJIB pakai versi yang sama. Lock di README atau `.tool-versions` (asdf).
