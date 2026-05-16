# Frontend — State Management (Riverpod 2.x)

## 1. Filosofi

- **Provider** untuk dependency injection (Dio, Hive boxes, repositories)
- **FutureProvider / StreamProvider** untuk read-only async data dari API
- **StateNotifierProvider / NotifierProvider** untuk state mutable (form, draft setup, active workout)
- **AsyncValue** untuk loading/error/data triple di UI
- **`ref.invalidate()`** untuk refresh, **`ref.refresh()`** untuk refresh + return value baru

Aturan ketat: **Tidak ada `setState` di StatefulWidget untuk data app-level**. State app harus di Riverpod. `setState` boleh untuk UI internal seperti animasi controller, tab controller, scroll position.

## 2. Struktur File Provider

Per-fitur, satu file `providers/<feature>_providers.dart`:

```
features/
  workout/
    providers/
      workout_repository_provider.dart   # Provider DI
      current_plan_provider.dart         # FutureProvider
      pre_workout_checkin_notifier.dart  # StateNotifier
      active_workout_notifier.dart       # StateNotifier
```

## 3. Provider Kunci per Fitur

### 3.1 Core (lintas fitur)

```dart
// lib/core/http/dio_provider.dart
final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ref.watch(envProvider).apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));
  dio.interceptors.add(AuthInterceptor(ref));
  dio.interceptors.add(ErrorInterceptor());
  return dio;
});

// lib/core/storage/hive_provider.dart
final hiveProvider = Provider<HiveInterface>((_) => Hive);

// lib/core/connectivity/connectivity_provider.dart
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (e) => e != ConnectivityResult.none,
  );
});
```

### 3.2 Auth

```dart
// AuthState: idle / authenticated(token, userId) / unauthenticated
class AuthState {
  AuthState({this.token, this.userId, this.hasProfile = false});
  final String? token;
  final String? userId;
  final bool hasProfile;
  bool get isAuthenticated => token != null;
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // restore from secure storage on init
    _restore();
    return AuthState();
  }

  Future<void> signup(String email, String password) async {
    final res = await ref.read(authRepoProvider).signup(email, password);
    await ref.read(secureStorageProvider).save('token', res.token);
    state = AuthState(token: res.token, userId: res.userId, hasProfile: false);
  }

  Future<void> login(String email, String password) async {/* similar */}
  Future<void> logout() async {/* clear */}
  Future<void> _restore() async {/* read secureStorage, validate token */}
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
```

### 3.3 Setup Profile (Draft)

```dart
class SetupDraft {
  SetupDraft({
    this.name, this.age, this.gender,
    this.heightCm, this.weightKg, this.waistCm,
    this.bmiResult,
    this.goal, this.targetWeightKg, this.timelineWeeks,
    this.conditions = const [],
    this.workoutMode, this.daysPerWeek, this.sessionMinutes, this.preferredTimes = const [], this.fitnessLevel,
    this.budgetPerDay, this.currency, this.mealFrequency, this.dietRestrictions = const [],
  });
  // ... fields ...
  SetupDraft copyWith({...}) => SetupDraft(...);
}

class SetupDraftNotifier extends Notifier<SetupDraft> {
  @override
  SetupDraft build() {
    // restore from Hive box 'setup_draft' if exists
    final box = ref.read(hiveProvider).box('setup_draft');
    if (box.isNotEmpty) return SetupDraftDeserializer.fromMap(box.toMap());
    return SetupDraft();
  }

  void updateBasic({String? name, int? age, Gender? gender}) {
    state = state.copyWith(name: name, age: age, gender: gender);
    _persist();
  }

  void updatePhysical({double? heightCm, double? weightKg, double? waistCm}) {/* ... */}

  void calculateBmi() {
    final result = HealthCalculator.compute(state);
    state = state.copyWith(bmiResult: result);
    _persist();
  }

  // ... per-step setters
  Future<void> _persist() async {
    final box = ref.read(hiveProvider).box('setup_draft');
    await box.putAll(SetupDraftDeserializer.toMap(state));
  }

  Future<void> clearDraft() async {
    await ref.read(hiveProvider).box('setup_draft').clear();
  }
}

final setupDraftProvider = NotifierProvider<SetupDraftNotifier, SetupDraft>(
  SetupDraftNotifier.new,
);
```

### 3.4 Plan Generation (S-13)

```dart
final planGenerationProvider = FutureProvider.autoDispose<Plan>((ref) async {
  final draft = ref.read(setupDraftProvider);
  final repo = ref.read(profileRepositoryProvider);

  // 1. Submit profile lengkap
  await repo.upsertProfile(draft);
  // 2. Trigger plan generation (Express → FastAPI → MySQL)
  final plan = await ref.read(planRepositoryProvider).generate();
  // 3. Cache ke Hive
  await ref.read(hiveProvider).box<Plan>('plans').put('current', plan);
  // 4. Clear setup draft
  await ref.read(setupDraftProvider.notifier).clearDraft();
  return plan;
});
```

UI di S-13 consume dengan `ref.watch(planGenerationProvider).when(loading: ..., error: ..., data: (plan) => navigateToPlanReady(plan))`.

### 3.5 Current Plan (S-14, S-15, tab Latihan/Nutrisi)

```dart
final currentPlanProvider = FutureProvider<Plan>((ref) async {
  final repo = ref.read(planRepositoryProvider);
  return repo.getCurrentPlan();   // cek Hive cache dulu, fetch jika stale
});
```

Repository pattern dengan TTL:
```dart
class PlanRepository {
  static const _staleness = Duration(minutes: 30);

  Future<Plan> getCurrentPlan() async {
    final box = _hive.box<Plan>('plans');
    final cached = box.get('current');
    final cachedAt = box.get('current_cached_at') as DateTime?;
    final isStale = cachedAt == null || DateTime.now().difference(cachedAt) > _staleness;

    if (cached != null && !isStale) return cached;

    try {
      final res = await _dio.get('/plan/current');
      final plan = Plan.fromJson(res.data);
      await box.put('current', plan);
      await box.put('current_cached_at', DateTime.now());
      return plan;
    } on DioException {
      // fallback ke cache jika offline
      if (cached != null) return cached;
      rethrow;
    }
  }
}
```

### 3.6 Pre-Workout Check-in (S-19)

```dart
class PreWorkoutCheckinState {
  PreWorkoutCheckinState({this.mood, this.energy, this.sleepBand, this.adjustedWorkout, this.isSubmitting = false});
  final int? mood;       // 1-5
  final int? energy;     // 1-5
  final SleepBand? sleepBand;  // <5, 5-6, 6-7, 7-8, >8
  final AdjustedWorkout? adjustedWorkout;
  final bool isSubmitting;
}

class PreWorkoutCheckinNotifier extends AutoDisposeFamilyNotifier<PreWorkoutCheckinState, int /* dayIndex */> {
  @override
  PreWorkoutCheckinState build(int dayIndex) => PreWorkoutCheckinState();

  void setMood(int v) => state = state.copyWith(mood: v);
  void setEnergy(int v) => state = state.copyWith(energy: v);
  void setSleep(SleepBand b) => state = state.copyWith(sleepBand: b);

  Future<void> submit() async {
    state = state.copyWith(isSubmitting: true);
    try {
      final adjusted = await ref.read(workoutRepoProvider).checkin(
        dayIndex: arg,
        mood: state.mood!,
        energy: state.energy!,
        sleepBand: state.sleepBand!,
      );
      state = state.copyWith(adjustedWorkout: adjusted, isSubmitting: false);
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }
}

final preWorkoutCheckinProvider = NotifierProvider.autoDispose
    .family<PreWorkoutCheckinNotifier, PreWorkoutCheckinState, int>(
  PreWorkoutCheckinNotifier.new,
);
```

### 3.7 Active Workout (S-20)

```dart
class ActiveWorkoutState {
  final List<ExerciseProgress> exercises;
  final int currentIndex;
  final int currentSet;
  final Duration totalElapsed;
  final bool isResting;
  final Duration? restRemaining;
  final bool isPaused;
}

class ActiveWorkoutNotifier extends AutoDisposeNotifier<ActiveWorkoutState> {
  Timer? _ticker;

  @override
  ActiveWorkoutState build() {
    ref.onDispose(() => _ticker?.cancel());
    final adjusted = /* injected via initial param */;
    return /* initial */;
  }

  void start() { _ticker = Timer.periodic(const Duration(seconds: 1), _tick); }
  void pause() { _ticker?.cancel(); state = state.copyWith(isPaused: true); }
  void resume() { /* restart ticker */ }
  void completeSet() { /* increment set, start rest if needed, haptic */ }
  void nextExercise() { /* ... */ }
  void prevExercise() { /* ... */ }
  void finish() { /* compute summary, send POST /workout/log */ }
}

final activeWorkoutProvider = NotifierProvider.autoDispose<ActiveWorkoutNotifier, ActiveWorkoutState>(
  ActiveWorkoutNotifier.new,
);
```

### 3.8 Daily Summary (S-15)

```dart
final dailySummaryProvider = FutureProvider.autoDispose<DailySummary>((ref) async {
  final repo = ref.read(progressRepoProvider);
  return repo.getDailySummary(DateTime.now());
});
```

### 3.9 Sync Queue (Offline)

```dart
// Stream yang emit jumlah pending sync
final syncQueueCountProvider = StreamProvider<int>((ref) async* {
  final box = ref.read(hiveProvider).box('sync_queue');
  yield box.length;
  await for (final _ in box.watch()) yield box.length;
});

// Background drain ketika online
class SyncDrainer extends Notifier<void> {
  @override
  void build() {
    ref.listen(connectivityProvider, (prev, next) {
      next.whenData((online) {
        if (online) _drain();
      });
    });
  }

  Future<void> _drain() async {
    final box = ref.read(hiveProvider).box('sync_queue');
    if (box.isEmpty) return;
    final items = box.values.toList();
    try {
      await ref.read(syncRepoProvider).batchUpload(items);
      await box.clear();
    } catch (_) {/* retry next online event */}
  }
}

final syncDrainerProvider = NotifierProvider<SyncDrainer, void>(SyncDrainer.new);
```

Inisialisasi di `main.dart`:
```dart
// Kick off sync drainer
ProviderContainer().read(syncDrainerProvider);
```

## 4. Pola Konsumsi di UI

### 4.1 Async data dengan AsyncValue.when

```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(currentPlanProvider);
    final summaryAsync = ref.watch(dailySummaryProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentPlanProvider);
          ref.invalidate(dailySummaryProvider);
        },
        child: planAsync.when(
          loading: () => const HomeSkeleton(),
          error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(currentPlanProvider)),
          data: (plan) => HomeContent(plan: plan, summary: summaryAsync),
        ),
      ),
    );
  }
}
```

### 4.2 StateNotifier untuk form

```dart
class SetupStep1Basic extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(setupDraftProvider);
    final notifier = ref.read(setupDraftProvider.notifier);

    return SetupScaffold(
      step: 1,
      title: 'Hai! Kenalkan dirimu 👋',
      subtitle: 'Kami perlu beberapa informasi dasar untuk mulai.',
      body: Column(
        children: [
          InputField(
            label: 'Nama Panggilanmu',
            initialValue: draft.name,
            onChanged: (v) => notifier.updateBasic(name: v),
          ),
          // ... usia, gender ...
        ],
      ),
      primaryButton: PrimaryButton(
        label: 'Lanjutkan →',
        onPressed: draft.isStep1Valid
            ? () => context.go('/setup/step2')
            : null,
      ),
    );
  }
}
```

## 5. Error & Loading Convention

- Saat loading data utama layar → tampilkan **skeleton** atau **shimmer**, bukan blank.
- Error API → tampilkan `ErrorState` widget (icon + pesan ID + tombol Retry).
- Validasi form gagal → `Form.validate()` + helper text merah di bawah field.
- Network error vs server error: tampilkan pesan berbeda (cek `e.type` dari DioException).

## 6. Testing State Logic (Minimum)

Wajib test:
- `HealthCalculator.compute(...)` (BMI/BMR/TDEE/BFP) — angka harus benar untuk berbagai profil.
- `SetupDraftNotifier` — chain update tidak menghapus field lain.
- `PlanRepository.getCurrentPlan()` — fallback ke cache saat offline.

Skip test untuk widget/UI di hackathon (manual QA cukup).

## 7. Catatan

- **Hindari over-watching**: jangan `ref.watch(...)` di tempat yang tidak perlu rebuild. Pakai `ref.read(...)` di event handler.
- **autoDispose** untuk provider yang scope-nya layar (planGenerationProvider, activeWorkoutProvider) — supaya tidak leak setelah pop.
- **family** untuk provider yang butuh parameter (preWorkoutCheckinProvider per dayIndex).
- **`ref.listen`** untuk side-effect (navigasi, snackbar) saat state berubah, bukan `watch`.
