const { hashPassword, verifyPassword } = require('../../src/utils/password');

describe('Password Utils Tests', () => {
  describe('hashPassword', () => {
    test('should hash password successfully', async () => {
      const password = 'testpassword123';
      const hashedPassword = await hashPassword(password);

      expect(hashedPassword).toBeDefined();
      expect(hashedPassword).not.toBe(password);
      expect(hashedPassword.length).toBeGreaterThan(50);
    });

    test('should generate different hashes for same password', async () => {
      const password = 'testpassword123';
      const hash1 = await hashPassword(password);
      const hash2 = await hashPassword(password);

      expect(hash1).not.toBe(hash2);
    });
  });

  describe('verifyPassword', () => {
    test('should verify correct password', async () => {
      const password = 'testpassword123';
      const hashedPassword = await hashPassword(password);
      const isValid = await verifyPassword(password, hashedPassword);

      expect(isValid).toBe(true);
    });

    test('should reject incorrect password', async () => {
      const password = 'testpassword123';
      const wrongPassword = 'wrongpassword';
      const hashedPassword = await hashPassword(password);
      const isValid = await verifyPassword(wrongPassword, hashedPassword);

      expect(isValid).toBe(false);
    });

    test('should handle empty passwords', async () => {
      const password = '';
      const hashedPassword = await hashPassword(password);
      const isValid = await verifyPassword(password, hashedPassword);

      expect(isValid).toBe(true);
    });
  });
});