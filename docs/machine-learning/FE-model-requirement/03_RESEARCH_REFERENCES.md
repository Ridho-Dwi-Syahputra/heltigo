# Heltigo ML — Research References (Jurnal 2022-2025)

> Kompilasi paper akademik terbaru sebagai dasar pemilihan algoritma, preprocessing, dan hyperparameter untuk 3 model ML Heltigo. Hasil systematic literature review yang dilakukan 2026-05-16.

**Total paper di-review:** 30+
**Domain:** Workout recommendation, meal planning, adaptive RL health coaching, small tabular data preprocessing

---

## 1. Personalized Workout Recommendation

### Top Papers

| # | Paper | Tahun | Venue | Key Insight |
|---|---|---|---|---|
| 1 | A machine learning framework for personalized exercise prescription based on BMI and physical fitness assessment | 2025/26 | Nature Scientific Reports | Hybrid 1D-CNN + Multi-head Attention + LightGBM. Dataset 6,698 students. **94.5% accuracy** BMI-aligned classification. |
| 2 | Personalized fitness recommendations using ML for national health strategy | 2025 | Nature Sci Reports | XGBoost beats RF + Deep MLP. **F1 ~0.92** untuk nationwide gym data. |
| 3 | Comparative Analysis of Classification Algorithms for Predicting Membership Churn — **EightGym Indonesia** | 2024-25 | Journal of Information Systems and Informatics | XGBoost: **95% accuracy** vs RF + SVM. Highly relevant untuk konteks ID. |
| 4 | PERFECT: Personalized Exercise Recommendation Framework | 2024 | ACM TCH | Bandit-based RL framework dengan biomarkers. |
| 5 | ML Based Smart Workout Recommendation System | 2024 | JETIR | Decision Tree Regression, 99.94% test acc (likely optimistic). |

### Algoritma Terbaik per Benchmark

**Untuk dataset tabular 973-1800 baris:**
- 🥇 **XGBoost** — F1 0.85-0.92 di paper 2024-2025
- 🥈 **LightGBM** — comparable, lebih cepat
- 🥉 **Random Forest** — masih kompetitif tapi consistently underperform vs gradient boosting

**Untuk dataset >10k baris dengan sequential data:**
- **LSTM/Transformer** (FitRec-Attn UCSD pakai 250k records)
- **Hybrid 1D-CNN + LightGBM** — emerging SOTA

**Hindari untuk <10k baris:** Deep learning standalone (overfitting).

### Feature Engineering Trick (terbukti di jurnal)

```python
# Mifflin-St Jeor BMR
bmr = 10*weight_kg + 6.25*height_cm - 5*age + (5 if gender_M else -161)

# TDEE
activity_factor = {1: 1.2, 2: 1.375, 3: 1.55, 4: 1.725, 5: 1.9}[workout_freq_band]
tdee = bmr * activity_factor

# Fat-Free Mass Index
ffmi = (weight_kg * (1 - fat_pct/100)) / (height_m**2)

# Interaction features (improve AUC 3-4 pp per Nature 2025)
df['bmi_x_age'] = df['bmi'] * df['age']
df['activity_x_duration'] = df['workout_freq'] * df['session_duration']
df['bpm_intensity_ratio'] = df['avg_bpm'] / df['max_bpm']
```

### Hyperparameter Tuning (XGBoost via Optuna)

```python
import optuna
from xgboost import XGBClassifier
from sklearn.model_selection import cross_val_score

def objective(trial):
    params = {
        'learning_rate': trial.suggest_float('lr', 0.01, 0.3, log=True),
        'max_depth': trial.suggest_int('depth', 3, 10),
        'n_estimators': trial.suggest_int('n_est', 100, 1000, step=100),
        'subsample': trial.suggest_float('subsample', 0.6, 1.0),
        'colsample_bytree': trial.suggest_float('colsample', 0.6, 1.0),
        'min_child_weight': trial.suggest_int('min_child', 1, 10),
        'gamma': trial.suggest_float('gamma', 0, 5),
        'reg_alpha': trial.suggest_float('reg_alpha', 0, 5),
        'reg_lambda': trial.suggest_float('reg_lambda', 0, 5),
    }
    model = XGBClassifier(**params, random_state=42, n_jobs=-1)
    return cross_val_score(model, X, y, cv=5, scoring='f1_macro').mean()

study = optuna.create_study(direction='maximize',
                            sampler=optuna.samplers.TPESampler(seed=42))
study.optimize(objective, n_trials=50)
print(f'Best F1: {study.best_value:.4f}')
print(f'Best params: {study.best_params}')
```

**Baseline target:** F1-macro ≥ 0.85, Accuracy ≥ 0.88, AUC ≥ 0.92.

---

## 2. Personalized Meal Planning with Budget Constraint

### Top Papers

| # | Paper | Tahun | Venue | Key Insight |
|---|---|---|---|---|
| 1 | Towards automatically generating meal plan based on genetic algorithm | 2024 | Soft Computing (Springer) | GA outperforms greedy knapsack on diversity + nutritional balance. |
| 2 | AI Diet Planner Using NN with Knapsack Optimizer | 2024 | IJERND | Hybrid NN + 0/1 Knapsack. MAE 3.8% on nutrient prediction. |
| 3 | AI-based system for food selection in **Indonesian restaurants** | 2025 | Frontiers in Nutrition | **Indonesia-specific GA engine.** Cuisine-aware (Padang, Jawa, dst). |
| 4 | An AI-based nutrition recommendation system: Mediterranean cuisine validation | 2024-25 | Frontiers in Nutrition (PMC) | GA + content-based filtering. Transferable cross-cuisine. |
| 5 | An Intelligent Food Recommendation System for Dine-in Customers with NCD History — **IPB Jurnal Keteknikan** | 2024 | Indonesia | GA + medical condition integration. |
| 6 | Diet Recommendation Model Using Multi Constraint Metaheuristic and Knapsack | 2023 | ResearchGate | Hybrid knapsack + metaheuristic kompetitif vs pure GA. |

### Algoritma Terbaik

**Status Knapsack vs RL vs GA:**

| Approach | Best For | Heltigo Fit |
|---|---|---|
| **0/1 Knapsack (greedy)** | Daily plan dengan budget+calorie constraint | ✅ Primary baseline |
| **Genetic Algorithm** | Multi-day diversity, complex objectives | ✅ Wrapper untuk 7-day plan |
| **Reinforcement Learning** | Longitudinal user feedback | ❌ Cold-start tidak cocok |
| **Hybrid Knapsack + GA** | Best of both worlds | ⭐ **Recommended** (Springer 2024) |

### GA Implementation Pattern (deap library)

```python
from deap import base, creator, tools, algorithms
import random

# Setup
creator.create('FitnessMax', base.Fitness, weights=(1.0,))
creator.create('Individual', list, fitness=creator.FitnessMax)

toolbox = base.Toolbox()
toolbox.register('food_pick', random.randint, 0, len(food_master) - 1)
toolbox.register('individual', tools.initRepeat, creator.Individual,
                 toolbox.food_pick, n=21)  # 7 days × 3 meals
toolbox.register('population', tools.initRepeat, list, toolbox.individual)

def fitness(individual):
    score = sum(food_master.iloc[idx]['score'] for idx in individual)
    # Diversity penalty: -2 per duplikat staple dalam 3 hari berurutan
    penalty = compute_diversity_penalty(individual, food_master)
    return (score - 2.0 * penalty,)

toolbox.register('evaluate', fitness)
toolbox.register('mate', tools.cxOnePoint)
toolbox.register('mutate', tools.mutUniformInt, low=0,
                 up=len(food_master)-1, indpb=0.05)
toolbox.register('select', tools.selTournament, tournsize=3)

pop = toolbox.population(n=30)
algorithms.eaSimple(pop, toolbox, cxpb=0.7, mutpb=0.2, ngen=50, verbose=True)
```

### Multi-Objective Handling

```python
# Weighted scalarization (most common)
score = (w1 * calorie_fit
       + w2 * price_fit
       + w3 * macro_balance
       + w4 * diversity)

# Per goal
WEIGHTS = {
    'WEIGHT_LOSS': {'protein': 0.50, 'calories': 0.20, 'fiber': 0.30, 'fat': 0.20},
    'MUSCLE_GAIN': {'protein': 0.45, 'calories': 0.40, 'fiber': 0.10, 'fat': 0.05},
    'MAINTENANCE': {'protein': 0.35, 'calories': 0.35, 'fiber': 0.20, 'fat': 0.10},
    'PERFORMANCE': {'protein': 0.40, 'calories': 0.45, 'fiber': 0.10, 'fat': 0.05},
}
```

### Indonesian NLP (IndoBERT — opsional Phase 2)

```python
from transformers import AutoTokenizer, AutoModel
import torch

tokenizer = AutoTokenizer.from_pretrained('indobenchmark/indobert-base-p1')
model = AutoModel.from_pretrained('indobenchmark/indobert-base-p1')

def embed_food_name(name: str) -> torch.Tensor:
    tokens = tokenizer(name, return_tensors='pt', truncation=True, max_length=32)
    with torch.no_grad():
        outputs = model(**tokens)
    return outputs.last_hidden_state.mean(dim=1).squeeze()

# Untuk semantic similarity / clustering nama makanan Indonesia
```

**Alternatif lighter:** TF-IDF on ingredient names + cosine similarity (cheap baseline).

---

## 3. Adaptive Plan Adjustment / RL Health Coaching

### Top Papers

| # | Paper | Tahun | Venue | Key Insight |
|---|---|---|---|---|
| 1 | Effectiveness of a Digital Health Intervention Leveraging RL: **DIAMANTE Trial** | 2024 | JMIR | RL messaging meningkatkan step counts + turunkan HbA1c vs schedule statis. **Real RCT evidence.** |
| 2 | Personalized Sports Health Recommendation Assisted by Q-Learning | 2024 | IJHCI | Q-learning: persistence +25%, health score +13.3%, AUC 96%. |
| 3 | Robust Mixed-Effects Bandit (DML-TS-NNR) | 2024-25 | PMC | Contextual bandit dengan user-specific params. Lebih baik dari vanilla Thompson sampling. |
| 4 | Enhancing Digital Health Services: ML for Personalized Exercise Goal | 2024 | Digital Health (SAGE) | Deep RL evaluasi fitness-fatigue. Outperforms fixed-goal. |
| 5 | Keeping people active at home with RL fitness | 2023 | IJCAI | Practical RL recommender. |
| 6 | REINFORCE Trial: RL medication adherence | 2024 | npj Digital Medicine | Real-world adherence gains. |

### Method Comparison

| Approach | When | Heltigo Fit |
|---|---|---|
| **Rule-based** | Cold start, no historical data | ✅ Phase 1 (current) |
| **Contextual Multi-Armed Bandit (Thompson Sampling)** | Small data, real-time, exploration-exploitation | ⭐ **Phase 2 recommended** |
| **Q-Learning / DQN** | Sequential, ≥4 weeks data | ⏳ Phase 3 (future) |
| **Deep RL (PPO/Actor-Critic)** | Large state spaces | ❌ Overkill |

### Thompson Sampling Contextual Bandit (Phase 2)

```python
import numpy as np
from scipy.stats import beta

class ThompsonSamplingBandit:
    """Contextual bandit dengan 3 arms: REDUCE, MAINTAIN, INTENSIFY."""

    def __init__(self, arms=['REDUCE', 'MAINTAIN', 'INTENSIFY']):
        self.arms = arms
        # Beta(alpha, beta) per arm — start uniform prior
        self.params = {arm: {'alpha': 1, 'beta': 1} for arm in arms}

    def select_arm(self, context):
        # Sample dari posterior tiap arm
        samples = {arm: beta.rvs(p['alpha'], p['beta'])
                   for arm, p in self.params.items()}
        return max(samples, key=samples.get)

    def update(self, arm, reward):
        # Reward ∈ [0, 1] — compliance + progress
        self.params[arm]['alpha'] += reward
        self.params[arm]['beta'] += (1 - reward)

# Reward composition (per DIAMANTE)
def compute_reward(compliance: float, weight_progress: float,
                   dropout: bool) -> float:
    alpha, beta_w, gamma = 0.5, 0.4, 0.3
    r = alpha * compliance + beta_w * weight_progress - gamma * float(dropout)
    return max(0, min(1, r))
```

### Kapan Switch Rule → Bandit?

- Setelah user akumulasi **≥ 4 minggu** data
- Setelah `daily_logs` punya ≥ 100 entries per user
- Setelah model warm-up dengan rule selama 2-3 minggu

---

## 4. Preprocessing untuk Small Tabular Data (973-1800 rows)

### Top Papers

| # | Paper | Tahun | Venue | Key Insight |
|---|---|---|---|---|
| 1 | Handling imbalanced medical datasets: decade survey | 2024 | Springer AI Review | SMOTE-variants masih standard. Deep-CTGAN emerging. |
| 2 | ML model enhancement via synthetic data | 2025 | Nature Sci Reports | CTGAN > SMOTE pada small medical datasets dengan target non-linear. |
| 3 | Augmenting small tabular health data | 2025 | BMC Medical Informatics | CTGAN improves AUC 3-7 pp pada <2000 rows. |
| 4 | Strategic application of SMOTE variants | 2025 | IACIS | SMOTEENN + SMOTE-Tomek + BorderlineSMOTE benchmarks. |
| 5 | Comprehensive evaluation framework for synthetic tabular data | 2025 | Frontiers Digital Health | Fidelity + utility + privacy benchmarks. |

### Augmentation Hierarchy (untuk 973-1800 rows)

```
1. SMOTE / Borderline-SMOTE       ← Cheap, baseline
        ↓
2. SMOTEENN (SMOTE + EditedNN)    ← ⭐ Recommended untuk medical
        ↓
3. ADASYN                          ← Untuk hard-to-classify minority
        ↓
4. CTGAN / TVAE (SDV library)     ← Kalau SMOTE plateau (gain 3-7 pp)
        ↓
5. Deep-CTGAN + ResNet            ← Bleeding edge, overkill hackathon
```

### SMOTEENN Code (recommended)

```python
from imblearn.combine import SMOTEENN
from imblearn.over_sampling import SMOTE
from imblearn.under_sampling import EditedNearestNeighbours

smote_enn = SMOTEENN(
    smote=SMOTE(random_state=42, k_neighbors=5),
    enn=EditedNearestNeighbours(n_neighbors=3),
    random_state=42
)
X_resampled, y_resampled = smote_enn.fit_resample(X_train, y_train)

# Sebelum: REST=1500, HIIT=200 (imbalanced 7.5:1)
# Setelah: ~equal distribution, plus cleaned noisy samples
```

### Feature Scaling Benchmark (i-MRI 2024)

| Scaler | Avg Val Acc | Avg Val AUC | Best For |
|---|---|---|---|
| None | 0.70 | 0.78 | Tree-based (XGBoost handles tanpa scaling) |
| Standard | 0.71 | 0.77 | Gaussian features |
| MinMax | 0.70 | 0.77 | Bounded output NN |
| **Robust** | **0.73** | **0.79** | **⭐ Health data dengan outliers** |

```python
from sklearn.preprocessing import RobustScaler

scaler = RobustScaler()  # Uses median + IQR, robust to outliers
X_scaled = scaler.fit_transform(X_train)
# Save untuk inference
import joblib; joblib.dump(scaler, 'scaler.pkl')
```

### Multi-Label Cross-Validation

```python
# ❌ Wrong (sklearn StratifiedKFold tidak handle multi-label)
from sklearn.model_selection import StratifiedKFold
# StratifiedKFold().split(X, y_multi)  # Salah!

# ✅ Correct (iterative-stratification)
from iterstrat.ml_stratifiers import MultilabelStratifiedKFold

mskf = MultilabelStratifiedKFold(n_splits=5, shuffle=True, random_state=42)
for train_idx, val_idx in mskf.split(X, y_multi):
    X_train, X_val = X.iloc[train_idx], X.iloc[val_idx]
    y_train, y_val = y_multi.iloc[train_idx], y_multi.iloc[val_idx]
```

---

## 5. Tech Stack Recommendation (Hackathon-Ready)

| Layer | Library | Versi | Why |
|---|---|---|---|
| **Tabular SOTA** | XGBoost | ≥2.0 | Beats deep models for <10k rows |
| **Tabular alt** | LightGBM | ≥4.0 | Faster than XGBoost, comparable accuracy |
| **AutoML** | AutoGluon | 1.5 | Zero-shot competitive (optional) |
| **Hyperparameter** | Optuna | 3.5+ | TPE sampler, replaces GridSearch |
| **Imbalance** | imbalanced-learn | 0.12+ | SMOTE/SMOTEENN/ADASYN |
| **Indonesian NLP** | transformers + IndoBERT | 4.36+ | Food name embedding |
| **Optimization** | PuLP / OR-Tools | latest | Linear/knapsack |
| **GA** | DEAP | 1.4+ | Mature, fleksibel |
| **RL bandits** | Custom Python | — | Thompson Sampling implementation simple |
| **Multi-label CV** | iterative-stratification | 0.1.7+ | Proper multi-label split |
| **Validation** | scikit-learn | 1.4+ | Metrics + base models |

---

## 6. Key Insights untuk Heltigo

### Workout Recommender
- ⭐ Start dengan **XGBoost + Optuna 50 trial**
- Skip LSTM/Transformer (dataset terlalu kecil)
- Target F1-macro ≥ 0.85
- Feature engineering critical: BMR, TDEE, interaction features (+3-4 pp AUC)

### Meal Planner
- ⭐ **Hybrid Knapsack (daily) + GA (weekly diversity)**
- Library: `deap` untuk GA
- Multi-objective: weighted scalarization (cukup), NSGA-II opsional
- IndoBERT untuk food embedding (Phase 2)

### Adaptive Replanner
- **Phase 1**: Rule 3-cabang (sudah ada) + XGBoost Regressor untuk fine-tune
- **Phase 2**: Thompson Sampling bandit (setelah ≥4 minggu data)
- **Phase 3**: Q-Learning (future, ≥3 bulan data)
- Reward: `α·compliance + β·progress - γ·dropout`

### Preprocessing Universal
- **RobustScaler** untuk numerik (handles outliers BMI, weight)
- **SMOTEENN** untuk class imbalance
- **iterative-stratification** untuk multi-label CV
- **Random seed = 42** semua tempat untuk reproducibility

---

## 7. Sumber Lengkap (URL)

### Workout Recommendation
- [Nature Sci Reports — ML Framework Exercise Prescription](https://www.nature.com/articles/s41598-026-42405-2)
- [Nature Sci Reports — Personalized fitness ML 2025](https://www.nature.com/articles/s41598-025-25566-4)
- [EightGym Indonesia — Classification Algorithms Comparison](https://journal-isi.org/index.php/isi/article/view/1120)
- [ACM TCH — PERFECT Framework](https://dl.acm.org/doi/10.1145/3696425)
- [JETIR — Smart Workout Recommendation](https://www.jetir.org/papers/JETIR2405918.pdf)
- [Frontiers — Deep Hybrid BMI Prediction](https://www.frontiersin.org/journals/public-health/articles/10.3389/fpubh.2025.1640226/full)

### Meal Planning
- [Soft Computing — GA Meal Plan 2024](https://link.springer.com/article/10.1007/s00500-023-09556-0)
- [IJERND — NN + Knapsack Diet Planner](https://www.ijernd.com/index.php/2024/article/view/85)
- [Frontiers Nutrition — Mediterranean AI](https://pmc.ncbi.nlm.nih.gov/articles/PMC12390980/)
- [Frontiers Nutrition — Indonesian Restaurants 2025](https://www.frontiersin.org/journals/nutrition/articles/10.3389/fnut.2025.1590523/full)
- [IPB Jurnal — Food Recommendation NCD](https://journal.ipb.ac.id/index.php/jtep/article/view/52452)
- [arXiv — Linear Optimization Perfect Meal](https://arxiv.org/abs/2501.04143)

### RL Health Coaching
- [JMIR — DIAMANTE RCT](https://www.jmir.org/2024/1/e60834)
- [IJHCI — Q-Learning Sports Health](https://www.tandfonline.com/doi/abs/10.1080/10447318.2023.2295693)
- [PMC — Mixed-Effects Bandit](https://pmc.ncbi.nlm.nih.gov/articles/PMC12395203/)
- [SAGE — Personalized Exercise Goal](https://journals.sagepub.com/doi/full/10.1177/20552076241233247)
- [npj Digital Medicine — REINFORCE Trial](https://www.nature.com/articles/s41746-024-01028-5)
- [IJCAI — RL Home Fitness](https://dl.acm.org/doi/10.24963/ijcai.2023/692)

### Preprocessing / Augmentation
- [Springer AI Review — Imbalanced Medical Survey](https://link.springer.com/article/10.1007/s10462-024-10884-2)
- [Nature Sci Reports — Synthetic Data ML 2025](https://www.nature.com/articles/s41598-025-15019-3)
- [BMC Med Informatics — Augmenting Small Tabular Health](https://link.springer.com/article/10.1186/s12911-025-03266-3)
- [Frontiers Digital Health — Synthetic Tabular Evaluation](https://www.frontiersin.org/journals/digital-health/articles/10.3389/fdgth.2025.1576290/full)
- [IACIS — Strategic SMOTE Application](https://iacis.org/iis/2025/2_iis_2025_70-85.pdf)
- [Iterative Stratification GitHub](https://github.com/trent-b/iterative-stratification)
- [RobustScaler Docs](https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.RobustScaler.html)

### Libraries
- [Optuna](https://optuna.org/)
- [TabPFN-2.5](https://priorlabs.ai/technical-reports/tabpfn-2-5-model-report)
- [AutoGluon Tabular 1.5](https://auto.gluon.ai/stable/api/autogluon.tabular.TabularPredictor.fit.html)
- [IndoBERT — HuggingFace](https://huggingface.co/indobenchmark/indobert-base-p1)
- [NusaBERT 2025](https://aclanthology.org/2025.sealp-1.2.pdf)
- [DEAP Documentation](https://deap.readthedocs.io/)

---

**Lihat juga:**
- [`00_OVERVIEW.md`](00_OVERVIEW.md) — Arsitektur ML Heltigo
- [`01_MODELS_SPEC.md`](01_MODELS_SPEC.md) — Spec detail per model (sudah pakai stack ini)
- [`02_DATASETS_INVENTORY.md`](02_DATASETS_INVENTORY.md) — Dataset details
