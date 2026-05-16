# Machine Learning — Models

> 📌 **Spec model final 2026-05-15** ada di:
> **[`FE-model-requirement/01_MODELS_SPEC.md`](FE-model-requirement/01_MODELS_SPEC.md)**
>
> Spec terbaru detailing:
> - **4 model** (Workout RF, Meal Planner Knapsack, **Pre-Workout Intensity Adjuster ⬅ NEW**, Adaptive Replanner)
> - Per model: 13 input features, output schema, algoritma + hyperparameter, training dataset, augmentation, evaluation metrics, FastAPI endpoint, request/response Pydantic schema, performance budget
> - Pre-Workout Intensity Adjuster di-split jadi model terpisah (sebelumnya bagian dari Workout Recommender)
> - Meal Planner punya scoring weights **per goal** (WEIGHT_LOSS/MUSCLE_GAIN/MAINTENANCE/PERFORMANCE)
> - Replanner mendukung `user_choice` override (KEEP/MODERATE/AGGRESSIVE) dari S-34c
>
> Dokumen ini di-keep sebagai draft awal — gunakan **`01_MODELS_SPEC.md`** untuk reference terbaru.

---

3 model utama. Detail arsitektur dan logika tiap model.
**Update:** Sekarang **4 model** — lihat banner di atas.

---

## 1. Workout Recommender (Random Forest)

### 1.1 Tujuan

Generate **7-day workout plan** berdasarkan profil fisiologis dan preferensi user. Output: untuk setiap hari, daftar exercise dari master `exercise_items` dengan set/reps/rest yang sesuai.

### 1.2 Pendekatan: Hybrid (RF Classifier + Rule-based Composer)

**Mengapa hybrid:**
- Pure ML (e.g. neural model) overkill untuk dataset 973 baris.
- Pure rule-based kurang sophisticated, tidak bisa belajar pola "user obese + pemula → cardio dominan".
- **Hybrid:** RF prediksi `workout_type` per hari, lalu rule-based pilih exercise dari master sesuai kategori.

### 1.3 Pipeline

```
Profile + Day index
    │
    ▼
Feature engineering (13 fitur)
    │
    ▼
Random Forest Classifier (multi-output)
    │   Output: workout_type (CARDIO/STRENGTH/HIIT/FLEXIBILITY/REST)
    │           intensity_band (LOW/MID/HIGH)
    ▼
Rule-based Composer
    │   Filter exercise_master berdasarkan:
    │   - workout_type & muscle_group
    │   - equipment (HOME/GYM mode)
    │   - difficulty (sesuai fitness_level)
    │   - hindari kontraindikasi (kondisi khusus)
    ▼
Diversifikasi (jangan ulang exercise sama 2 hari berturut)
    │
    ▼
Set sets/reps/rest dari template per intensity_band & exercise difficulty
    │
    ▼
Generate phase order: WARMUP (1-2 exercises) → MAIN (4-6) → COOLDOWN (1-2)
    │
    ▼
Output 7-day plan
```

### 1.4 Random Forest Spec

```python
from sklearn.ensemble import RandomForestClassifier
from sklearn.multioutput import MultiOutputClassifier

base_rf = RandomForestClassifier(
    n_estimators=100,
    max_depth=10,
    min_samples_split=5,
    min_samples_leaf=2,
    random_state=42,
    class_weight='balanced',
)

# Multi-output: workout_type + intensity_band
model = MultiOutputClassifier(base_rf)
```

### 1.5 Fitur Input (13)

| Fitur | Tipe | Sumber |
|---|---|---|
| `bmi` | float | profile.bmi |
| `bmi_cat_enc` | int (0-3) | profile.bmi_category |
| `gender_enc` | int (0/1) | profile.gender |
| `age` | int | profile.age |
| `age_band_enc` | int (0-3) | derived |
| `fitness_level_enc` | int (0-2) | profile.fitness_level |
| `mode_enc` | int (0/1) | profile.workout_mode HOME/GYM |
| `days_per_week` | int (3-5) | profile.days_per_week |
| `session_minutes` | int (15/30/45/60) | profile.session_minutes |
| `day_index` | int (0-6) | hari ke berapa |
| `is_first_day_of_week` | bool | derived |
| `has_injury` | bool | profile.conditions |
| `has_chronic_condition` | bool | profile.conditions |

**Output:**
- `workout_type` ∈ {CARDIO, STRENGTH, HIIT, FLEXIBILITY, REST}
- `intensity_band` ∈ {LOW, MID, HIGH}

### 1.6 Training Set

Dari `gym_member_exercise_dataset` (973 baris). Karena dataset asli **tidak punya `day_index` atau `intensity_band`**, kita generate synthetic label dengan rule:

```python
# Pseudo-code
def synthesize_training_data(df_gym):
    rows = []
    for _, person in df_gym.iterrows():
        # Ekspansi 1 user → 7 hari (week schedule)
        for day_index in range(7):
            row = make_features(person, day_index)
            row['workout_type'] = decide_type(person, day_index)
            row['intensity_band'] = decide_intensity(person, day_index)
            rows.append(row)
    return pd.DataFrame(rows)

def decide_type(person, day):
    # Person punya 'Workout_Type' di dataset asli (CARDIO/STRENGTH/HIIT/Yoga)
    pattern = get_pattern(person['Workout_Type'], person['Workout_Frequency'])
    # pattern = ['STRENGTH', 'CARDIO', 'REST', 'STRENGTH', 'CARDIO', 'FLEXIBILITY', 'REST']
    return pattern[day]

def decide_intensity(person, day):
    # Hari pertama latihan setelah istirahat → HIGH
    # Hari ke-3+ berturut-turut → MID
    # Pemula → LOW dominan
    if person['Experience_Level'] == 'Beginner':
        return 'LOW' if day < 3 else 'MID'
    return 'HIGH' if day in [0, 3] else 'MID'
```

Hasil: ~6.800 training rows (973 × 7).

**Validasi:** 80/20 split. Target accuracy >70% per output. F1-macro >0.65.

### 1.7 Composer Rules

```python
def compose_workout_day(workout_type: str, intensity_band: str, profile: dict, exercise_master: pd.DataFrame):
    if workout_type == 'REST':
        return {'is_rest_day': True, 'exercises': []}

    # 1. Filter exercise sesuai mode
    pool = exercise_master[exercise_master['equipment'].isin(
        ['BODYWEIGHT'] if profile['workout_mode'] == 'HOME' else ['BODYWEIGHT', 'DUMBBELL', 'BARBELL', 'MACHINE']
    )]

    # 2. Filter sesuai workout_type
    type_to_muscle = {
        'CARDIO': ['FULL_BODY', 'LEG'],
        'STRENGTH': ['CHEST', 'BACK', 'SHOULDER', 'ARM', 'LEG'],
        'HIIT': ['FULL_BODY'],
        'FLEXIBILITY': ['FULL_BODY', 'CORE'],
    }
    pool = pool[pool['muscle_group'].isin(type_to_muscle[workout_type])]

    # 3. Filter difficulty sesuai fitness_level + intensity
    target_diff = {
        ('BEGINNER', 'LOW'): 'BEGINNER',
        ('BEGINNER', 'MID'): 'BEGINNER',
        ('BEGINNER', 'HIGH'): 'INTERMEDIATE',
        ('INTERMEDIATE', 'LOW'): 'BEGINNER',
        ('INTERMEDIATE', 'MID'): 'INTERMEDIATE',
        ('INTERMEDIATE', 'HIGH'): 'INTERMEDIATE',
        ('ADVANCED', 'LOW'): 'INTERMEDIATE',
        ('ADVANCED', 'MID'): 'ADVANCED',
        ('ADVANCED', 'HIGH'): 'ADVANCED',
    }[(profile['fitness_level'], intensity_band)]
    pool = pool[pool['difficulty'] == target_diff]

    # 4. Hindari kontraindikasi (kondisi khusus)
    if 'JOINT_PAIN' in profile['conditions']:
        pool = pool[~pool['name'].str.contains('squat|lunge|jumping', case=False)]

    # 5. Random sample untuk diversifikasi
    main_count = {'15': 3, '30': 4, '45': 5, '60': 6}[str(profile['session_minutes'])]
    main_exercises = pool.sample(n=min(main_count, len(pool)), random_state=hash(profile['user_id'] + str(day_index)) % 2**31)

    # 6. Tambah warmup & cooldown
    warmup = exercise_master[exercise_master['exercise_type'] == 'CARDIO'].sample(1)
    cooldown = exercise_master[exercise_master['exercise_type'] == 'FLEXIBILITY'].sample(1)

    # 7. Set sets/reps/rest dari template per intensity
    sets_reps_template = {
        'LOW': {'sets': 2, 'reps': 12, 'rest': 60},
        'MID': {'sets': 3, 'reps': 10, 'rest': 75},
        'HIGH': {'sets': 4, 'reps': 8, 'rest': 90},
    }[intensity_band]

    return assemble_day(warmup, main_exercises, cooldown, sets_reps_template)
```

### 1.8 AI Tip Generator

Untuk field `ai_tip` per exercise, pakai template:

```python
def gen_ai_tip(exercise_name: str, profile: dict, intensity: str) -> str:
    if profile['fitness_level'] == 'BEGINNER':
        return f"Lakukan {exercise_name} pelan, fokus pada teknik. Jangan paksa repetisi."
    if 'JOINT_PAIN' in profile['conditions']:
        return f"Hindari gerakan tajam saat {exercise_name}, dengarkan tubuhmu."
    if intensity == 'HIGH':
        return f"Tingkatkan tempo {exercise_name} sampai napas terengah, target zona kardio."
    return f"Pertahankan kontrol gerakan {exercise_name}. Istirahat antar set."
```

---

## 2. Workout Adjuster (Rule-Based Table)

### 2.1 Tujuan

Adjust intensity workout hari tertentu **real-time** berdasarkan input user di Pre-Workout Check-in (S-19): mood (1-5), energy (1-5), sleep_band (5 levels).

### 2.2 Pendekatan: Pure Rule-Based

**Mengapa bukan ML:**
- Tidak ada training data untuk adjustment factor.
- Logika sangat sederhana, ML overkill.
- Output deterministic — penting agar user trust.

### 2.3 Adjustment Table

```python
ADJUSTMENT_TABLE = {
    # Format: (energy, sleep_band) → multiplier (clamp -0.5..+0.2)
    # Mood diintegrasikan terpisah
    (1, '<5'): -0.40,
    (1, '5-6'): -0.35,
    (1, '6-7'): -0.30,
    (1, '7-8'): -0.25,
    (1, '>8'): -0.20,
    (2, '<5'): -0.30,
    (2, '5-6'): -0.25,
    (2, '6-7'): -0.20,
    (2, '7-8'): -0.15,
    (2, '>8'): -0.10,
    (3, '<5'): -0.20,
    (3, '5-6'): -0.10,
    (3, '6-7'): 0.00,
    (3, '7-8'): +0.05,
    (3, '>8'): +0.10,
    (4, '<5'): -0.10,
    (4, '5-6'): 0.00,
    (4, '6-7'): +0.05,
    (4, '7-8'): +0.10,
    (4, '>8'): +0.15,
    (5, '<5'): -0.05,
    (5, '5-6'): +0.05,
    (5, '6-7'): +0.10,
    (5, '7-8'): +0.15,
    (5, '>8'): +0.20,
}

def compute_adjustment(mood: int, energy: int, sleep_band: str) -> float:
    base = ADJUSTMENT_TABLE[(energy, sleep_band)]
    # Mood modifier ringan: kurangi 5% jika mood<3, tambah 3% jika mood>=4
    mood_mod = -0.05 if mood < 3 else (+0.03 if mood >= 4 else 0)
    return max(-0.50, min(0.20, base + mood_mod))
```

### 2.4 Apply Adjustment

```python
def apply_adjustment(workout_day: dict, adjustment: float) -> dict:
    factor = 1 + adjustment  # 0.5..1.2
    for ex in workout_day['exercises']:
        if ex['phase'] != 'MAIN':
            continue  # Tidak adjust warmup/cooldown
        ex['sets'] = max(1, round(ex['sets'] * factor))
        ex['reps'] = max(4, round(ex['reps'] * factor))
        # Saat volume berkurang, naikkan rest
        if adjustment < 0:
            ex['rest_seconds'] = round(ex['rest_seconds'] * (1 - adjustment))
        # AI tip update
        if adjustment < -0.2:
            ex['ai_tip'] = "Energi rendah hari ini. Fokus teknik, jangan paksa volume."
        elif adjustment > 0.1:
            ex['ai_tip'] = "Energi penuh, naikkan intensitas. Hati-hati overtraining."
    return workout_day
```

### 2.5 Persisted

Save tabel ke `app/data/workout_adj_rules.json` untuk audit, walau hardcode juga tidak masalah.

---

## 3. Meal Planner (Knapsack 0/1 + Diversifier)

### 3.1 Tujuan

Generate **7-day meal plan** dengan 2-4 meals per hari, mengoptimalkan **nilai gizi** dalam batasan **budget harian**.

### 3.2 Pendekatan: 0/1 Knapsack per Meal + Cross-Day Diversifier

**Per meal:**
- Pilih kombinasi food items dari pool yang memenuhi:
  - Budget meal: total cost ≤ allocated_budget
  - Calorie target meal: total calories dalam ±15% target
  - Macro balance: protein ≥ 15%, fat ≤ 35%
- Optimasi: maksimalkan **score gizi** (lihat §3.4)

**Cross-day:**
- Jangan ulang menu utama yang sama 2 hari berturut.
- Diversifikasi kategori (jangan 7 hari STAPLE yang sama).

### 3.3 Algoritma Knapsack

```python
def knapsack_meal(
    pool: pd.DataFrame,           # filtered foods (halal, diet restrictions, etc)
    budget: int,                  # allocated budget untuk meal ini (rupiah)
    calorie_target: int,          # target kalori meal
    calorie_tolerance: float = 0.15,
) -> list[dict]:
    """
    Return list of selected foods dengan field {food_id, servings}.
    """
    # 1. Pre-filter: drop yang harga > budget
    pool = pool[pool['estimated_price_idr'] <= budget].copy()
    if pool.empty:
        return []

    # 2. Compute score per item: gizi-per-rupiah
    pool['score'] = (
        0.4 * pool['protein_g'] / pool['estimated_price_idr'] * 1000 +
        0.3 * pool['calories_kcal'] / pool['estimated_price_idr'] * 1000 +
        0.2 * pool['fiber_g'].fillna(0) / pool['estimated_price_idr'] * 1000 -
        0.1 * pool['fat_g'] / pool['estimated_price_idr'] * 1000  # penalti lemak
    )

    # 3. DP knapsack — TAPI kompleksitas O(N×budget) dengan budget bisa 35000+
    # Untuk hackathon, pakai greedy approximation:
    pool = pool.sort_values('score', ascending=False)

    selected = []
    remaining_budget = budget
    accumulated_cal = 0

    for _, food in pool.iterrows():
        if remaining_budget < food['estimated_price_idr']:
            continue
        if accumulated_cal + food['calories_kcal'] > calorie_target * (1 + calorie_tolerance):
            continue

        # Pilih 1 serving dulu
        selected.append({
            'food_id': food['id'],
            'servings': 1.0,
            'calories_kcal': food['calories_kcal'],
            'cost_idr': food['estimated_price_idr'],
        })
        remaining_budget -= food['estimated_price_idr']
        accumulated_cal += food['calories_kcal']

        # Stop saat dekat target kalori
        if accumulated_cal >= calorie_target * (1 - calorie_tolerance):
            break

    # 4. Jika under-target, coba tambah 1 SNACK kecil
    if accumulated_cal < calorie_target * (1 - calorie_tolerance):
        snacks = pool[(pool['category'] == 'SNACK') & (pool['estimated_price_idr'] <= remaining_budget)]
        if not snacks.empty:
            top_snack = snacks.iloc[0]
            selected.append({
                'food_id': top_snack['id'],
                'servings': 0.5,
                'calories_kcal': int(top_snack['calories_kcal'] * 0.5),
                'cost_idr': int(top_snack['estimated_price_idr'] * 0.5),
            })

    return selected
```

### 3.4 Scoring

Bobot: protein > kalori > serat, penalti fat. Bisa ditweak per goal:
- `LOSE_WEIGHT`: protein 0.5, calories 0.2, fiber 0.3, fat penalty -0.2
- `MAINTAIN`: protein 0.4, calories 0.3, fiber 0.2, fat penalty -0.1
- `GAIN_MUSCLE`: protein 0.6, calories 0.3, fiber 0.1, fat penalty 0

### 3.5 Day Composer

```python
def compose_meal_day(profile: dict, day_index: int, food_master: pd.DataFrame) -> dict:
    # 1. Filter pool sesuai diet restrictions
    pool = food_master.copy()
    if 'halal' in profile['diet_restrictions']:
        pool = pool[pool['is_halal']]
    if 'vegetarian' in profile['diet_restrictions']:
        pool = pool[pool['is_vegetarian']]
    if 'no-nuts' in profile['diet_restrictions']:
        pool = pool[~pool['contains_nuts']]
    if 'no-dairy' in profile['diet_restrictions']:
        pool = pool[~pool['contains_dairy']]

    # 2. Allocate budget per meal
    daily_budget = profile['budget_per_day_idr']
    meal_count = profile['meal_frequency']

    allocations = {
        2: {'BREAKFAST': 0.45, 'DINNER': 0.55},
        3: {'BREAKFAST': 0.30, 'LUNCH': 0.40, 'DINNER': 0.30},
        4: {'BREAKFAST': 0.25, 'LUNCH': 0.35, 'SNACK': 0.10, 'DINNER': 0.30},
    }[meal_count]

    # 3. Allocate calorie per meal (sama proporsi)
    daily_calorie_target = profile['tdee'] + profile['target_calorie_adj']

    meals = []
    for meal_type, ratio in allocations.items():
        meal_budget = int(daily_budget * ratio)
        meal_calorie = int(daily_calorie_target * ratio)

        # 4. Filter pool sesuai meal_type semantic (BREAKFAST favor STAPLE+BEVERAGE, DINNER favor PROTEIN+VEG)
        type_pool = filter_by_meal_type(pool, meal_type)

        # 5. Knapsack
        foods = knapsack_meal(type_pool, meal_budget, meal_calorie)

        meals.append({
            'meal_type': meal_type,
            'calories_kcal': sum(f['calories_kcal'] for f in foods),
            'cost_idr': sum(f['cost_idr'] for f in foods),
            'ai_explanation': gen_meal_explanation(meal_type, foods, profile),
            'foods': foods,
        })

    # 6. Aggregate macros
    totals = compute_totals(meals, food_master)

    return {
        'day_index': day_index,
        'total_calories': totals['calories'],
        'total_protein_g': totals['protein'],
        'total_carb_g': totals['carb'],
        'total_fat_g': totals['fat'],
        'total_cost_idr': sum(m['cost_idr'] for m in meals),
        'meals': meals,
    }
```

### 3.6 Cross-Day Diversifier

Setelah 7 hari di-generate, cek duplikasi:

```python
def diversify_week(meal_days: list[dict], food_master: pd.DataFrame) -> list[dict]:
    seen_main_foods = set()  # food_id staple per hari
    for day in meal_days:
        # Cek main staple di lunch atau dinner
        main_meal = next((m for m in day['meals'] if m['meal_type'] in ('LUNCH', 'DINNER')), None)
        if not main_meal:
            continue
        staples = [f for f in main_meal['foods'] if food_master.loc[f['food_id'], 'category'] == 'STAPLE']
        for s in staples:
            if s['food_id'] in seen_main_foods:
                # Coba swap dengan staple lain (greedy, tidak rerun knapsack penuh)
                alt = find_alt_staple(food_master, exclude=seen_main_foods, calorie_match=s['calories_kcal'])
                if alt is not None:
                    s['food_id'] = alt['id']
                    s['cost_idr'] = alt['estimated_price_idr']
            seen_main_foods.add(s['food_id'])
    return meal_days
```

### 3.7 Alternative Endpoint

`POST /infer/meal/alternative`:
- Input: `plan_meal_id`, `target_calories`, `budget_idr`, `exclude_food_ids`, `diet_restrictions`
- Logic: jalankan `knapsack_meal` lagi dengan filter exclude
- Output: meal baru

---

## 4. Adaptive Replanner

### 4.1 Tujuan

Setiap Sunday 20:00, baca skor minggu sebelumnya dan generate plan minggu depan dengan adaptasi.

### 4.2 Pendekatan: Rule-Based 3-Cabang dengan Optional DT Tweaking

```python
def replan(input: dict) -> dict:
    score = input['score_percent']
    weight_change = input['weight_change_kg']
    weight_target_change = input['weight_target_change_kg']

    # Tentukan strategi
    if score < 50:
        strategy = 'REDUCE'
        notes = "Skor minggu ini rendah. Saya kurangi volume agar lebih mudah konsisten."
        recommendation = "Tidak apa-apa. Mulai dari yang lebih ringan minggu ini."
    elif score <= 80:
        strategy = 'MAINTAIN_SWAP'
        notes = "Performa stabil. Saya pertahankan struktur, ganti latihan yang sering diskip."
        recommendation = "Konsisten. Coba lebih disiplin di latihan yang sering kamu lewati."
    else:
        strategy = 'INTENSIFY'
        notes = "Performa luar biasa! Saya naikkan intensitas dan tambah volume."
        recommendation = "Performamu naik. Naikkan target minggu ini."

    # Apply ke workout plan
    new_workout_days = apply_strategy_to_workout(
        input['previous_plan']['workout_days'],
        strategy,
        skipped_ids=input['most_skipped_exercise_ids'],
        profile=input['profile'],
    )

    # Apply ke meal plan
    new_meal_days = apply_strategy_to_meal(
        input['previous_plan']['meal_days'],
        strategy,
        weight_diff=weight_change - weight_target_change,
        profile=input['profile'],
    )

    return {
        'ai_notes': notes,
        'ai_recommendation': recommendation,
        'workout_days': new_workout_days,
        'meal_days': new_meal_days,
    }
```

### 4.3 Apply Strategy

```python
def apply_strategy_to_workout(prev_days, strategy, skipped_ids, profile):
    if strategy == 'REDUCE':
        # Volume × 0.7, swap difficulty ke level lebih rendah
        return reduce_volume(prev_days, factor=0.7)
    if strategy == 'MAINTAIN_SWAP':
        # Sama volume, swap exercise yang sering diskip dengan alternatif
        return swap_skipped(prev_days, skipped_ids, profile)
    # INTENSIFY
    return intensify(prev_days, factor=1.15, profile=profile)
```

### 4.4 Optional Decision Tree Tweaking

Jika tim ML punya waktu, train DT kecil untuk **fine-tune intensity multiplier**:
- Input: score_percent, weight_diff, fitness_level, age
- Output: intensity_multiplier (0.5..1.3)
- Train data: synthetic dengan rules + sedikit jitter (~500 rows)

Tidak prioritas. Default rule-based 3-cabang sudah cukup untuk demo.

---

## 5. Prioritas Build

| Model | Day mulai | Status |
|---|---|---|
| Workout RF baseline | D3 | wajib P0 |
| Workout adjustment table | D7 | wajib P0 |
| Meal planner knapsack | D5 | wajib P0 |
| Replanner rule-based | D7 | wajib P0 |
| Workout RF tuning | D4 | nice-to-have |
| Meal cross-day diversifier | D9 | nice-to-have |
| Replanner DT tweaking | D10 | opsional |

---

## 6. Logging & Debugging

```python
import logging
logger = logging.getLogger(__name__)

def infer_workout(profile: dict) -> dict:
    logger.info(f"Workout inference for profile: bmi={profile['bmi']}, level={profile['fitness_level']}")
    # ... inference ...
    logger.info(f"Generated 7 days, total exercises: {sum(len(d['exercises']) for d in days)}")
    return {'days': days}
```

Saat error/edge case:
```python
if pool.empty:
    logger.warning(f"Empty pool after filtering for profile {profile}")
    raise HTTPException(422, "Tidak ada exercise yang cocok dengan preferensi")
```
