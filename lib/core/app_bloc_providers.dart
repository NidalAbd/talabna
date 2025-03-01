import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/category/subcategory_bloc.dart';
import 'package:talbna/blocs/comments/comment_bloc.dart';
import 'package:talbna/blocs/internet/internet_bloc.dart';
import 'package:talbna/blocs/internet/internet_event.dart';
import 'package:talbna/blocs/notification/notifications_bloc.dart';
import 'package:talbna/blocs/other_users/user_profile_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_bloc.dart';
import 'package:talbna/blocs/report/report_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/user_action/user_action_bloc.dart';
import 'package:talbna/blocs/user_contact/user_contact_bloc.dart';
import 'package:talbna/blocs/user_follow/user_follow_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/theme_cubit.dart';
import 'app_repositories.dart';

class AppBlocProviders {
  static List<BlocProvider> getProviders(AppRepositories repositories) {
    return [
      // Network Observer
      BlocProvider<NetworkBloc>(
        create: (context) => NetworkBloc()..add(NetworkObserve()),
      ),

      // Authentication
      BlocProvider<AuthenticationBloc>(
        create: (context) => AuthenticationBloc(
          authenticationRepository: repositories.authenticationRepository,
        ),
      ),

      // User Profiles
      BlocProvider<UserProfileBloc>(
        create: (context) => UserProfileBloc(
          repository: repositories.userProfileRepository,
        ),
      ),
      BlocProvider<OtherUserProfileBloc>(
        create: (context) => OtherUserProfileBloc(
          repository: repositories.userProfileRepository,
        ),
      ),

      // Service & Purchase Related
      BlocProvider<ServicePostBloc>(
        create: (context) => ServicePostBloc(
          servicePostRepository: repositories.servicePostRepository,
        ),
      ),
      BlocProvider<PurchaseRequestBloc>(
        create: (context) => PurchaseRequestBloc(
          repository: repositories.purchaseRequestRepository,
        ),
      ),

      // Social Interactions
      BlocProvider<UserFollowBloc>(
        create: (context) => UserFollowBloc(
          repository: repositories.userFollowRepository,
        ),
      ),
      BlocProvider<UserActionBloc>(
        create: (context) => UserActionBloc(
          repository: repositories.userFollowRepository,
        ),
      ),
      BlocProvider<UserContactBloc>(
        create: (context) => UserContactBloc(
          repository: repositories.userContactRepository,
        ),
      ),

      // Content Related
      BlocProvider<CommentBloc>(
        create: (context) => CommentBloc(
          commentRepository: repositories.commentRepository,
        ),
      ),
      BlocProvider<SubcategoryBloc>(
        create: (context) => SubcategoryBloc(
          categoriesRepository: repositories.categoriesRepository,
        ),
      ),
      BlocProvider<ReportBloc>(
        create: (context) => ReportBloc(
          repository: repositories.reportRepository,
        ),
      ),

      // Notifications
      BlocProvider<talabnaNotificationBloc>(
        create: (context) => talabnaNotificationBloc(
          notificationRepository: repositories.notificationRepository,
        ),
      ),

      // Theme Management
      BlocProvider<ThemeCubit>(
        create: (context) => ThemeCubit()..loadTheme(),
      ),
    ];
  }
}