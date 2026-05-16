import pandas as pd
import json
import re

# File paths
parquet_path = r"D:\Local Disk D\Tugas\hackathon core3d\machine-learning\notebook\training_model\Model_Perencana_Makan\output\preprocessed\food_master_v3.parquet"
output_sql = r"D:\Local Disk D\Tugas\hackathon core3d\backend\seed_data.sql"

# 1. Load Food Data
df_food = pd.read_parquet(parquet_path)

def escape_sql(val):
    if pd.isna(val):
        return "NULL"
    if isinstance(val, bool):
        return "1" if val else "0"
    if isinstance(val, (int, float)):
        return str(val)
    # Escape single quotes
    val_str = str(val).replace("'", "''")
    return f"'{val_str}'"

# 2. Write SQL
with open(output_sql, "w", encoding="utf-8") as f:
    f.write("-- ============================================================\n")
    f.write("-- HELTIGO SEED DATA\n")
    f.write("-- ============================================================\n\n")
    f.write("SET FOREIGN_KEY_CHECKS = 0;\n\n")
    
    # EXERCISE MASTER
    f.write("-- ------------------------------------------------------------\n")
    f.write("-- 1. EXERCISE MASTER\n")
    f.write("-- ------------------------------------------------------------\n")
    f.write("INSERT INTO `exercise_master` (`id`, `slug`, `name`, `description`, `difficulty`, `is_active`) VALUES\n")
    
    exercises = [
        (1, "dynamic-stretching", "Dynamic Stretching", "Stretching dinamis sebelum mulai latihan utama.", "BEGINNER"),
        (2, "jogging", "Jogging", "Lari kecil untuk melatih ketahanan jantung.", "BEGINNER"),
        (3, "jump-rope", "Jump Rope", "Lompat tali untuk membakar kalori secara intens.", "INTERMEDIATE"),
        (4, "jumping-jacks", "Jumping Jacks", "Lompat dengan membuka tutup tangan dan kaki.", "BEGINNER"),
        (5, "burpees", "Burpees", "Kombinasi squat, push-up, dan lompatan vertikal.", "ADVANCED"),
        (6, "mountain-climbers", "Mountain Climbers", "Gerakan seperti mendaki dalam posisi plank.", "INTERMEDIATE"),
        (7, "box-jump", "Box Jump", "Lompat ke atas kotak/platform dengan kedua kaki.", "ADVANCED"),
        (8, "push-up", "Push Up", "Latihan otot dada, bahu, dan trisep.", "INTERMEDIATE"),
        (9, "squat", "Squat", "Latihan otot paha dan glutes.", "BEGINNER"),
        (10, "plank", "Plank", "Tahan posisi push-up untuk kekuatan core.", "BEGINNER"),
        (11, "cat-cow", "Cat-Cow", "Peregangan punggung dari posisi merangkak.", "BEGINNER"),
        (12, "child-pose", "Child Pose", "Peregangan otot punggung bawah dan pinggul.", "BEGINNER"),
        (13, "pigeon-pose", "Pigeon Pose", "Peregangan mendalam pada otot pinggul bagian bawah.", "INTERMEDIATE"),
        (14, "static-stretching", "Static Stretching", "Peregangan statis setelah selesai latihan utama.", "BEGINNER")
    ]
    
    for i, ex in enumerate(exercises):
        id, slug, name, desc, diff = ex
        line = f"({id}, '{slug}', '{name}', '{desc}', '{diff}', 1)"
        if i == len(exercises) - 1:
            f.write(line + ";\n\n")
        else:
            f.write(line + ",\n")
            
    # FOOD MASTER
    f.write("-- ------------------------------------------------------------\n")
    f.write("-- 2. FOOD MASTER (1346 items)\n")
    f.write("-- ------------------------------------------------------------\n")
    f.write("INSERT INTO `food_master` (`id`, `slug`, `name`, `category`, `cuisine`, `calories_per_portion`, `protein_g`, `fat_g`, `carbs_g`, `estimated_price_idr`, `is_halal`, `is_vegetarian`, `is_vegan`, `is_gluten_free`, `image_url`, `base_portion`, `base_portion_gram`, `fiber_g`, `is_active`) VALUES\n")
    
    for i, row in df_food.iterrows():
        cols = [
            row['id'], row['slug'], row['name'], row['category'], row['cuisine'],
            row['calories_per_portion'], row['protein_g'], row['fat_g'], row['carbs_g'],
            row['estimated_price_idr'], row['is_halal'], row['is_vegetarian'], row['is_vegan'],
            row['is_gluten_free'], row['image_url'], row['base_portion'], row['base_portion_gram'],
            row['fiber_g'], row['is_active']
        ]
        
        # Format as SQL string
        sql_vals = [escape_sql(c) for c in cols]
        line = f"({', '.join(sql_vals)})"
        
        if i == len(df_food) - 1:
            f.write(line + ";\n\n")
        else:
            f.write(line + ",\n")
            
    f.write("SET FOREIGN_KEY_CHECKS = 1;\n")

print(f"Generated {output_sql} with {len(df_food)} food items and {len(exercises)} exercises.")
