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

  const AppRepositories({
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

  static AppRepositories initialize() {
    return AppRepositories(
      authenticationRepository: AuthenticationRepository(),
      servicePostRepository: ServicePostRepository(),
      commentRepository: CommentRepository(),
      userProfileRepository: UserProfileRepository(),
      categoriesRepository: CategoriesRepository(),
      userFollowRepository: UserFollowRepository(),
      notificationRepository: NotificationRepository(),
      userContactRepository: UserContactRepository(),
      reportRepository: ReportRepository(),
      purchaseRequestRepository: PurchaseRequestRepository(),
    );
  }
}