const mockSendMulticast = jest.fn();
const mockUpdate = jest.fn();
const mockGet = jest.fn();
const mockTokensGet = jest.fn();
const mockTokenDelete = jest.fn();
const mockDeleteField = jest.fn(() => '__delete__');

jest.mock('firebase-admin', () => ({
  messaging: () => ({ sendEachForMulticast: mockSendMulticast }),
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
        collection: () => ({
          get: mockTokensGet,
          doc: () => ({ delete: mockTokenDelete }),
        }),
      }),
    }),
  },
}));

import {
  getUserFcmTokens,
  sendFcmToUser,
  sendFcmToUserDevices,
  sendFcmToUsers,
} from './messaging';

function tokenDocs(tokens: string[]) {
  return { docs: tokens.map((t) => ({ id: t, data: () => ({ token: t }) })) };
}

describe('getUserFcmTokens', () => {
  beforeEach(() => jest.clearAllMocks());

  it('combines legacy token and subcollection tokens, deduped', async () => {
    mockGet.mockResolvedValue({
      exists: true,
      data: () => ({ fcmToken: 'legacy' }),
    });
    mockTokensGet.mockResolvedValue(tokenDocs(['legacy', 'android', 'ios']));

    const tokens = await getUserFcmTokens('uid1');
    expect(tokens.sort()).toEqual(['android', 'ios', 'legacy']);
  });

  it('returns empty array when user has no tokens', async () => {
    mockGet.mockResolvedValue({ exists: true, data: () => ({}) });
    mockTokensGet.mockResolvedValue(tokenDocs([]));

    const tokens = await getUserFcmTokens('uid1');
    expect(tokens).toEqual([]);
  });
});

describe('sendFcmToUser', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockTokensGet.mockResolvedValue(tokenDocs([]));
    mockTokenDelete.mockResolvedValue(undefined);
    mockUpdate.mockResolvedValue({});
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

  it('sends FCM to all device tokens and returns success', async () => {
    mockGet.mockResolvedValue({
      exists: true,
      data: () => ({ fcmToken: 'legacy', settings: {} }),
    });
    mockTokensGet.mockResolvedValue(tokenDocs(['ios-token']));
    mockSendMulticast.mockResolvedValue({
      successCount: 2,
      responses: [{ success: true }, { success: true }],
    });

    const result = await sendFcmToUser('uid1', { notification: { title: 'Test', body: 'Body' } });
    expect(result.success).toBe(true);
    expect(mockSendMulticast).toHaveBeenCalledWith(
      expect.objectContaining({
        tokens: expect.arrayContaining(['legacy', 'ios-token']),
        notification: { title: 'Test', body: 'Body' },
      }),
    );
  });

  it('prunes dead tokens on registration errors', async () => {
    mockGet.mockResolvedValue({
      exists: true,
      data: () => ({ fcmToken: 'dead', settings: {} }),
    });
    mockTokensGet.mockResolvedValue(tokenDocs([]));
    mockSendMulticast.mockResolvedValue({
      successCount: 0,
      responses: [
        {
          success: false,
          error: {
            message: 'not registered',
            errorInfo: { code: 'messaging/registration-token-not-registered' },
          },
        },
      ],
    });

    const result = await sendFcmToUser('uid1', { notification: { title: 'Test', body: 'Body' } });
    expect(result.success).toBe(false);
    // Legacy field cleared (user doc re-read shows the same dead token).
    expect(mockUpdate).toHaveBeenCalledWith({ fcmToken: '__delete__' });
  });
});

describe('sendFcmToUserDevices', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockTokensGet.mockResolvedValue(tokenDocs([]));
  });

  it('succeeds when at least one device receives the message', async () => {
    mockGet.mockResolvedValue({ exists: true, data: () => ({}) });
    mockTokensGet.mockResolvedValue(tokenDocs(['t1', 't2']));
    mockSendMulticast.mockResolvedValue({
      successCount: 1,
      responses: [
        { success: true },
        { success: false, error: { message: 'other', errorInfo: { code: 'messaging/internal-error' } } },
      ],
    });

    const result = await sendFcmToUserDevices('uid1', { notification: { title: 'Hi' } });
    expect(result.success).toBe(true);
    // Non-registration errors do NOT prune the token.
    expect(mockTokenDelete).not.toHaveBeenCalled();
  });
});

describe('sendFcmToUsers', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockTokensGet.mockResolvedValue(tokenDocs([]));
  });

  it('sends to all users with concurrency limit', async () => {
    mockGet
      .mockResolvedValueOnce({ exists: true, data: () => ({ fcmToken: 'token1', settings: {} }) })
      .mockResolvedValueOnce({ exists: true, data: () => ({ fcmToken: 'token2', settings: {} }) });
    mockSendMulticast.mockResolvedValue({
      successCount: 1,
      responses: [{ success: true }],
    });

    const results = await sendFcmToUsers(['u1', 'u2'], { notification: { title: 'Test', body: 'Body' } }, 1);
    expect(results.get('u1')?.success).toBe(true);
    expect(results.get('u2')?.success).toBe(true);
    expect(mockSendMulticast).toHaveBeenCalledTimes(2);
  });
});
