import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repo_impl.dart';
import 'features/auth/domain/repositories/auth_repo.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {

  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPrefs);

  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);

  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSource(
      auth:      sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerLazySingleton<AuthRepo>(
        () => AuthRepoImpl(sl<AuthRemoteDataSource>()),
  );

  sl.registerLazySingleton<RegisterUseCase>(
        () => RegisterUseCase(sl<AuthRepo>()),
  );

  sl.registerLazySingleton<LoginUseCase>(
        () => LoginUseCase(sl<AuthRepo>()),
  );

  sl.registerFactory<AuthBloc>(
        () => AuthBloc(
      registerUseCase: sl<RegisterUseCase>(),
      loginUseCase:    sl<LoginUseCase>(),
      authDataSource:  sl<AuthRemoteDataSource>(),
    ),
  );
}