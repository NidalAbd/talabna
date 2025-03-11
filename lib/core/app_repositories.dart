// lib/core/app_repositories.dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/core/service_locator.dart';
import 'package:talbna/data/repositories/authentication_repository.dart';
import 'package:talbna/data/repositories/categories_repository.dart';
import 'package:talbna/data/repositories/comment_repository.dart';
import 'package:talbna/data/repositories/notification_repository.dart';
import 'package:talbna/data/repositories/purchase_request_repository.dart';
import 'package:talbna/data/repositories/report_repository.dart';
import 'package:talbna/data/repositories/service_post_repository.dart';
import 'package:talbna/data/repositories/user_contact_repository.dart';
import 'package:talbna/data/repositories/user_follow_repository.dart';
import 'package:talbna/data/repositories/user_profile_repository.dart';
import 'package:talbna/utils/debug_logger.dart';

class AppRepositories {
  final AuthenticationRepository authenticationRepository;
  final ServicePostRepository servicePostRepository;
  final CommentRepository commentRepository;
  final UserProfileRepository userProfileRepository;
  final CategoriesRepository categoriesRepository;
  final UserFollowRepository userFollowRepository;
  final NotificationRepository notificationRepository;
  final UserContactRepository userContactRepository;
  final ReportRepository reportRepository;
  final PurchaseRequestRepository purchaseRequestRepository;

  const AppRepositories._({
    required this.authenticationRepository,
    required this.servicePostRepository,
    required this.commentRepository,
    required this.userProfileRepository,
    required this.categoriesRepository,
    required this.userFollowRepository,
    required this.notificationRepository,
    required this.userContactRepository,
    required this.reportRepository,
    required this.purchaseRequestRepository,
  });

  static Future<AppRepositories> initialize() async {
    DebugLogger.log('Initializing AppRepositories', category: 'REPOSITORIES');

    try {
      // Check if service locator is ready
      if (GetIt.instance.isRegistered<ServicePostRepository>() &&
          GetIt.instance.isRegistered<CategoriesRepository>()) {
        // Use service locator for repositories that have been registered
        DebugLogger.log('Using repositories from service locator', category: 'REPOSITORIES');

        return AppRepositories._(
          authenticationRepository: AuthenticationRepository(),
          servicePostRepository: serviceLocator<ServicePostRepository>(),
          commentRepository: CommentRepository(),
          userProfileRepository: UserProfileRepository(),
          categoriesRepository: serviceLocator<CategoriesRepository>(),
          userFollowRepository: UserFollowRepository(),
          notificationRepository: NotificationRepository(),
          userContactRepository: UserContactRepository(),
          reportRepository: ReportRepository(),
          purchaseRequestRepository: PurchaseRequestRepository(),
        );
      } else {
        // Fallback to direct instantiation
        DebugLogger.log('Service locator not ready, using direct instantiation', category: 'REPOSITORIES');

        // Create the remote and local data sources manually
        final sharedPreferences = GetIt.instance.isRegistered<SharedPreferences>()
            ? serviceLocator<SharedPreferences>()
            : null;

        // Create repositories with manual dependency injection
        // Note: This is a temporary solution until the service locator is fully set up
        final categoriesRepository = await CategoriesRepository.legacy();

        return AppRepositories._(
          authenticationRepository: AuthenticationRepository(),
          servicePostRepository: ServicePostRepository(),
          commentRepository: CommentRepository(),
          userProfileRepository: UserProfileRepository(),
          categoriesRepository: categoriesRepository,
          userFollowRepository: UserFollowRepository(),
          notificationRepository: NotificationRepository(),
          userContactRepository: UserContactRepository(),
          reportRepository: ReportRepository(),
          purchaseRequestRepository: PurchaseRequestRepository(),
        );
      }
    } catch (e) {
      DebugLogger.log('Error initializing repositories: $e', category: 'REPOSITORIES');

      // Create legacy repositories as fallback
      final categoriesRepository = await CategoriesRepository.legacy();

      return AppRepositories._(
        authenticationRepository: AuthenticationRepository(),
        servicePostRepository: ServicePostRepository(),
        commentRepository: CommentRepository(),
        userProfileRepository: UserProfileRepository(),
        categoriesRepository: categoriesRepository,
        userFollowRepository: UserFollowRepository(),
        notificationRepository: NotificationRepository(),
        userContactRepository: UserContactRepository(),
        reportRepository: ReportRepository(),
        purchaseRequestRepository: PurchaseRequestRepository(),
      );
    }
  }
}