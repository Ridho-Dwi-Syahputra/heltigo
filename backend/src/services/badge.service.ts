/**
 * Badge unlock detector.
 * Dipanggil setiap selesai workout / log meal.
 */
import { prisma } from '../config/db';

function toBig(id: string) {
  return BigInt(id);
}

export const badgeService = {
  async checkUnlocks(userId: string) {
    const badges = await prisma.badge.findMany({ where: { isActive: true } });
    if (!badges.length) return { unlocked: [] };

    const [streak, sessionCount, mealLogCount, profile] = await Promise.all([
      prisma.streak.findUnique({ where: { userId: toBig(userId) } }),
      prisma.workoutSession.count({ where: { userId: toBig(userId), status: 'COMPLETED' } }),
      prisma.mealLog.count({ where: { userId: toBig(userId) } }),
      prisma.healthProfile.findUnique({ where: { userId: toBig(userId) } }),
    ]);

    const ownedBadges = await prisma.userBadge.findMany({
      where: { userId: toBig(userId) },
      select: { badgeId: true },
    });
    const ownedIds = new Set(ownedBadges.map((b) => b.badgeId.toString()));

    const newlyUnlocked: Array<{ id: string; code: string; title: string }> = [];

    for (const badge of badges) {
      if (ownedIds.has(badge.id.toString())) continue;
      let unlocked = false;
      switch (badge.criterionType) {
        case 'STREAK':
          unlocked = (streak?.currentStreak ?? 0) >= badge.criterionValue;
          break;
        case 'WORKOUTS_DONE':
          unlocked = sessionCount >= badge.criterionValue;
          break;
        case 'MEALS_LOGGED':
          unlocked = mealLogCount >= badge.criterionValue;
          break;
        case 'WEIGHT_LOST':
          if (profile) {
            const lost = Number(profile.startWeightKg) - Number(profile.weightKg);
            unlocked = lost >= badge.criterionValue;
          }
          break;
        default:
          break;
      }
      if (unlocked) {
        await prisma.userBadge.create({
          data: { userId: toBig(userId), badgeId: badge.id },
        });
        newlyUnlocked.push({
          id: badge.id.toString(),
          code: badge.code,
          title: badge.title,
        });
      }
    }

    return { unlocked: newlyUnlocked };
  },
};
