import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/notification/notifications_bloc.dart';
import 'package:talbna/blocs/other_users/user_profile_bloc.dart';
import 'package:talbna/blocs/report/report_bloc.dart';
import 'package:talbna/blocs/service_post/bloc_observer.dart';
import 'package:talbna/blocs/user_action/user_action_bloc.dart';
import 'package:talbna/blocs/user_contact/user_contact_bloc.dart';
import 'package:talbna/blocs/user_follow/user_follow_bloc.dart';
import 'package:talbna/data/repositories/categories_repository.dart';
import 'package:talbna/data/repositories/purchase_request_repository.dart';
import 'package:talbna/data/repositories/report_repository.dart';
import 'package:talbna/data/repositories/service_post_repository.dart';
import 'package:talbna/theme_cubit.dart';
import 'package:talbna/utils/fcm_handler.dart';
import 'app.dart';
import 'blocs/authentication/authentication_bloc.dart';
import 'blocs/category/subcategory_bloc.dart';
import 'blocs/internet/internet_bloc.dart';
import 'blocs/internet/internet_event.dart';
import 'blocs/purchase_request/purchase_request_bloc.dart';
import 'blocs/service_post/service_post_bloc.dart';
import 'blocs/user_profile/user_profile_bloc.dart';
import 'data/repositories/authentication_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/user_contact_repository.dart';
import 'data/repositories/user_follow_repository.dart';
import 'data/repositories/user_profile_repository.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FCMHandler fcmHandler = FCMHandler();
  await fcmHandler.initializeFCM();
  await requestPermissions();
  final authenticationRepository = AuthenticationRepository();
  final servicePostRepository  = ServicePostRepository();

  final userProfileRepository = UserProfileRepository();
  final subcategoryRepository  = CategoriesRepository();
  AppTheme.setSystemBarColors(Brightness.light, AppTheme.primaryColor,AppTheme.primaryColor);
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<NetworkBloc>(
          create: (context) => NetworkBloc()..add(NetworkObserve()),
        ),
        BlocProvider<AuthenticationBloc>(
          create: (context) => AuthenticationBloc(
            authenticationRepository: authenticationRepository,
          ),
        ),
        BlocProvider<UserProfileBloc>(
          create: (context) => UserProfileBloc(
            repository: userProfileRepository,
          ),
        ),
        BlocProvider<PurchaseRequestBloc>(
          create: (context) => PurchaseRequestBloc(repository: PurchaseRequestRepository()),
        ),
        BlocProvider<OtherUserProfileBloc>(
          create: (context) => OtherUserProfileBloc(
            repository: userProfileRepository,
          ),
        ),
        BlocProvider<UserFollowBloc>(
          create: (context) => UserFollowBloc(
            repository: UserFollowRepository(),
          ),
        ),
        BlocProvider<UserActionBloc>(
          create: (context) => UserActionBloc(
            repository: UserFollowRepository(),
          ),
        ),
        BlocProvider<TalbnaNotificationBloc>(
          create: (context) => TalbnaNotificationBloc(notificationRepository: NotificationRepository()),
        ),
        BlocProvider<ServicePostBloc>(
          create: (context) => ServicePostBloc(servicePostRepository: servicePostRepository),
        ),

        BlocProvider<UserContactBloc>(
          create: (context) => UserContactBloc(repository: UserContactRepository()),
        ),
        BlocProvider<ReportBloc>(
          create: (context) => ReportBloc(repository: ReportRepository()),
        ),
        BlocProvider<SubcategoryBloc>(
          create: (context) => SubcategoryBloc(categoriesRepository: subcategoryRepository),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
      ],
      child: MyApp(
        authenticationRepository: authenticationRepository,
      ),
    ),
  );
}

Future<void> requestPermissions() async {
  // Request location permission
  await Permission.location.request();
  // Request storage permission
  await Permission.storage.request();
  // Request photos permission
  await Permission.photos.request();
  // Request contacts permission
  await Permission.contacts.request();
  // Request camera permission
  await Permission.camera.request();
  // Request notification permission
  await Permission.notification.request();
}
