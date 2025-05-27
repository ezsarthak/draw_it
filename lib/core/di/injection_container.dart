import 'package:get_it/get_it.dart';

import '../../data/datasources/socket_datasource.dart';
import '../../data/datasources/storage_datasource.dart';
import '../../data/repositories/drawing_repository_impl.dart';
import '../../data/repositories/socket_repository_impl.dart';
import '../../data/repositories/storage_repository_impl.dart';
import '../../domain/repositories/drawing_repository.dart';
import '../../domain/repositories/socket_repository.dart';
import '../../domain/repositories/storage_repository.dart';
import '../../domain/usecases/drawing_usecases.dart';
import '../../domain/usecases/socket_usecases.dart';
import '../../domain/usecases/storage_usecases.dart';
import '../../presentation/bloc/drawing/drawing_bloc.dart';
import '../../presentation/bloc/socket/socket_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Data sources
  sl.registerLazySingleton<SocketDataSource>(
    () => SocketDataSourceImpl(),
  );
  sl.registerLazySingleton<StorageDataSource>(
    () => StorageDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<DrawingRepository>(
    () => DrawingRepositoryImpl(),
  );
  sl.registerLazySingleton<SocketRepository>(
    () => SocketRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<StorageRepository>(
    () => StorageRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => AddLineUseCase(sl()));
  sl.registerLazySingleton(() => UndoUseCase(sl()));
  sl.registerLazySingleton(() => RedoUseCase(sl()));
  sl.registerLazySingleton(() => ClearLinesUseCase(sl()));
  sl.registerLazySingleton(() => ConnectSocketUseCase(sl()));
  sl.registerLazySingleton(() => DisconnectSocketUseCase(sl()));
  sl.registerLazySingleton(() => EmitDrawLineUseCase(sl()));
  sl.registerLazySingleton(() => SaveDrawingUseCase(sl()));

  // BLoCs
  sl.registerFactory(() => DrawingBloc(
        addLineUseCase: sl(),
        undoUseCase: sl(),
        redoUseCase: sl(),
        clearLinesUseCase: sl(),
      ));
  sl.registerFactory(() => SocketBloc(
        connectSocketUseCase: sl(),
        disconnectSocketUseCase: sl(),
        emitDrawLineUseCase: sl(),
        socketRepository: sl(),
      ));
}
