import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/comments/comment_bloc.dart';
import 'package:talbna/blocs/notification/notifications_bloc.dart';
import 'package:talbna/blocs/other_users/user_profile_bloc.dart';
import 'package:talbna/blocs/report/report_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/user_action/user_action_bloc.dart';
import 'package:talbna/blocs/user_contact/user_contact_bloc.dart';
import 'package:talbna/blocs/user_follow/user_follow_bloc.dart';
import 'package:talbna/data/repositories/authentication_repository.dart';
import 'package:talbna/data/repositories/comment_repository.dart';
import 'package:talbna/data/repositories/notification_repository.dart';
import 'package:talbna/data/repositories/report_repository.dart';
import 'package:talbna/data/repositories/service_post_repository.dart';
import 'package:talbna/data/repositories/user_contact_repository.dart';
import 'package:talbna/data/repositories/user_follow_repository.dart';
import 'package:talbna/data/repositories/user_profile_repository.dart';
import 'package:talbna/theme_cubit.dart';
import 'package:talbna/utils/fcm_handler.dart';
import 'app.dart';
import 'blocs/category/subcategory_bloc.dart';
import 'blocs/internet/internet_bloc.dart';
import 'blocs/internet/internet_event.dart';
import 'blocs/purchase_request/purchase_request_bloc.dart';
import 'blocs/user_profile/user_profile_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'data/repositories/categories_repository.dart';
import 'data/repositories/purchase_request_repository.dart';

String language = 'العربية';

Future<void> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.locationWhenInUse,
    Permission.contacts,
    Permission.camera,
    Permission.storage,
    Permission.notification,
  ].request();

  if (statuses[Permission.locationWhenInUse]?.isDenied == true) {
    print('Location permission denied.');
  }
  if (statuses[Permission.contacts]?.isDenied == true) {
    print('Contacts permission denied.');
  }
  if (statuses[Permission.camera]?.isDenied == true) {
    print('Camera permission denied.');
  }
  if (statuses[Permission.storage]?.isPermanentlyDenied == true) {
    print('Storage permission permanently denied. Redirecting to settings...');
    await openAppSettings();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FCMHandler fcmHandler = FCMHandler();
  await fcmHandler.initializeFCM();
  await requestPermissions();

  final prefs = await SharedPreferences.getInstance();
  final bool isDarkTheme = prefs.getBool('isDarkTheme') ?? false;

  final brightness = isDarkTheme ? Brightness.dark : Brightness.light;
  final statusBarColor = isDarkTheme ? AppTheme.darkPrimaryColor : AppTheme.lightPrimaryColor;
  final navigationBarColor = isDarkTheme ? AppTheme.darkPrimaryColor : AppTheme.lightPrimaryColor;

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: statusBarColor,
    statusBarBrightness: brightness,
    systemNavigationBarColor: navigationBarColor,
    systemNavigationBarIconBrightness: isDarkTheme ? Brightness.light : Brightness.dark,
  ));

  if (prefs.containsKey('language')) {
    language = prefs.getString('language')!;
  } else {
    language = 'English';
  }

  final authenticationRepository = AuthenticationRepository();
  final servicePostRepository = ServicePostRepository();
  final commentsRepository = CommentRepository();
  final userProfileRepository = UserProfileRepository();
  final subcategoryRepository = CategoriesRepository();

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
        BlocProvider<talabnaNotificationBloc>(
          create: (context) => talabnaNotificationBloc(notificationRepository: NotificationRepository()),
        ),
        BlocProvider<ServicePostBloc>(
          create: (context) => ServicePostBloc(servicePostRepository: servicePostRepository),
        ),
        BlocProvider<CommentBloc>(
          create: (context) => CommentBloc(commentRepository: commentsRepository),
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
          create: (context) => ThemeCubit()..loadTheme(),
        ),
      ],
      child: MyApp(
        authenticationRepository: authenticationRepository,
        isDarkTheme: isDarkTheme,
      ),
    ),
  );
}

