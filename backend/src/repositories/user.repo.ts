import { Prisma } from '@prisma/client';
import { prisma } from '../config/db';

export const userRepo = {
  async findByEmail(email: string) {
    return prisma.user.findUnique({ where: { email } });
  },

  async findById(id: string) {
    return prisma.user.findUnique({ where: { id: BigInt(id) } });
  },

  async findByIdWithProfile(id: string) {
    return prisma.user.findUnique({
      where: { id: BigInt(id) },
      include: { healthProfile: true, settings: true },
    });
  },

  async create(data: { email: string; passwordHash: string; name?: string }) {
    return prisma.user.create({
      data: {
        email: data.email,
        passwordHash: data.passwordHash,
        name: data.name || 'User',
      },
    });
  },

  async update(id: string, data: Prisma.UserUpdateInput) {
    return prisma.user.update({ where: { id: BigInt(id) }, data });
  },

  async updateLastLogin(id: string) {
    return prisma.user.update({
      where: { id: BigInt(id) },
      data: { lastLoginAt: new Date() },
    });
  },

  async softDelete(id: string) {
    return prisma.user.update({
      where: { id: BigInt(id) },
      data: { deletedAt: new Date() },
    });
  },
};
