// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i117;
import '../../features/chat/data/datasources/chat_remote_data_source.dart'
    as _i980;
import '../../features/chat/data/repositories/chat_repository_impl.dart'
    as _i504;
import '../../features/chat/domain/repositories/chat_repository.dart' as _i420;
import '../../features/chat/presentation/cubit/chat_cubit.dart' as _i305;
import '../../features/discover/data/datasources/discover_remote_data_source.dart'
    as _i121;
import '../../features/discover/data/repositories/discover_repository_impl.dart'
    as _i76;
import '../../features/discover/domain/repositories/discover_repository.dart'
    as _i302;
import '../../features/discover/presentation/cubit/discover_cubit.dart'
    as _i322;
import '../../features/game/data/datasources/game_remote_data_source.dart'
    as _i783;
import '../../features/game/data/repositories/game_repository_impl.dart'
    as _i33;
import '../../features/game/domain/repositories/game_repository.dart' as _i32;
import '../../features/game/presentation/cubit/game_cubit.dart' as _i192;
import '../../features/room/data/datasources/room_remote_data_source.dart'
    as _i918;
import '../../features/room/data/repositories/room_repository_impl.dart'
    as _i166;
import '../../features/room/domain/repositories/room_repository.dart' as _i855;
import '../../features/room/presentation/cubit/room_cubit.dart' as _i131;
import '../../features/tournament/data/datasources/tournament_remote_data_source.dart'
    as _i636;
import '../../features/tournament/data/repositories/tournament_repository_impl.dart'
    as _i689;
import '../../features/tournament/domain/repositories/tournament_repository.dart'
    as _i107;
import '../../features/tournament/presentation/cubit/tournament_cubit.dart'
    as _i234;
import '../network/cache_helper.dart' as _i681;
import 'third_party_module.dart' as _i811;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final thirdPartyModule = _$ThirdPartyModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => thirdPartyModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i59.FirebaseAuth>(() => thirdPartyModule.auth);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => thirdPartyModule.firestore);
    gh.lazySingleton<_i457.FirebaseStorage>(() => thirdPartyModule.storage);
    gh.lazySingleton<_i980.ChatRemoteDataSource>(
      () => _i980.ChatRemoteDataSource(),
    );
    gh.lazySingleton<_i121.DiscoverRemoteDataSource>(
      () => _i121.DiscoverRemoteDataSource(),
    );
    gh.lazySingleton<_i783.GameRemoteDataSource>(
      () => _i783.GameRemoteDataSource(),
    );
    gh.lazySingleton<_i918.RoomRemoteDataSource>(
      () => _i918.RoomRemoteDataSource(),
    );
    gh.lazySingleton<_i636.TournamentRemoteDataSource>(
      () => _i636.TournamentRemoteDataSource(),
    );
    gh.lazySingleton<_i302.DiscoverRepository>(
      () => _i76.DiscoverRepositoryImpl(
        remoteDataSource: gh<_i121.DiscoverRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i855.RoomRepository>(
      () => _i166.RoomRepositoryImpl(
        remoteDataSource: gh<_i918.RoomRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => _i107.AuthRemoteDataSource(firebaseAuth: gh<_i59.FirebaseAuth>()),
    );
    gh.lazySingleton<_i107.TournamentRepository>(
      () => _i689.TournamentRepositoryImpl(
        remoteDataSource: gh<_i636.TournamentRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        remoteDataSource: gh<_i107.AuthRemoteDataSource>(),
      ),
    );
    gh.singleton<_i681.CacheHelper>(
      () => _i681.CacheHelper(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i420.ChatRepository>(
      () => _i504.ChatRepositoryImpl(
        remoteDataSource: gh<_i980.ChatRemoteDataSource>(),
      ),
    );
    gh.factory<_i117.AuthCubit>(
      () => _i117.AuthCubit(authRepository: gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i32.GameRepository>(
      () => _i33.GameRepositoryImpl(
        remoteDataSource: gh<_i783.GameRemoteDataSource>(),
      ),
    );
    gh.factory<_i322.DiscoverCubit>(
      () => _i322.DiscoverCubit(
        discoverRepository: gh<_i302.DiscoverRepository>(),
      ),
    );
    gh.factory<_i131.RoomCubit>(
      () => _i131.RoomCubit(roomRepository: gh<_i855.RoomRepository>()),
    );
    gh.factory<_i234.TournamentCubit>(
      () => _i234.TournamentCubit(
        tournamentRepository: gh<_i107.TournamentRepository>(),
      ),
    );
    gh.factory<_i192.GameCubit>(
      () => _i192.GameCubit(gameRepository: gh<_i32.GameRepository>()),
    );
    gh.factory<_i305.ChatCubit>(
      () => _i305.ChatCubit(chatRepository: gh<_i420.ChatRepository>()),
    );
    return this;
  }
}

class _$ThirdPartyModule extends _i811.ThirdPartyModule {}
