const mockSend = jest.fn();
const mockUpdate = jest.fn();
const mockGet = jest.fn();
const mockDeleteField = jest.fn(() => '__delete__');

jest.mock('firebase-admin', () => ({
  messaging: () => ({ send: mockSend }),
  firestore: {
    FieldValue: { delete: mockDeleteField },
    Timestamp: { now: () => ({ toDate: () => new Date() }) },
  },
}));

jest.mock('../config/admin', () => ({
  db: {
    collection: () => ({
      doc: () => ({
        get: mockGet,
        update: mockUpdate,
      }),
    }),
  },
}));

import { sendFcmToUser, sendFcmToUsers } from './messaging';

describe('sendFcmToUser', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('returns error when user is not found', async () => {
    mockGet.mockResolvedValue({ exists: false });
    const result = await sendFcmToUser('uid1', { notification: { title: 'Test', body: 'Body' } });
    expect(result.success).toBe(false);
    expect(result.error).toBe('User not found');
  });

  it('returns error when user has no FCM token', async () => {
    mockGet.mockResolvedValue({ exists: true, data: () => ({}) });
    const result = await sendFcmToUser('uid1', { notification: { title: 'Test', body: 'Body' } });
    expect(result.success).toBe(false);
    expect(result.error).toBe('No FCM token');
  });

  it('returns error when user disabled system notifications', async () => {
    mockGet.mockResolvedValue({
      exists: true,
      data: () => ({ fcmToken: 'token', settings: { notifications: { system: false } } }),
    });
    const result = await sendFcmToUser('uid1', { notification: { title: 'Test', body: 'Body' } });
    expect(result.success).toBe(false);
    expect(result.error).toBe('User disabled system notifications');
  });

  it('sends FCM and returns success', async () => {
    mockGet.mockResolvedValue({
      exists: true,
      data: () => ({ fcmToken: 'token', settings: {} }),
    });
    mockSend.mockResolvedValue('message-id');

    const result = await sendFcmToUser('uid1', { notification: { title: 'Test', body: 'Body' } });
    expect(result.success).toBe(true);
    expect(mockSend).toHaveBeenCalledWith(
      expect.objectContaining({
        token: 'token',
        notification: { title: 'Test', body: 'Body' },
      }),
    );
  });

  it('clears invalid token on registration error', async () => {
    mockGet.mockResolvedValue({
      exists: true,
      data: () => ({ fcmToken: 'token', settings: {} }),
    });
    mockSend.mockRejectedValue({ errorInfo: { code: 'messaging/invalid-registration-token' } });

    const result = await sendFcmToUser('uid1', { notification: { title: 'Test', body: 'Body' } });
    expect(result.success).toBe(false);
    expect(mockUpdate).toHaveBeenCalledWith({ fcmToken: '__delete__' });
  });
});

describe('sendFcmToUsers', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('sends to all users with concurrency limit', async () => {
    mockGet
      .mockResolvedValueOnce({ exists: true, data: () => ({ fcmToken: 'token1', settings: {} }) })
      .mockResolvedValueOnce({ exists: true, data: () => ({ fcmToken: 'token2', settings: {} }) });
    mockSend.mockResolvedValue('message-id');

    const results = await sendFcmToUsers(['u1', 'u2'], { notification: { title: 'Test', body: 'Body' } }, 1);
    expect(results.get('u1')?.success).toBe(true);
    expect(results.get('u2')?.success).toBe(true);
    expect(mockSend).toHaveBeenCalledTimes(2);
  });
});
