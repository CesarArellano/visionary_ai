import 'package:firebase_ai/firebase_ai.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visionary_ai/core/utils/image_utils.dart';
import 'package:visionary_ai/features/history/data/datasources/history_local_datasource.dart';
import 'package:visionary_ai/features/history/data/repositories/history_repository_impl.dart';
import 'package:visionary_ai/features/history/domain/repositories/history_repository.dart';
import 'package:visionary_ai/features/vision/data/datasources/gemini_remote_datasource.dart';
import 'package:visionary_ai/features/vision/data/repositories/vision_repository_impl.dart';
import 'package:visionary_ai/features/vision/domain/repositories/vision_repository.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<FirebaseAI>(() => FirebaseAI.googleAI());

  sl.registerLazySingleton<ImagePicker>(() => ImagePicker());

  sl.registerLazySingleton<ImageUtils>(() => ImageUtils());

  sl.registerLazySingleton<GeminiRemoteDatasource>(
    () => GeminiRemoteDatasource(firebaseAI: sl()),
  );

  sl.registerLazySingleton<HistoryLocalDatasource>(
    () => HistoryLocalDatasource(),
  );

  sl.registerLazySingleton<VisionRepository>(
    () => VisionRepositoryImpl(datasource: sl()),
  );

  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(datasource: sl()),
  );
}