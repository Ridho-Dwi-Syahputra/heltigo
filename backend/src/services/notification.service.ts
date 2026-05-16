import { prisma } from '../config/db';
import { ApiError } from '../utils/api-error';

function toBig(id: string) {
  return BigInt(id);
}

export const notificationService = {
  async listForUser(userId: string, opts: { unreadOnly?: boolean; limit?: number }) {
    const limit = Math.min(opts.limit ?? 30, 100);
    const where: any = { userId: toBig(userId) };
    if (opts.unreadOnly) where.isRead = false;
    const items = await prisma.notification.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
    const unreadCount = await prisma.notification.count({
      where: { userId: toBig(userId), isRead: false },
    });
    return {
      items: items.map((n) => ({
        id: n.id.toString(),
        type: n.type,
        title: n.title,
        body: n.body,
        actionUrl: n.actionUrl,
        isRead: n.isRead,
        readAt: n.readAt,
        createdAt: n.createdAt,
      })),
      unreadCount,
    };
  },

  async markAsRead(userId: string, id: string) {
    const notif = await prisma.notification.findUnique({ where: { id: toBig(id) } });
    if (!notif || notif.userId !== toBig(userId)) {
      throw new ApiError(404, 'NOT_FOUND', 'Notifikasi tidak ditemukan');
    }
    const updated = await prisma.notification.update({
      where: { id: toBig(id) },
      data: { isRead: true, readAt: new Date() },
    });
    return { id: updated.id.toString(), isRead: updated.isRead };
  },

  async markAllAsRead(userId: string) {
    const result = await prisma.notification.updateMany({
      where: { userId: toBig(userId), isRead: false },
      data: { isRead: true, readAt: new Date() },
    });
    return { updatedCount: result.count };
  },

  async registerFcmToken(
    userId: string,
    body: { token: string; platform: 'ANDROID' | 'IOS' | 'WEB' },
  ) {
    if (!body.token || !body.platform) {
      throw new ApiError(400, 'INVALID_INPUT', 'Token dan platform wajib');
    }
    const fcm = await prisma.fcmToken.upsert({
      where: { token: body.token },
      create: { userId: toBig(userId), token: body.token, platform: body.platform },
      update: { userId: toBig(userId), platform: body.platform },
    });
    return { id: fcm.id.toString(), platform: fcm.platform };
  },

  async deleteFcmToken(userId: string, body: { token: string }) {
    if (!body.token) throw new ApiError(400, 'TOKEN_REQUIRED', 'Token wajib');
    await prisma.fcmToken.deleteMany({
      where: { userId: toBig(userId), token: body.token },
    });
    return { deleted: true };
  },
};
