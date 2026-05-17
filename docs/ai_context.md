# Bloot — AI Context & Skills

> **Purpose:** Rules, constraints, and context that any AI agent coding in this project must follow. Referenced by AGENTS.md and consumed by coding assistants.

---

## 1. Architecture Overview

Bloot uses **Feature-First Clean Architecture** with Flutter.

```
lib/
├── app/                    # App-level: MaterialApp, router, theme
├── core/                   # Shared: constants, extensions, services, utils
├── features/               # Feature modules (domain → data → presentation)
│   ├── auth/
│   ├── home/
│   ├── discover/
│   ├── rooms/
│   ├── game/
│   ├── stream/
│   ├── tournaments/
│   ├── chat/
│   ├── profile/
│   └── settings/
├── shared/                 # Shared widgets, models, l10n
└── main.dart
```

### Layer Dependency Rule

```
Presentation → Domain ← Data
     │              │        │
     └──→ Cubit ←───┘        │
            │                │
            └──→ Repository ─┘
```

- **Domain** contains entities, repository interfaces, and use cases. It has ZERO external dependencies.
- **Data** contains repository implementations, data sources (Firestore, Agora), and models (with freezed).
- **Presentation** contains Cubits, pages, and widgets. It depends on Domain only through repository interfaces.

### State Management

- `flutter_bloc` / `Cubit` for all state management
- `freezed` for immutable data models and union types
- `equatable` for value comparison in Cubit states (or rely on freezed)

### Navigation

- `go_router` with named routes
- Route structure mirrors feature folders
- Deep link support for room invitations

---

## 2. Non-Negotiable Code Rules

These rules are **absolute**. Violating them requires explicit approval from the project lead.

### 2.1 No `print()` Statements

```dart
// NEVER
print('User logged in: $userId');

// USE INSTEAD
// Configure a proper logger (e.g., logger package)
logger.i('User logged in: $userId');

// Or use debugPrint during development only
debugPrint('User logged in: $userId');
```

### 2.2 No Hardcoded Strings

```dart
// NEVER
Text('Play Baloot')

// USE INSTEAD
Text(context.l10n.playBaloot)
```

All user-visible strings must go through `l10n` (AppLocalizations). Generated ARB files live in `lib/shared/l10n/`.

### 2.3 EdgeInsetsDirectional Only

```dart
// NEVER
padding: EdgeInsets.only(left: 16, right: 16),

// USE INSTEAD
padding: EdgeInsetsDirectional.only(start: 16, end: 16),
```

All padding and margin must use `EdgeInsetsDirectional` to support RTL. The same applies to alignment: use `AlignmentDirectional` instead of `Alignment`.

### 2.4 ColorManager Only

```dart
// NEVER
color: Color(0xFF8B5CF6),

// USE INSTEAD
color: ColorManager.purple,
```

All color references must go through `ColorManager` — a static class defined in `lib/app/theme.dart` that maps every design token to a named constant.

### 2.5 Dark-Only Theme

```dart
// NEVER
themeMode: ThemeMode.system,

// USE INSTEAD
themeMode: ThemeMode.dark,
```

No light theme toggle. No `ThemeMode.system`. The app is dark-only for MVP.

### 2.6 No Business Logic in Widgets

```dart
// NEVER inside a widget build method
final canStart = players.where((p) => p.isReady).length == 4;
if (canStart) { ... }

// USE INSTEAD — move to Cubit
// In room_cubit.dart:
bool get canStartGame => state.players.where((p) => p.isReady).length == 4;
```

Widgets are for rendering. All logic lives in Cubits or use cases.

### 2.7 Repository Pattern

```dart
// NEVER call Firestore directly from a Cubit
FirebaseFirestore.instance.collection('rooms').snapshots();

// USE INSTEAD — through a repository
final rooms = await roomRepository.getRooms();
```

Data layer access is always through repository interfaces defined in the domain layer.

### 2.8 Immutable Models

```dart
// NEVER mutable models
class User {
  String name;
  int level;
}

// USE INSTEAD — freezed models
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required int level,
  }) = _User;
}
```

All data models use `freezed` for immutability, `copyWith`, and union types.

### 2.9 Error Handling

```dart
// NEVER swallow exceptions silently
try { ... } catch (e) { }

// USE INSTEAD — meaningful error states
try {
  final result = await repository.joinRoom(roomId);
  emit(RoomJoined(result));
} on NetworkException {
  emit(RoomError('Network error. Please check your connection.'));
} on RoomFullException {
  emit(RoomError('Room is full. Try another room.'));
}
```

Every Cubit that performs async work must have a failure state with a user-friendly message.

### 2.10 No Direct Navigation in Cubits

```dart
// NEVER
class AuthCubit extends Cubit<AuthState> {
  void login() {
    // ...
    Navigator.of(context).pushNamed('/home'); // WRONG
  }
}

// USE INSTEAD — emit navigation events and handle in UI
class AuthCubit extends Cubit<AuthState> {
  void login() async {
    emit(AuthLoading());
    final result = await authRepository.login(phone: phone);
    if (result.isSuccess) {
      emit(AuthSuccess(user: result.user));
    }
  }
}

// In the widget:
BlocListener<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is AuthSuccess) {
      context.go('/home');
    }
  },
)
```

---

## 3. Key Documentation References

| File | Purpose |
|------|---------|
| `docs/AGENTS.md` | Quick-reference project overview |
| `docs/DESIGN.md` | Master design system (tokens, components, rules) |
| `docs/ai_context.md` | This file — code rules and architecture |
| `docs/ai_project_context.md` | Detailed folder structure, state patterns, data layer |
| `docs/firebase_schema.md` | Complete Firestore schema |
| `docs/implementation_plan.md` | Phase-by-phase implementation plan |
| `docs/master_flow_map.md` | All screens and navigation flows |
| `docs/coderules/` | Detailed code rules by category |
| `ai_prompts/00_master_rules.md` | UI generation constitution |
| `ai_prompts/_BUILD_SEQUENCE.md` | UI build order |

---

## 4. Development Workflow Per Feature

When implementing a new feature, follow this order:

### 4.1 Domain Layer

1. **Define the entity** in `features/{feature}/domain/entities/`
   ```dart
   // e.g., features/rooms/domain/entities/room.dart
   class Room {
     final String id;
     final String name;
     final RoomType type;
     final List<String> playerIds;
     // ...
   }
   ```

2. **Define the repository interface** in `features/{feature}/domain/repositories/`
   ```dart
   abstract class RoomRepository {
     Future<List<Room>> getRooms();
     Stream<List<Room>> watchRooms();
     Future<Room> createRoom(RoomParams params);
     Future<void> joinRoom(String roomId, String userId);
     Future<void> leaveRoom(String roomId, String userId);
   }
   ```

3. **Define use cases** (optional, for complex logic) in `features/{feature}/domain/use_cases/`
   ```dart
   class JoinRoomUseCase {
     final RoomRepository repository;
     JoinRoomUseCase(this.repository);
     Future<Result<Room>> call(String roomId, String userId) async {
       // validation, business rules
       return repository.joinRoom(roomId, userId);
     }
   }
   ```

### 4.2 Data Layer

1. **Define the model** (with freezed) in `features/{feature}/data/models/`
   ```dart
   @freezed
   class RoomModel with _$RoomModel {
     const factory RoomModel({
       required String id,
       required String name,
       required String type,
       required List<String> playerIds,
       // ...
     }) = _RoomModel;

     factory RoomModel.fromJson(Map<String, dynamic> json) => _$RoomModelFromJson(json);
   }
   ```

2. **Define the data source** in `features/{feature}/data/datasources/`
   ```dart
   class RoomRemoteDataSource {
     final FirebaseFirestore _firestore;
     Stream<List<RoomModel>> watchRooms() { ... }
     Future<void> createRoom(Map<String, dynamic> data) { ... }
   }
   ```

3. **Implement the repository** in `features/{feature}/data/repositories/`
   ```dart
   class RoomRepositoryImpl implements RoomRepository {
     final RoomRemoteDataSource _remoteDataSource;
     // Map between models and entities
   }
   ```

### 4.3 Presentation Layer

1. **Define states** (with freezed) in `features/{feature}/presentation/cubit/`
   ```dart
   @freezed
   class RoomState with _$RoomState {
     const factory RoomState.initial() = RoomInitial;
     const factory RoomState.loading() = RoomLoading;
     const factory RoomState.loaded({required List<Room> rooms}) = RoomLoaded;
     const factory RoomState.error({required String message}) = RoomError;
   }
   ```

2. **Define the Cubit** in `features/{feature}/presentation/cubit/`
   ```dart
   class RoomCubit extends Cubit<RoomState> {
     final RoomRepository _repository;
     RoomCubit(this._repository) : super(const RoomState.initial());

     Future<void> loadRooms() async { ... }
     Future<void> createRoom(RoomParams params) async { ... }
   }
   ```

3. **Build the page** in `features/{feature}/presentation/pages/`
   ```dart
   class RoomPage extends StatelessWidget {
     // BlocProvider + BlocBuilder/Consumer/Listener
   }
   ```

4. **Build reusable widgets** in `features/{feature}/presentation/widgets/`
   ```dart
   class PlayerVideoSquare extends StatelessWidget { ... }
   class StreamCard extends StatelessWidget { ... }
   ```

### 4.4 Register Dependencies

- Register repositories in `injection_container.dart` (using `get_it` or manual DI)
- Register Cubits with `BlocProvider` at the page level
- Add route in `app/router.dart`

---

## 5. Linting & Quality

Run these commands before every commit:

```bash
flutter analyze           # Static analysis
dart format . --set-exit-if-changed   # Format check
flutter test              # Run all tests
```

Common lint rules enforced in `analysis_options.yaml`:
- `always_use_package_imports`
- `avoid_print`
- `prefer_const_constructors`
- `prefer_const_declarations`
- `require_trailing_commas`
- `use_key_in_widget_constructors`
- `sized_box_for_whitespace`
- `avoid_unnecessary_containers`