// lib/core/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/data/datasources/category_data_source.dart';
import 'package:talbna/data/datasources/local/local_category_data_source.dart';
import 'package:talbna/data/datasources/remote/remote_category_data_source.dart';
import 'package:talbna/data/datasources/service_post_data_source.dart';
import 'package:talbna/data/datasources/local/local_service_post_data_source.dart';
import 'package:talbna/data/datasources/remote/remote_service_post_data_source.dart';
import 'package:talbna/data/repositories/categories_repository.dart';
import 'package:talbna/data/repositories/service_post_repository.dart';
import 'package:talbna/blocs/category/subcategory_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/utils/debug_logger.dart';

final serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  DebugLogger.log('Setting up service locator', category: 'INIT');

  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(sharedPreferences);
  serviceLocator.registerLazySingleton<http.Client>(() => http.Client());

  // Data sources
  serviceLocator.registerLazySingleton<CategoryDataSource>(
        () => RemoteCategoryDataSource(),
  );

  serviceLocator.registerLazySingleton<LocalCategoryDataSource>(
        () => LocalCategoryDataSource(sharedPreferences: serviceLocator<SharedPreferences>()),
  );

  // Repositories
  serviceLocator.registerLazySingleton<CategoriesRepository>(
        () => CategoriesRepository(
      remoteDataSource: serviceLocator<CategoryDataSource>(),
      localDataSource: serviceLocator<LocalCategoryDataSource>(),
    ),
  );

  // BLoCs
  serviceLocator.registerFactory<SubcategoryBloc>(
        () => SubcategoryBloc(
      categoriesRepository: serviceLocator<CategoriesRepository>(),
      localDataSource: serviceLocator<LocalCategoryDataSource>(),
    ),
  );

  serviceLocator.registerFactory<ServicePostBloc>(
        () => ServicePostBloc(
      servicePostRepository: serviceLocator<ServicePostRepository>(),
    ),
  );

  DebugLogger.log('Service locator setup complete', category: 'INIT');
}