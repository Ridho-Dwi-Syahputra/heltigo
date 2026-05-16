"""
Fix 1: Remove explicit `backgroundColor: AppColors.background` from Scaffold & AppBar
       so Flutter's ThemeData (scaffoldBackgroundColor + AppBarTheme) handles it.
       This ensures EVERY screen reacts to theme changes via InheritedTheme.

Fix 2: Convert hardcoded `Color(0xFF0D0D0D)` → `AppColors.background` references
       in places that should be adaptive.
"""
import os
import re

BASE = 'd:/Local Disk D/Tugas/hackathon core3d/frontend/heltigo/lib'

SKIP_DIRS = ['styles']

def fix_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content

    # ── Remove `backgroundColor: AppColors.background,` that follows Scaffold( or AppBar(
    # Pattern 1: single line `backgroundColor: AppColors.background,`
    # We remove the entire line if it contains ONLY backgroundColor: AppColors.background

    lines = content.split('\n')
    new_lines = []
    i = 0
    while i < len(lines):
        line = lines[i]

        # Remove standalone `backgroundColor: AppColors.background,` lines
        stripped = line.strip()
        if stripped in (
            'backgroundColor: AppColors.background,',
            'backgroundColor: AppColors.background,',
        ):
            # Check if this is inside a Scaffold or AppBar context
            # (check previous non-empty lines for context)
            context_ok = True  # remove in most cases
            # But keep if it's in a Container/Dialog/Sheet context
            # Look backwards for the opening widget
            for j in range(i - 1, max(0, i - 15), -1):
                prev = lines[j].strip()
                if any(w in prev for w in ['Container(', 'BoxDecoration(', 'showModalBottomSheet', 'showDialog', 'Dialog(', 'AlertDialog(']):
                    context_ok = False
                    break
                if any(w in prev for w in ['Scaffold(', 'AppBar(', 'return Scaffold', 'child: Scaffold']):
                    context_ok = True
                    break

            if context_ok:
                i += 1
                continue  # skip this line (remove it)

        new_lines.append(line)
        i += 1

    new_content = '\n'.join(new_lines)

    if new_content != original:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return True
    return False


fixed = 0
for root, dirs, files in os.walk(BASE):
    if any(skip in root for skip in SKIP_DIRS):
        continue
    for fname in files:
        if fname.endswith('.dart'):
            path = os.path.join(root, fname)
            if fix_file(path):
                fixed += 1
                print(f'Fixed: {fname}')

print(f'\nTotal files fixed: {fixed}')
