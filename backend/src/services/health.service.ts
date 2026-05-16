export const healthService = {
  calculateBMI(weightKg: number, heightCm: number) {
    const heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  },
  calculateBMR(weightKg: number, heightCm: number, age: number, gender: 'M' | 'F' | 'OTHER') {
    let base = 10 * weightKg + 6.25 * heightCm - 5 * age;
    return gender === 'M' ? base + 5 : base - 161;
  },
  calculateTDEE(bmr: number, fitnessLevel: string) {
    const multipliers: Record<string, number> = {
      'BEGINNER': 1.2,
      'INTERMEDIATE': 1.55,
      'ADVANCED': 1.725
    };
    return bmr * (multipliers[fitnessLevel] || 1.2);
  }
};
