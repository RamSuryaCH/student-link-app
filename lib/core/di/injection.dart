import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Data sources
import '../../data/datasources/firebase_auth_service.dart';
import '../../data/datasources/post_service.dart';
import '../../data/datasources/anonymous_post_service.dart';
import '../../data/datasources/club_service.dart';
import '../../data/datasources/connection_service.dart';
import '../../data/datasources/messaging_service.dart';
import '../../data/datasources/user_profile_service.dart';
import '../../data/datasources/admin_service.dart';
import '../../data/datasources/push_notification_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Firebase instances
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  getIt.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);

  // Services
  getIt.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());
  getIt.registerLazySingleton<PostService>(() => PostService());
  getIt.registerLazySingleton<AnonymousPostService>(() => AnonymousPostService());
  getIt.registerLazySingleton<ClubService>(() => ClubService());
  getIt.registerLazySingleton<ConnectionService>(() => ConnectionService());
  getIt.registerLazySingleton<MessagingService>(() => MessagingService());
  getIt.registerLazySingleton<UserProfileService>(() => UserProfileService());
  getIt.registerLazySingleton<AdminService>(() => AdminService());
  getIt.registerLazySingleton<PushNotificationService>(() => PushNotificationService());
}
