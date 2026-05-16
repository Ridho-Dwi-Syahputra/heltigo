# Frontend — Offline-First Strategy

## 1. Filosofi: Hybrid Offline-First

Heltigo bukan 100% offline (karena ML inference di backend), tapi **fitur kritis tetap berfungsi tanpa internet**. Filosofi:

1. **Read kritis dari cache dulu**, fetch di background untuk update.
2. **Write dulu ke local** (Hive), lalu **enqueue** untuk sync ke server saat online.
3. **Optimistic UI** — user selalu lihat hasil aksi mereka langsung, sync di belakang.
4. **Konflik resolution**: server-side last-write-wins kecuali ada kasus khusus.

## 2. Cakupan Offline (Tabel Lengkap)

| Aksi User | Online? | Offline behavior |
|---|---|---|
| Splash + cek auth | ✅ wajib | Boot ke welcome jika belum signup (tidak bisa demo) |
| Signup / Login | ✅ wajib | Tampilkan pesan "Butuh internet untuk login" |
| Setup profile (input data) | Tidak butuh | Simpan ke `setup_draft` Hive box |
| Kalkulasi BMI/BMR/TDEE | Tidak butuh | `health_calculator.dart` pure Dart, instan |
| Submit profile + Plan Generate | ✅ wajib | Block, butuh ML — tampilkan "Butuh internet untuk generate plan" |
| Lihat plan minggu ini (S-14, S-15, S-16, S-17, S-22, S-23) | ❌ tidak butuh | Baca dari `plans` box (cached saat online) |
| Centang exercise/meal selesai | ❌ tidak butuh | Update Hive lokal + enqueue |
| Pre-workout check-in (S-19) | Idealnya ✅, fallback ❌ | Jika offline: skip ML adjust, pakai original workout, toast "Tanpa adaptasi AI" |
| Active workout (S-20) | ❌ tidak butuh | Full offline. Sync log saat selesai. |
| Workout complete log | ❌ tidak butuh | Enqueue |
| Add weight (S-27) | ❌ tidak butuh | Simpan lokal + enqueue |
| Notifikasi pengingat | ❌ tidak butuh | `flutter_local_notifications` |
| Lihat progress dashboard (S-26) | Idealnya ✅ | Tampilkan cached data, label "Data terakhir disinkronkan: X menit lalu" |
| Weekly Report (S-29) | ✅ wajib (agregasi server) | Block jika offline, suggest open online |
| Pengaturan notifikasi (S-32) | ❌ untuk schedule lokal, ✅ untuk sync prefs | Update lokal + enqueue |

## 3. Hive Schema (Boxes)

File: `lib/core/storage/hive_setup.dart`

```dart
abstract class HiveBoxes {
  static const appState = 'app_state';        // hasProfile, lastSyncedAt
  static const setupDraft = 'setup_draft';     // draft setup profile (TypedBox<SetupDraft>)
  static const plans = 'plans';                // current plan + previous plans (TypedBox<Plan>)
  static const dailyChecklists = 'checklists'; // per-hari checklist exercise + meal (TypedBox<DailyChecklist>)
  static const weightLogs = 'weight_logs';     // log timbangan lokal (TypedBox<WeightLog>)
  static const syncQueue = 'sync_queue';       // pending sync items (TypedBox<SyncItem>)
  static const notifPrefs = 'notif_prefs';     // pengaturan notifikasi (TypedBox<NotifPrefs>)
  static const cache = 'cache';                // misc cached responses (key-value)
}

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(SetupDraftAdapter());
  Hive.registerAdapter(PlanAdapter());
  Hive.registerAdapter(WorkoutDayAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(MealAdapter());
  Hive.registerAdapter(FoodItemAdapter());
  Hive.registerAdapter(DailyChecklistAdapter());
  Hive.registerAdapter(WeightLogAdapter());
  Hive.registerAdapter(SyncItemAdapter());
  Hive.registerAdapter(NotifPrefsAdapter());

  await Future.wait([
    Hive.openBox(HiveBoxes.appState),
    Hive.openBox<SetupDraft>(HiveBoxes.setupDraft),
    Hive.openBox<Plan>(HiveBoxes.plans),
    Hive.openBox<DailyChecklist>(HiveBoxes.dailyChecklists),
    Hive.openBox<WeightLog>(HiveBoxes.weightLogs),
    Hive.openBox<SyncItem>(HiveBoxes.syncQueue),
    Hive.openBox<NotifPrefs>(HiveBoxes.notifPrefs),
    Hive.openBox(HiveBoxes.cache),
  ]);
}
```

**Generate Hive adapters:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 4. SyncItem Model

```dart
@HiveType(typeId: 100)
class SyncItem extends HiveObject {
  @HiveField(0) final String id;          // UUID v4 client-generated
  @HiveField(1) final String type;        // 'workout_checklist', 'meal_checklist', 'weight_log', 'workout_log', 'mood_after'
  @HiveField(2) final Map<String, dynamic> payload;
  @HiveField(3) final DateTime createdAt;
  @HiveField(4) int retryCount;

  SyncItem({required this.id, required this.type, required this.payload, required this.createdAt, this.retryCount = 0});
}
```

`id` = UUID v4 (paket `uuid`). Server pakai `id` untuk deduplikasi (idempotent upsert).

## 5. Sync Drainer Logic

File: `lib/core/storage/sync_drainer.dart`

```dart
class SyncDrainer {
  SyncDrainer(this._dio, this._box);
  final Dio _dio;
  final Box<SyncItem> _box;
  bool _draining = false;

  Future<void> drainNow() async {
    if (_draining) return;
    _draining = true;
    try {
      final items = _box.values.toList();
      if (items.isEmpty) return;

      final res = await _dio.post('/sync/batch', data: {
        'items': items.map((i) => {
          'id': i.id,
          'type': i.type,
          'payload': i.payload,
          'created_at': i.createdAt.toIso8601String(),
        }).toList(),
      });

      // Server returns per-item status
      final results = (res.data['results'] as List).cast<Map<String, dynamic>>();
      for (final result in results) {
        final id = result['id'] as String;
        final status = result['status'] as String;
        if (status == 'ok' || status == 'duplicate') {
          await _box.values.firstWhere((s) => s.id == id).delete();
        } else if (status == 'invalid') {
          // payload bermasalah, hapus daripada loop
          await _box.values.firstWhere((s) => s.id == id).delete();
        }
        // status 'retry' → biarkan di queue
      }
    } catch (e) {
      // network error → keep all items in queue, akan retry saat online lagi
    } finally {
      _draining = false;
    }
  }
}
```

**Trigger drain:**
1. Saat connectivity berubah dari offline → online (listen `connectivity_plus`).
2. Saat app kembali ke foreground (`AppLifecycleState.resumed`).
3. Setelah enqueue baru jika online (try opportunistic).

## 6. Optimistic UI Pattern (Contoh: Centang Exercise)

```dart
class WorkoutDayNotifier extends Notifier<DailyChecklist> {
  @override
  DailyChecklist build() {
    final box = ref.read(hiveProvider).box<DailyChecklist>(HiveBoxes.dailyChecklists);
    return box.get(_todayKey()) ?? DailyChecklist.empty(date: DateTime.now());
  }

  Future<void> toggleExercise(String exerciseId) async {
    // 1. Update lokal langsung (optimistic)
    final updated = state.toggleExercise(exerciseId);
    state = updated;
    await ref.read(hiveProvider).box<DailyChecklist>(HiveBoxes.dailyChecklists).put(_todayKey(), updated);

    // 2. Enqueue untuk sync
    final syncBox = ref.read(hiveProvider).box<SyncItem>(HiveBoxes.syncQueue);
    await syncBox.add(SyncItem(
      id: const Uuid().v4(),
      type: 'workout_checklist',
      payload: {
        'exercise_id': exerciseId,
        'date': _todayKey(),
        'completed': updated.completedExercises.contains(exerciseId),
      },
      createdAt: DateTime.now(),
    ));

    // 3. Try drain langsung jika online
    final online = ref.read(connectivityProvider).valueOrNull ?? false;
    if (online) ref.read(syncDrainerProvider.notifier).drainNow();
  }
}
```

## 7. Cache TTL & Refresh Strategy

| Data | TTL | Strategi |
|---|---|---|
| Current plan | 30 menit | Stale-while-revalidate: tampilkan cache, fetch di background, update jika beda |
| Daily summary (S-15) | 5 menit | Stale-while-revalidate |
| Food items master | 24 jam | Refresh on demand atau saat sync |
| Exercise items master | 24 jam | Sama |
| User profile | 1 jam | Refresh saat buka Edit Profile |
| Weight history | 10 menit | Refresh saat buka Progress Dashboard |
| Weekly report | 1 hari (immutable saat sudah final) | Cache permanen per minggu |

Implementasi via `cachedAt` field di setiap box record + helper `_isStale(cachedAt, ttl)`.

## 8. Konflik Resolution

Karena single user single device (untuk hackathon), konflik minim. Strategi sederhana:

- **Last-write-wins di server** untuk semua field profile dan checklist.
- **Idempotent sync** via UUID — duplikasi tidak terjadi.
- **Plan generation**: hanya server yang bisa create plan baru, mobile tidak pernah konflik.

Nanti saat scale ke multi-device, akan dipikirkan vector clock atau CRDT — di luar scope hackathon.

## 9. Offline UX Patterns

### 9.1 Banner Offline

Saat offline, tampilkan banner persistent di atas Scaffold:
```
"📡 Mode Offline — Aksi disinkronkan saat koneksi kembali"
```

`shared/widgets/offline_banner.dart`:
```dart
class OfflineBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(connectivityProvider).valueOrNull ?? true;
    if (online) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: AppColors.amberLight,
      child: Text(
        '📡 Mode Offline — Aksi disinkronkan saat koneksi kembali',
        style: AppTextStyles.caption.copyWith(color: AppColors.amber),
        textAlign: TextAlign.center,
      ),
    );
  }
}
```

### 9.2 Pending Sync Counter

Di `ProfileScreen` (S-30), tampilkan badge kecil jika ada pending sync:
```
"X aksi belum disinkronkan"
```

### 9.3 Last Synced Indicator

Di `Progress Dashboard` (S-26) tampilkan teks kecil:
```
"Terakhir disinkronkan: 12 menit lalu"
```

Atau saat data sangat stale (>1 jam): "Data mungkin tidak terbaru".

## 10. Testing Offline

Untuk QA:
1. Buka app saat online → setup profile lengkap → plan ter-generate.
2. Aktifkan airplane mode.
3. Buka home screen → harus tampilkan plan dari cache + banner offline.
4. Centang beberapa exercise → harus update UI langsung.
5. Add weight → harus simpan lokal.
6. Check Hive box `sync_queue` (via debug tool) → harus berisi 3+ item.
7. Matikan airplane mode.
8. Banner hilang. Sync queue ter-drain dalam beberapa detik.
9. Verify di backend MySQL: data tersinkron.
