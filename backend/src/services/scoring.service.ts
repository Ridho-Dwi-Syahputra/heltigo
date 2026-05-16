/**
 * Heuristik weekly score:
 *  - 50% workout consistency (sessions completed / 5)
 *  - 50% meal compliance (meal logs / 21 = 7d * 3 meals)
 */
export const scoringService = {
  calculateWeeklyScore(
    sessions: Array<{ status: string }>,
    meals: Array<unknown>,
    targetSessionsPerWeek = 5,
    targetMealsPerWeek = 21,
  ): number {
    const completed = sessions.filter((s) => s.status === 'COMPLETED').length;
    const workoutScore = Math.min(1, completed / targetSessionsPerWeek) * 50;
    const mealScore = Math.min(1, meals.length / targetMealsPerWeek) * 50;
    return Math.round(workoutScore + mealScore);
  },
};
