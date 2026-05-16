export const intensityAdjusterService = {
  getMultiplier(mood: string, energy: number, sleepBand: string) {
    let multiplier = 1.0;
    
    if (mood === 'VERY_BAD' || mood === 'BAD') multiplier -= 0.1;
    if (mood === 'VERY_GOOD' || mood === 'GOOD') multiplier += 0.1;
    
    if (energy <= 3) multiplier -= 0.15;
    if (energy >= 8) multiplier += 0.15;

    if (sleepBand === 'LT5') multiplier -= 0.2;
    if (sleepBand === 'GT8') multiplier += 0.1;

    return Math.max(0.5, Math.min(1.5, multiplier));
  }
};
