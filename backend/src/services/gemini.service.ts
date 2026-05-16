/**
 * Gemini Enrichment Service
 * ─────────────────────────
 * Layer untuk memperkaya output ML dengan teks personal Bahasa Indonesia.
 * Pola: BE → ML (numeric output) → Gemini (narrative output) → FE
 *
 * Setiap method punya fallback statis kalau Gemini error/timeout, supaya
 * endpoint user-facing tidak pernah blocking karena Gemini down.
 */
import { GoogleGenerativeAI } from '@google/generative-ai';
import { env } from '../config/env';
import { logger } from '../utils/logger';

const TIMEOUT_MS = parseInt(env.GEMINI_TIMEOUT_MS, 10) || 3000;

let client: GoogleGenerativeAI | null = null;
function getClient(): GoogleGenerativeAI | null {
  if (!env.GEMINI_API_KEY) return null;
  if (!client) client = new GoogleGenerativeAI(env.GEMINI_API_KEY);
  return client;
}

async function generate(prompt: string, fallback: string): Promise<string> {
  const c = getClient();
  if (!c) return fallback;

  try {
    const model = c.getGenerativeModel({ model: env.GEMINI_MODEL });
    const racePromise = model.generateContent(prompt);
    const timeoutPromise = new Promise<never>((_, reject) =>
      setTimeout(() => reject(new Error('GEMINI_TIMEOUT')), TIMEOUT_MS),
    );
    const result: any = await Promise.race([racePromise, timeoutPromise]);
    const text = result?.response?.text?.()?.trim();
    return text && text.length > 0 ? text : fallback;
  } catch (err) {
    logger.warn({ err: (err as Error).message }, 'Gemini enrichment failed, using fallback');
    return fallback;
  }
}

export const geminiService = {
  /**
   * Personalized congrats setelah workout session selesai.
   */
  async enrichWorkoutComplete(input: {
    workoutName?: string | null;
    durationMin: number;
    caloriesBurned: number;
    effortScore?: number | null;
    goal?: string | null;
  }): Promise<string> {
    const fallback =
      `Mantap! ${input.workoutName ?? 'Sesi latihan'} selesai dalam ${input.durationMin} menit ` +
      `dengan estimasi ${input.caloriesBurned} kkal terbakar. Pertahankan konsistensinya!`;
    const prompt = [
      'Kamu adalah personal trainer AI berbahasa Indonesia.',
      'Buat satu paragraf singkat (maks 2 kalimat) memberi selamat user setelah selesai latihan,',
      'sertakan apresiasi spesifik dan satu tips recovery praktis.',
      `Data: latihan "${input.workoutName ?? 'sesi latihan'}", durasi ${input.durationMin} menit,`,
      `kalori terbakar ${input.caloriesBurned}, effort ${input.effortScore ?? '-'}/10,`,
      `goal user: ${input.goal ?? 'MAINTENANCE'}.`,
      'Tanpa emoji, tanpa heading, tanpa list.',
    ].join(' ');
    return generate(prompt, fallback);
  },

  /**
   * Penjelasan singkat kenapa makanan alternatif ini cocok untuk user.
   */
  async enrichMealRecommendation(input: {
    foodName: string;
    calories: number;
    goal?: string | null;
    reason?: string;
  }): Promise<string> {
    const fallback = `${input.foodName} (${input.calories} kkal) cocok untuk goal ${input.goal ?? 'kamu'}.`;
    const prompt = [
      'Kamu adalah ahli gizi AI berbahasa Indonesia.',
      `Jelaskan dalam 1 kalimat singkat kenapa "${input.foodName}" (${input.calories} kkal)`,
      `cocok untuk user dengan goal ${input.goal ?? 'MAINTENANCE'}.`,
      input.reason ? `Konteks tambahan: ${input.reason}.` : '',
      'Tanpa emoji, tanpa heading.',
    ].join(' ');
    return generate(prompt, fallback);
  },

  /**
   * Narrative replan: rangkum hasil 7 hari + arah tindak lanjut.
   */
  async enrichReplanNarrative(input: {
    weeklyScore: number;
    weightDiffKg: number;
    action: string;
    volumeMultiplier: number;
    goal?: string | null;
  }): Promise<string> {
    const sign = input.weightDiffKg > 0 ? '+' : '';
    const fallback =
      `Minggu ini skor kepatuhanmu ${Math.round(input.weeklyScore)}/100 dengan perubahan berat ` +
      `${sign}${input.weightDiffKg.toFixed(1)} kg. Rekomendasi: ${input.action}.`;
    const prompt = [
      'Kamu adalah pelatih kesehatan AI berbahasa Indonesia.',
      'Tulis 2 kalimat: kalimat pertama merangkum performa minggu ini,',
      'kalimat kedua memberi alasan singkat di balik rekomendasi.',
      `Data: weekly_score ${Math.round(input.weeklyScore)}/100,`,
      `perubahan berat ${sign}${input.weightDiffKg.toFixed(1)} kg,`,
      `action ML "${input.action}", volume multiplier ${input.volumeMultiplier.toFixed(2)},`,
      `goal user ${input.goal ?? 'MAINTENANCE'}.`,
      'Tanpa emoji, tanpa heading, tanpa list.',
    ].join(' ');
    return generate(prompt, fallback);
  },

  /**
   * Saran setelah food-scan: keseimbangan + tips makanan pendamping.
   */
  async enrichFoodScanAdvice(input: {
    foods: string[];
    totalCalories: number;
    assessment: string;
    goal?: string | null;
    condition?: string | null;
  }): Promise<string> {
    const foodList = input.foods.join(', ') || 'makanan kamu';
    const fallback =
      `Total ${Math.round(input.totalCalories)} kkal untuk ${foodList}. ` +
      `Kategori: ${input.assessment.toLowerCase()}.`;
    const prompt = [
      'Kamu adalah ahli gizi AI berbahasa Indonesia.',
      'Tulis 2 kalimat: kalimat pertama menilai keseimbangan makanan,',
      'kalimat kedua memberi 1 tips konkret (misal tambah serat / kurangi gula / minum air).',
      `Data: makanan ${foodList}, total ${Math.round(input.totalCalories)} kkal,`,
      `assessment ML "${input.assessment}", goal ${input.goal ?? 'MAINTENANCE'},`,
      `kondisi kesehatan ${input.condition ?? 'tidak ada'}.`,
      'Tanpa emoji, tanpa heading, tanpa list.',
    ].join(' ');
    return generate(prompt, fallback);
  },
};
