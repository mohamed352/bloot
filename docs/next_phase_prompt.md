# Phase L Prompt: Chat List Firestore Integration

> **For:** New conversation continuation  
> **Previous phases completed:** A–K (Profile fully wired, Settings wired, Notifications wired)  
> **Next:** Wire Chat List to Firestore `conversations` collection

---

## 1. Scope (Medium — ~200 lines)

Replace the hardcoded mock conversation list in `ChatRemoteDataSource.getConversations()` with a real Firestore query. Keep message sending/loading mocked for now (Phase M). The chat list page UI already exists and works with `ChatConversation` entities — we only need to make the data layer real.

**What stays mocked:**
- `getMessages(String conversationId)` — keep existing hardcoded messages
- `sendMessage(...)` — keep existing mock append logic

**What becomes real:**
- `getConversations()` — Firestore query on `conversations` collection

---

## 2. Current State of Relevant Files

### `lib/features/chat/domain/entities/chat.dart`
Already defines:
```dart
class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
    required this.type,
  });
  final String id;
  final String name;
  final String? avatarUrl;
  final String lastMessage;
  final String time;
  final int unread;
  final String type;
}
```

### `lib/features/chat/data/models/chat_model.dart`
Already has `ChatConversationModel` (Freezed) with `toEntity()` extension.

### `lib/features/chat/data/datasources/chat_remote_data_source.dart`
Currently returns 5 hardcoded `ChatConversationModel` items with 300ms delay. No Firestore import.

### `lib/features/chat/data/repositories/chat_repository_impl.dart`
Simply delegates to remote data source and maps `toEntity()`.

### `lib/features/chat/presentation/cubit/chat_cubit.dart`
Has `loadConversations()` → emits `loading` → repo → `conversationsLoaded`.

### `lib/features/chat/presentation/cubit/chat_state.dart`
```dart
const factory ChatState.conversationsLoaded({
  required List<ChatConversation> conversations,
  @Default(0) int selectedFilterIndex,
}) = ChatConversationsLoaded;
```

### `lib/features/chat/presentation/pages/chat_list_page.dart`
Uses `BlocConsumer<ChatCubit, ChatState>`. Reads `state is ChatConversationsLoaded ? state.conversations : []`. Renders `_ChatListItem` for each. **Note:** The `selectFilter` cubit method exists but the page does NOT actually filter the list by type — it just highlights the chip. Leave this as-is for now.

### Routing (`lib/config/routes/app_router.dart`)
```dart
GoRoute(
  path: RoutePaths.chat,
  name: RouteNames.chat,
  builder: (context, state) => BlocProvider(
    create: (_) => getIt<ChatCubit>()..loadConversations(),
    child: const ChatListPage(),
  ),
),
```

---

## 3. Firestore Schema Assumption

Create documents in a `conversations` collection with this shape:

```dart
{
  'name': 'Khalid Al-Rashid',
  'avatarUrl': 'https://i.pravatar.cc/150?img=12',
  'lastMessage': 'good_game_yesterday',
  'lastMessageAt': Timestamp,
  'unread': 2,
  'type': 'direct',       // 'direct' | 'rooms'
  'participantIds': ['uid1', 'uid2'],
}
```

**Important:** The existing UI expects `time` as a **String** (e.g., `'2m'`, `'15m'`, `'1h'`). Since Firestore stores `lastMessageAt` as a Timestamp, the model must format it to a relative string in the data source mapping.

---

## 4. Step-by-Step Implementation

### Step 1: Update `ChatConversationModel` (if needed)
The current model already has all fields. No changes needed unless you want to add `participantIds` — but that's not used in the UI yet, so skip it.

### Step 2: Rewrite `ChatRemoteDataSource`

**File:** `lib/features/chat/data/datasources/chat_remote_data_source.dart`

Changes:
1. Add `FirebaseFirestore` and `firebase_auth` imports
2. Add constructor injection for Firestore and FirebaseAuth
3. Replace `getConversations()` body:
   - Query `_firestore.collection('conversations')`
   - Filter where `'participantIds'` array contains current user UID
   - Order by `'lastMessageAt'` descending
   - Limit 50
   - Map each doc to `ChatConversationModel`
   - Format `lastMessageAt` → relative time string (`'2m'`, `'1h'`, `'1d'`)
   - If Firestore returns empty or errors, fall back to the existing 5 hardcoded conversations
4. Keep `getMessages()` and `sendMessage()` exactly as they are

**Relative time formatter helper:**
```dart
String _formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return '${dateTime.day}/${dateTime.month}';
}
```

### Step 3: Update DI registration
The data source currently has no constructor parameters. After adding Firestore/Auth injection, you MUST regenerate `injection.config.dart`.

### Step 4: Verify no other files need changes
- `ChatRepository` interface — no changes needed
- `ChatRepositoryImpl` — no changes needed
- `ChatCubit` — no changes needed
- `ChatState` — no changes needed
- `ChatListPage` — no changes needed (it already renders `ChatConversation` entities correctly)

---

## 5. Code Pattern to Follow

Use the exact same pattern as `NotificationsRemoteDataSource` (Phase H):

```dart
@lazySingleton
class ChatRemoteDataSource {
  ChatRemoteDataSource({
    required FirebaseFirestore firestore,
    required firebase_auth.FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  Future<List<ChatConversationModel>> getConversations() async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) return _mockConversations;

      final snapshot = await _firestore
          .collection('conversations')
          .where('participantIds', arrayContains: uid)
          .orderBy('lastMessageAt', descending: true)
          .limit(50)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map(_mapDocToModel).toList();
      }
    } catch (e) {
      AppLogger.error('Failed to fetch conversations', error: e);
    }

    return _mockConversations;
  }

  ChatConversationModel _mapDocToModel(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final lastMessageAt = data['lastMessageAt'];

    return ChatConversationModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String?,
      lastMessage: data['lastMessage'] as String? ?? '',
      time: lastMessageAt is Timestamp
          ? _formatRelativeTime(lastMessageAt.toDate())
          : '',
      unread: (data['unread'] as num?)?.toInt() ?? 0,
      type: data['type'] as String? ?? 'direct',
    );
  }

  String _formatRelativeTime(DateTime dateTime) { ... }

  // Keep existing _mockConversations, getMessages, sendMessage
}
```

---

## 6. Localization Notes

The `chat_list_page.dart` uses `.tr()` for:
- `'messages'` — title
- `'all'`, `'rooms'`, `'direct'` — filter chips

The `lastMessage` field from Firestore should store **localization keys** (e.g., `'good_game_yesterday'`) so that `.tr()` works in the UI. OR store raw text and skip `.tr()` for lastMessage. The current UI does NOT call `.tr()` on `lastMessage` — it displays it as-is. So storing raw text in Firestore is fine.

---

## 7. Verification Steps

```bash
# After modifying ChatRemoteDataSource constructor
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze
flutter analyze --no-pub

# Test
flutter test --no-pub

# Manual: Open Chat tab → conversation list should load (mock fallback if Firestore empty)
```

---

## 8. Common Pitfalls

1. **Firestore index required:** The query `.where('participantIds', arrayContains: uid).orderBy('lastMessageAt', descending: true)` requires a composite index in Firestore. If you get an index error during testing, create it via the Firebase Console link in the error message.
2. **Missing `firebase_auth` import:** Use `firebase_auth.FirebaseAuth` (aliased) to avoid conflicts with the `FirebaseAuth` from `cloud_firestore`.
3. **Time field type mismatch:** The UI expects `time` as a `String`. Do NOT change the model to `DateTime` — format it in the data source mapper.
4. **Unused import of `cloud_firestore` in model files:** The `chat_model.dart` does NOT need `cloud_firestore` import. Only the data source needs it.

---

## 9. Deferred to Phase M (Chat Messages)

- `getMessages()` — real Firestore `conversations/{id}/messages` subcollection query
- `sendMessage()` — write to Firestore + optimistic UI update
- Real-time message streaming via Firestore snapshots
- `DirectMessagePage` AppBar — wire to real user profile instead of hardcoded name/avatar
