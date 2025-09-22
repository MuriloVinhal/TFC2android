// Setup file for Jest tests
process.env.NODE_ENV = 'test';

// Mock console methods in test environment
global.console = {
  ...console,
  log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
};

// Setup database for tests
beforeAll(async () => {
  // Database setup logic here if needed
});

afterAll(async () => {
  // Cleanup logic here if needed
});

beforeEach(() => {
  // Reset mocks before each test
  jest.clearAllMocks();
});