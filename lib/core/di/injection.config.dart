// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:app_links/app_links.dart' as _i327;
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:cloud_functions/cloud_functions.dart' as _i809;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_crashlytics/firebase_crashlytics.dart' as _i141;
import 'package:firebase_database/firebase_database.dart' as _i345;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:firebase_performance/firebase_performance.dart' as _i346;
import 'package:firebase_remote_config/firebase_remote_config.dart' as _i627;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:package_info_plus/package_info_plus.dart' as _i655;
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
import '../../features/chat/presentation/cubit/new_message_cubit.dart' as _i22;
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
import '../../features/home/data/datasources/home_remote_data_source.dart'
    as _i362;
import '../../features/home/data/repositories/home_repository_impl.dart'
    as _i76;
import '../../features/home/domain/repositories/home_repository.dart' as _i0;
import '../../features/home/presentation/cubit/home_cubit.dart' as _i9;
import '../../features/moderation/data/datasources/moderation_remote_data_source.dart'
    as _i200;
import '../../features/moderation/data/repositories/moderation_repository_impl.dart'
    as _i378;
import '../../features/moderation/domain/repositories/moderation_repository.dart'
    as _i106;
import '../../features/moderation/presentation/cubit/blocked_users_cubit.dart'
    as _i793;
import '../../features/notifications/data/datasources/notifications_remote_data_source.dart'
    as _i951;
import '../../features/notifications/data/repositories/notifications_repository_impl.dart'
    as _i201;
import '../../features/notifications/domain/repositories/notifications_repository.dart'
    as _i563;
import '../../features/notifications/presentation/cubit/notifications_cubit.dart'
    as _i405;
import '../../features/profile/data/datasources/profile_remote_data_source.dart'
    as _i847;
import '../../features/profile/data/repositories/profile_repository_impl.dart'
    as _i334;
import '../../features/profile/domain/repositories/profile_repository.dart'
    as _i894;
import '../../features/profile/presentation/cubit/edit_profile_cubit.dart'
    as _i990;
import '../../features/profile/presentation/cubit/profile_cubit.dart' as _i36;
import '../../features/room/data/datasources/room_remote_data_source.dart'
    as _i918;
import '../../features/room/data/repositories/room_repository_impl.dart'
    as _i166;
import '../../features/room/domain/repositories/room_repository.dart' as _i855;
import '../../features/room/presentation/cubit/room_cubit.dart' as _i131;
import '../../features/settings/data/repositories/settings_repository_impl.dart'
    as _i955;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i674;
import '../../features/settings/presentation/cubit/settings_cubit.dart'
    as _i792;
import '../network/cache_helper.dart' as _i681;
import '../services/agora_service.dart' as _i890;
import '../services/audio_service.dart' as _i15;
import '../services/deep_link_service.dart' as _i391;
import '../services/notification_service.dart' as _i941;
import '../services/presence_service.dart' as _i219;
import '../services/remote_config_service.dart' as _i858;
import '../services/stream_heartbeat_service.dart' as _i19;
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
    await gh.factoryAsync<_i655.PackageInfo>(
      () => thirdPartyModule.packageInfo,
      preResolve: true,
    );
    gh.lazySingleton<_i59.FirebaseAuth>(() => thirdPartyModule.auth);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => thirdPartyModule.firestore);
    gh.lazySingleton<_i345.FirebaseDatabase>(() => thirdPartyModule.database);
    gh.lazySingleton<_i457.FirebaseStorage>(() => thirdPartyModule.storage);
    gh.lazySingleton<_i809.FirebaseFunctions>(() => thirdPartyModule.functions);
    gh.lazySingleton<_i892.FirebaseMessaging>(() => thirdPartyModule.messaging);
    gh.lazySingleton<_i627.FirebaseRemoteConfig>(
      () => thirdPartyModule.remoteConfig,
    );
    gh.lazySingleton<_i141.FirebaseCrashlytics>(
      () => thirdPartyModule.crashlytics,
    );
    gh.lazySingleton<_i346.FirebasePerformance>(
      () => thirdPartyModule.performance,
    );
    gh.lazySingleton<_i327.AppLinks>(() => thirdPartyModule.appLinks);
    gh.lazySingleton<_i15.AudioService>(
      () => _i15.AudioService(prefs: gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i200.ModerationRemoteDataSource>(
      () => _i200.ModerationRemoteDataSource(
        firestore: gh<_i974.FirebaseFirestore>(),
        firebaseAuth: gh<_i59.FirebaseAuth>(),
        functions: gh<_i809.FirebaseFunctions>(),
      ),
    );
    gh.lazySingleton<_i918.RoomRemoteDataSource>(
      () => _i918.RoomRemoteDataSource(
        firestore: gh<_i974.FirebaseFirestore>(),
        firebaseAuth: gh<_i59.FirebaseAuth>(),
        functions: gh<_i809.FirebaseFunctions>(),
      ),
    );
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => _i107.AuthRemoteDataSource(
        firebaseAuth: gh<_i59.FirebaseAuth>(),
        firestore: gh<_i974.FirebaseFirestore>(),
        functions: gh<_i809.FirebaseFunctions>(),
        storage: gh<_i457.FirebaseStorage>(),
      ),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        remoteDataSource: gh<_i107.AuthRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i847.ProfileRemoteDataSource>(
      () => _i847.ProfileRemoteDataSource(
        firestore: gh<_i974.FirebaseFirestore>(),
        firebaseAuth: gh<_i59.FirebaseAuth>(),
        storage: gh<_i457.FirebaseStorage>(),
      ),
    );
    gh.singleton<_i681.CacheHelper>(
      () => _i681.CacheHelper(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i941.NotificationService>(
      () => _i941.NotificationService(
        messaging: gh<_i892.FirebaseMessaging>(),
        firestore: gh<_i974.FirebaseFirestore>(),
        auth: gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i219.PresenceService>(
      () => _i219.PresenceService(
        firestore: gh<_i974.FirebaseFirestore>(),
        database: gh<_i345.FirebaseDatabase>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i106.ModerationRepository>(
      () => _i378.ModerationRepositoryImpl(
        remoteDataSource: gh<_i200.ModerationRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i894.ProfileRepository>(
      () => _i334.ProfileRepositoryImpl(
        remoteDataSource: gh<_i847.ProfileRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i391.DeepLinkService>(
      () => _i391.DeepLinkService(appLinks: gh<_i327.AppLinks>()),
    );
    gh.lazySingleton<_i858.RemoteConfigService>(
      () => _i858.RemoteConfigService(
        remoteConfig: gh<_i627.FirebaseRemoteConfig>(),
        firestore: gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i890.AgoraService>(
      () => _i890.AgoraService(
        functions: gh<_i809.FirebaseFunctions>(),
        cacheHelper: gh<_i681.CacheHelper>(),
        firebaseAuth: gh<_i59.FirebaseAuth>(),
        remoteConfig: gh<_i858.RemoteConfigService>(),
      ),
    );
    gh.lazySingleton<_i980.ChatRemoteDataSource>(
      () => _i980.ChatRemoteDataSource(
        firestore: gh<_i974.FirebaseFirestore>(),
        firebaseAuth: gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i121.DiscoverRemoteDataSource>(
      () => _i121.DiscoverRemoteDataSource(
        firestore: gh<_i974.FirebaseFirestore>(),
        firebaseAuth: gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i362.HomeRemoteDataSource>(
      () => _i362.HomeRemoteDataSource(firestore: gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i951.NotificationsRemoteDataSource>(
      () => _i951.NotificationsRemoteDataSource(
        firestore: gh<_i974.FirebaseFirestore>(),
        firebaseAuth: gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i783.GameRemoteDataSource>(
      () => _i783.GameRemoteDataSource(
        firestore: gh<_i974.FirebaseFirestore>(),
        functions: gh<_i809.FirebaseFunctions>(),
        firebaseAuth: gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i302.DiscoverRepository>(
      () => _i76.DiscoverRepositoryImpl(
        remoteDataSource: gh<_i121.DiscoverRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i855.RoomRepository>(
      () => _i166.RoomRepositoryImpl(
        remoteDataSource: gh<_i918.RoomRemoteDataSource>(),
        firebaseAuth: gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i0.HomeRepository>(
      () => _i76.HomeRepositoryImpl(
        remoteDataSource: gh<_i362.HomeRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i674.SettingsRepository>(
      () => _i955.SettingsRepositoryImpl(cacheHelper: gh<_i681.CacheHelper>()),
    );
    gh.lazySingleton<_i563.NotificationsRepository>(
      () => _i201.NotificationsRepositoryImpl(
        remoteDataSource: gh<_i951.NotificationsRemoteDataSource>(),
      ),
    );
    gh.factory<_i990.EditProfileCubit>(
      () => _i990.EditProfileCubit(
        profileRepository: gh<_i894.ProfileRepository>(),
      ),
    );
    gh.factory<_i36.ProfileCubit>(
      () => _i36.ProfileCubit(profileRepository: gh<_i894.ProfileRepository>()),
    );
    gh.factory<_i793.BlockedUsersCubit>(
      () => _i793.BlockedUsersCubit(
        moderationRepository: gh<_i106.ModerationRepository>(),
      ),
    );
    gh.singleton<_i117.AuthCubit>(
      () => _i117.AuthCubit(
        authRepository: gh<_i787.AuthRepository>(),
        remoteConfigService: gh<_i858.RemoteConfigService>(),
      ),
    );
    gh.factory<_i9.HomeCubit>(
      () => _i9.HomeCubit(
        homeRepository: gh<_i0.HomeRepository>(),
        profileRepository: gh<_i894.ProfileRepository>(),
        notificationsRepository: gh<_i563.NotificationsRepository>(),
      ),
    );
    gh.factory<_i131.RoomCubit>(
      () => _i131.RoomCubit(
        roomRepository: gh<_i855.RoomRepository>(),
        agoraService: gh<_i890.AgoraService>(),
        heartbeatService: gh<_i19.StreamHeartbeatService>(),
      ),
    );
    gh.lazySingleton<_i420.ChatRepository>(
      () => _i504.ChatRepositoryImpl(
        remoteDataSource: gh<_i980.ChatRemoteDataSource>(),
      ),
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
    gh.lazySingleton<_i19.StreamHeartbeatService>(
      () => _i19.StreamHeartbeatService(
        roomRepository: gh<_i855.RoomRepository>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i405.NotificationsCubit>(
      () => _i405.NotificationsCubit(
        notificationsRepository: gh<_i563.NotificationsRepository>(),
      ),
    );
    gh.factory<_i792.SettingsCubit>(
      () => _i792.SettingsCubit(
        settingsRepository: gh<_i674.SettingsRepository>(),
      ),
    );
    gh.factory<_i305.ChatCubit>(
      () => _i305.ChatCubit(chatRepository: gh<_i420.ChatRepository>()),
    );
    gh.factory<_i22.NewMessageCubit>(
      () => _i22.NewMessageCubit(chatRepository: gh<_i420.ChatRepository>()),
    );
    gh.factory<_i192.GameCubit>(
      () => _i192.GameCubit(
        gameRepository: gh<_i32.GameRepository>(),
        roomRepository: gh<_i855.RoomRepository>(),
        agoraService: gh<_i890.AgoraService>(),
        audioService: gh<_i15.AudioService>(),
        heartbeatService: gh<_i19.StreamHeartbeatService>(),
      ),
    );
    return this;
  }
}

class _$ThirdPartyModule extends _i811.ThirdPartyModule {}
