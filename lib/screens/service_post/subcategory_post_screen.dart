import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/blocs/user_action/user_action_bloc.dart';
import 'package:talbna/blocs/user_action/user_action_event.dart';
import 'package:talbna/blocs/user_action/user_action_state.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/screens/profile/profile_check_builder.dart';
import 'package:talbna/screens/service_post/service_post_card.dart';

import '../../blocs/user_profile/user_profile_bloc.dart';
import '../profile/profile_completion_service.dart';
import '../service_post/create_service_post_form.dart';

class SubCategoryPostScreen extends StatefulWidget {
  const SubCategoryPostScreen({
    super.key,
    required this.userID,
    required this.categoryId,
    required this.subcategoryId,
    required this.servicePostBloc,
    required this.userProfileBloc,
    required this.user,
    required this.titleSubcategory,
  });

  final int userID;
  final User user;
  final int categoryId;
  final int subcategoryId;
  final String titleSubcategory;
  final ServicePostBloc servicePostBloc;
  final UserProfileBloc userProfileBloc;

  @override
  SubCategoryPostScreenState createState() => SubCategoryPostScreenState();
}

class SubCategoryPostScreenState extends State<SubCategoryPostScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasReachedMax = false;
  bool isFollowing = false;
  bool _isRefreshing = false;
  List<ServicePost> _posts = [];
  final _profileCompletionService = ProfileCompletionService();
  final language = Language();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  Future<void> _handleAddPost(BuildContext context) async {
    // Use the context extension to check profile completion
    context.performWithProfileCheck(
      action: () {
        _navigateToServicePost(context);
      },
      user: widget.user,
      userId: widget.userID,
    );
  }

  void _navigateToServicePost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServicePostFormScreen(userId: widget.userID, user: widget.user,),
      ),
    );
  }

  void _loadInitialData() {
    context.read<UserActionBloc>().add(
        GetUserFollowSubcategories(subCategoryId: widget.subcategoryId)
    );

    widget.servicePostBloc.add(
        GetServicePostsByCategorySubCategoryEvent(
            category: widget.categoryId, subCategory: widget.subcategoryId, page: _currentPage
        )
    );
  }

  void _onScroll() {
    if (!_hasReachedMax &&
        _scrollController.offset >= _scrollController.position.maxScrollExtent - 200 &&
        !_scrollController.position.outOfRange) {
      _currentPage++;
      widget.servicePostBloc.add(
          GetServicePostsByCategorySubCategoryEvent(
              category: widget.categoryId, subCategory: widget.subcategoryId, page: _currentPage
          )
      );
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
      _currentPage = 1;
      _hasReachedMax = false;
      _posts.clear();
    });

    _loadInitialData();

    setState(() => _isRefreshing = false);
  }

  Widget _buildFollowButton() {
    return BlocConsumer<UserActionBloc, UserActionState>(
      listener: (context, state) {
        if (state is UserMakeFollowSubcategoriesSuccess) {
          isFollowing = state.followSuccess;

          final message = state.followSuccess
              ? language.getFollowingText(widget.titleSubcategory)
              : language.getUnfollowedText(widget.titleSubcategory);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    state.followSuccess ? Icons.check_circle : Icons.info_outline,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(message),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is GetFollowSubcategoriesSuccess) {
          isFollowing = state.followSuccess;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: ElevatedButton(
            onPressed: () {
              // Check profile completion before allowing follow action
              context.performWithProfileCheck(
                action: () {
                  context.read<UserActionBloc>().add(
                      UserMakeFollowSubcategories(
                          subCategoryId: widget.subcategoryId
                      )
                  );
                },
                user: widget.user,
                userId: widget.userID,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isFollowing
                  ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                  : Theme.of(context).primaryColor,
              foregroundColor: isFollowing
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.white,
              elevation: isFollowing ? 0 : 2,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isFollowing
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFollowing ? Icons.check : Icons.add,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  isFollowing
                      ? language.getFollowingButtonText()
                      : language.getFollowButtonText(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _handleRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(language.getTryAgainText()),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withOpacity(0.7),
            theme.primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.titleSubcategory,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      language.getNotificationFollowingText(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              _buildFollowButton(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                language.getLatestPostsText(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  language.getPostsCountText(_posts.length),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: theme.hintColor,
          ),
          const SizedBox(height: 16),
          Text(
            language.getNoPostsText(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            language.getBeFirstToPostText(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _handleAddPost(context),
            icon: const Icon(Icons.add),
            label: Text(language.getCreatePostText()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              pinned: true,
              elevation: 0,
              forceElevated: innerBoxIsScrolled,
              backgroundColor: theme.scaffoldBackgroundColor,
              title: Text(
                widget.titleSubcategory,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
            ),
          ];
        },
        body: BlocConsumer<ServicePostBloc, ServicePostState>(
          bloc: widget.servicePostBloc,
          listener: (context, state) {
            if (state is ServicePostLoadSuccess) {
              setState(() {
                if (_currentPage == 1) {
                  _posts = state.servicePosts;
                } else {
                  _posts = [..._posts, ...state.servicePosts];
                }
                _hasReachedMax = state.hasReachedMax;
              });
            }
          },
          builder: (context, state) {
            if (_posts.isEmpty && state is ServicePostLoading) {
              return _buildLoadingIndicator();
            }

            if (state is ServicePostLoadFailure) {
              return _buildErrorState(state.errorMessage);
            }

            if (_posts.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: _handleRefresh,
              color: theme.primaryColor,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildCategoryHeader(),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          if (index >= _posts.length) {
                            return _buildLoadingIndicator();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: AnimatedOpacity(
                              opacity: _isRefreshing ? 0.5 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.shadowColor.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ServicePostCard(
                                    key: ValueKey('post_${_posts[index].id}'),
                                    servicePost: _posts[index],
                                    onPostDeleted: (postId) {
                                      setState(() {
                                        _posts.removeWhere((p) => p.id == postId);
                                      });
                                    },
                                    canViewProfile: false,
                                    userProfileId: widget.userID,
                                    user: widget.user,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: _posts.length + (_hasReachedMax ? 0 : 1),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _posts.clear();
    super.dispose();
  }
}