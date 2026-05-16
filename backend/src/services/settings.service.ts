import { Prisma } from '@prisma/client';
import { prisma } from '../config/db';

function toBig(id: string) {
  return BigInt(id);
}

function serializeSetting(s: any) {
  return {
    id: s.id.toString(),
    theme: s.theme,
    language: s.language,
    timezone: s.timezone,
    notificationsEnabled: s.notificationsEnabled,
    dailyReminderTime: s.dailyReminderTime,
    workoutReminderTime: s.workoutReminderTime,
    mealReminderTime: s.mealReminderTime,
    updatedAt: s.updatedAt,
  };
}

export const settingsService = {
  async getSettings(userId: string) {
    let setting = await prisma.setting.findUnique({ where: { userId: toBig(userId) } });
    if (!setting) {
      setting = await prisma.setting.create({ data: { userId: toBig(userId) } });
    }
    return { settings: serializeSetting(setting) };
  },

  async updateSettings(
    userId: string,
    body: {
      theme?: 'LIGHT' | 'DARK' | 'SYSTEM';
      language?: 'id' | 'en';
      timezone?: string;
      notificationsEnabled?: boolean;
      dailyReminderTime?: string | null;
      workoutReminderTime?: string | null;
      mealReminderTime?: string | null;
    },
  ) {
    const data: Prisma.SettingUpdateInput = {};
    if (body.theme !== undefined) data.theme = body.theme;
    if (body.language !== undefined) data.language = body.language;
    if (body.timezone !== undefined) data.timezone = body.timezone;
    if (body.notificationsEnabled !== undefined) data.notificationsEnabled = body.notificationsEnabled;
    if (body.dailyReminderTime !== undefined) {
      data.dailyReminderTime = body.dailyReminderTime ? new Date(`1970-01-01T${body.dailyReminderTime}Z`) : null;
    }
    if (body.workoutReminderTime !== undefined) {
      data.workoutReminderTime = body.workoutReminderTime ? new Date(`1970-01-01T${body.workoutReminderTime}Z`) : null;
    }
    if (body.mealReminderTime !== undefined) {
      data.mealReminderTime = body.mealReminderTime ? new Date(`1970-01-01T${body.mealReminderTime}Z`) : null;
    }
    const setting = await prisma.setting.upsert({
      where: { userId: toBig(userId) },
      update: data,
      create: {
        userId: toBig(userId),
        theme: body.theme ?? 'DARK',
        language: body.language ?? 'id',
        timezone: body.timezone ?? 'Asia/Jakarta',
        notificationsEnabled: body.notificationsEnabled ?? true,
      },
    });
    return { settings: serializeSetting(setting) };
  },
};
