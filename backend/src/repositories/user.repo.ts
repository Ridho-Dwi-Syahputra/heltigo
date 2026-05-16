import { prisma } from '../config/db';

export const userRepo = {
  async findByEmail(email: string) {
    return prisma.user.findUnique({
      where: { email },
    });
  },
  
  async findById(id: string) {
    return prisma.user.findUnique({
      where: { id: BigInt(id) },
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
  }
};
