// 📁 lib/core/services/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/discovery/data/datasources/discovery_remote_datasource.dart';
import '../../features/discovery/data/repositories/discovery_repository_impl.dart';
import '../../features/discovery/domain/repositories/discovery_repository.dart';
import '../../features/discovery/domain/usecases/get_nearby_users_usecase.dart';
import '../../features/discovery/presentation/bloc/discovery_bloc.dart';

import '../../features/feed/data/datasources/feed_remote_datasource.dart';
import '../../features/feed/data/repositories/feed_repository_impl.dart';
import '../../features/feed/domain/repositories/feed_repository.dart';
import '../../features/feed/domain/usecases/get_feed_posts_usecase.dart';
import '../../features/feed/domain/repositories/recommendation_repository.dart';
import '../../features/feed/data/repositories/recommendation_repository_impl.dart';
import '../../features/feed/domain/usecases/get_user_recommendations_usecase.dart';
import '../../features/feed/presentation/bloc/feed_bloc.dart';
import '../../features/feed/presentation/bloc/recommendation_bloc.dart';

import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/send_message_usecase.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';

import '../../features/gamification/data/datasources/gamification_remote_datasource.dart';
import '../../features/gamification/data/repositories/gamification_repository_impl.dart';
import '../../features/gamification/domain/repositories/gamification_repository.dart';
import '../../features/gamification/domain/usecases/add_xp_usecase.dart';
import '../../features/gamification/domain/usecases/get_user_xp_usecase.dart';
import '../../features/gamification/presentation/bloc/gamification_bloc.dart';

import '../encryption/encryption_service.dart';
import '../location/location_service.dart';
import '../storage/secure_storage_service.dart';
import '../services/ad_service.dart';
import '../services/subscription_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core Services
  getIt.registerLazySingleton(() => Supabase.instance.client);
  getIt.registerLazySingleton(() => const FlutterSecureStorage());
  getIt.registerLazySingleton(() => SecureStorageService(getIt()));
  getIt.registerLazySingleton(() => EncryptionService(getIt()));
  getIt.registerLazySingleton(() => LocationService());
  
  getIt.registerLazySingleton(() => AdService());
  getIt.registerLazySingleton(() => SubscriptionService());
  
  // Initialize ad service
  await getIt<AdService>().initialize();
  await getIt<SubscriptionService>().initialize();
  
  // Auth Feature
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton(() => SignInUseCase(getIt()));
  getIt.registerLazySingleton(() => SignUpUseCase(getIt()));
  getIt.registerLazySingleton(() => SignOutUseCase(getIt()));
  getIt.registerFactory(() => AuthBloc(
    signInUseCase: getIt(),
    signUpUseCase: getIt(),
    signOutUseCase: getIt(),
  ));
  
  // Discovery Feature
  getIt.registerLazySingleton<DiscoveryRemoteDataSource>(
    () => DiscoveryRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<DiscoveryRepository>(
    () => DiscoveryRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton(() => GetNearbyUsersUseCase(getIt()));
  getIt.registerFactory(() => DiscoveryBloc(getNearbyUsersUseCase: getIt()));
  
  // Feed Feature
  getIt.registerLazySingleton<FeedRemoteDataSource>(
    () => FeedRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton(() => GetFeedPostsUseCase(getIt()));
  getIt.registerFactory(() => FeedBloc(
    getFeedPostsUseCase: getIt(),
    repository: getIt(),
  ));
  
  // Recommendation Feature
  getIt.registerLazySingleton<RecommendationRepository>(
    () => RecommendationRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetUserRecommendationsUseCase(getIt()));
  getIt.registerFactory(() => RecommendationBloc(
    getUserRecommendationsUseCase: getIt(),
    repository: getIt(),
  ));
  
  // Chat Feature
  getIt.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton(() => SendMessageUseCase(getIt()));
  getIt.registerFactory(() => ChatBloc(
    sendMessageUseCase: getIt(),
    chatRepository: getIt(),
  ));
  
  // Gamification Feature
  getIt.registerLazySingleton<GamificationRemoteDataSource>(
    () => GamificationRemoteDataSourceImpl(supabaseClient: getIt()),
  );
  getIt.registerLazySingleton<GamificationRepository>(
    () => GamificationRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton(() => GetUserXpUseCase(getIt()));
  getIt.registerLazySingleton(() => AddXpUseCase(getIt()));
  getIt.registerFactory(() => GamificationBloc(
    getUserXpUseCase: getIt(),
    addXpUseCase: getIt(),
    repository: getIt(),
  ));
}
