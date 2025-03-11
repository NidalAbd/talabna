import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/service_post/service_post_card.dart';
import 'package:talbna/utils/debug_logger.dart';
import '../widgets/shimmer_widgets.dart';

class ServicePostScreen extends StatefulWidget {
  final int category;
  final int userID;
  final bool showSubcategoryGridView;
  final ServicePostBloc servicePostBloc;
  final User user;

  const ServicePostScreen({
    super.key,
    required this.category,
    required this.userID,
    required this.servicePostBloc,
    required this.showSubcategoryGridView,
    required this.user,
  });

  @override
  ServicePostScreenState createState() => ServicePostScreenState();
}

class ServicePostScreenState extends State<ServicePostScreen>
    with AutomaticKeepAliveClientMixin<ServicePostScreen> {

  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollCategoryPostController = ScrollController();

  // Pagination state
  int _currentPage = 1;
  bool _hasReachedMax = false;
  bool _isLoadingMore = false;

  // Track post IDs to prevent duplicates
  final Set<int> _loadedPostIds = {};

  // Content state
  List<ServicePost> _servicePostsCategory = [];
  bool _hasError = false;
  String _errorMessage = '';

  // Performance tracking
  final Stopwatch _loadStopwatch = Stopwatch();
  bool _isFirstLoad = true;

  // Flag to track if first load is complete
  bool _initialLoadComplete = false;

  // Post deletion callback
  late Function onPostDeleted = (int postId) {
    setState(() {
      _servicePostsCategory.removeWhere((post) => post.id == postId);
      _loadedPostIds.remove(postId);
    });
  };

  @override
  void initState() {
    super.initState();

    // Start tracking load time
    _loadStopwatch.start();

    // Set up scroll controller for pagination
    _scrollCategoryPostController.addListener(_onScrollCategoryPost);

    // Load initial data
    _loadInitialData();
  }

  @override
  void didUpdateWidget(ServicePostScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If category changed, we need to reload
    if (oldWidget.category != widget.category) {
      _resetState();
      _loadInitialData();
    }
  }

  void _resetState() {
    _currentPage = 1;
    _hasReachedMax = false;
    _isLoadingMore = false;
    _servicePostsCategory.clear();
    _loadedPostIds.clear();  // Clear tracked post IDs
    _hasError = false;
    _errorMessage = '';
    _isFirstLoad = true;
    _initialLoadComplete = false;

    // Reset stopwatch for timing the new load
    _loadStopwatch.reset();
    _loadStopwatch.start();
  }

  void _loadInitialData() {
    // Request the first page of posts for this category
    widget.servicePostBloc.add(GetServicePostsByCategoryEvent(
      widget.category,
      _currentPage,
      forceRefresh: true,  // Always get fresh data on initial load
    ));
  }

  void _onScrollCategoryPost() {
    // Only load more if not already loading and not at the max
    if (!_isLoadingMore &&
        !_hasReachedMax &&
        _scrollCategoryPostController.offset >=
            _scrollCategoryPostController.position.maxScrollExtent - 200 &&
        !_scrollCategoryPostController.position.outOfRange) {

      setState(() {
        _isLoadingMore = true;
      });

      _currentPage++;

      DebugLogger.log('Loading more posts for category ${widget.category}, page $_currentPage',
          category: 'SERVICE_POST_SCREEN');

      widget.servicePostBloc.add(GetServicePostsByCategoryEvent(
        widget.category,
        _currentPage,
        forceRefresh: true,  // Always force refresh for pagination
      ));
    }
  }

  Future<void> _handleRefreshCategoryPost() async {
    DebugLogger.log('Refreshing posts for category ${widget.category}',
        category: 'SERVICE_POST_SCREEN');

    // Reset to page 1
    _currentPage = 1;
    _hasReachedMax = false;
    _servicePostsCategory.clear();
    _loadedPostIds.clear();  // Clear tracked post IDs
    _isFirstLoad = true;

    // Track refresh time
    _loadStopwatch.reset();
    _loadStopwatch.start();

    // Request fresh data
    widget.servicePostBloc.add(GetServicePostsByCategoryEvent(
      widget.category,
      _currentPage,
      forceRefresh: true,  // Always get fresh data on refresh
    ));

    // Return a Future that completes after a short delay to allow the refresh indicator to show
    return Future.delayed(const Duration(milliseconds: 500));
  }

  void _handleCategoryPostLoadSuccess(
      List<ServicePost> servicePosts, bool hasReachedMax) {

    // If this is the first load, log performance
    if (_isFirstLoad) {
      _loadStopwatch.stop();
      _isFirstLoad = false;
      _initialLoadComplete = true;

      DebugLogger.log(
          'Initial load of ${servicePosts.length} posts for category ${widget.category} completed in ${_loadStopwatch.elapsedMilliseconds}ms',
          category: 'PERFORMANCE');
    }

    // Filter out duplicates based on post ID
    final List<ServicePost> uniquePosts = [];
    for (final post in servicePosts) {
      if (post.id != null && !_loadedPostIds.contains(post.id)) {
        uniquePosts.add(post);
        _loadedPostIds.add(post.id!);
      }
    }

    setState(() {
      if (_currentPage == 1) {
        // For first page, replace the entire list
        _servicePostsCategory = uniquePosts;
      } else {
        // For pagination, append only new unique posts
        _servicePostsCategory = [..._servicePostsCategory, ...uniquePosts];
      }

      // Update state flags
      _hasReachedMax = hasReachedMax || uniquePosts.isEmpty;
      _isLoadingMore = false;
      _hasError = false;

      // Log summary for debugging
      DebugLogger.log(
          'Added ${uniquePosts.length} new posts. Total: ${_servicePostsCategory.length}. HasReachedMax: $_hasReachedMax',
          category: 'SERVICE_POST_SCREEN');
    });
  }

  Future<bool> _onWillPopCategoryPost() async {
    if (_scrollCategoryPostController.offset > 0) {
      // Scroll to top smoothly
      _scrollCategoryPostController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInToLinear,
      );

      // Wait for 200 milliseconds before refreshing
      await Future.delayed(const Duration(milliseconds: 200));

      // Trigger a refresh after reaching the top
      _handleRefreshCategoryPost();
      return false;
    } else {
      return true;
    }
  }

  @override
  void dispose() {
    _loadStopwatch.stop();
    _servicePostsCategory.clear();
    _loadedPostIds.clear();
    _scrollCategoryPostController.removeListener(_onScrollCategoryPost);
    _scrollCategoryPostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return WillPopScope(
      onWillPop: _onWillPopCategoryPost,
      child: BlocListener<ServicePostBloc, ServicePostState>(
        listenWhen: (previous, current) {
          // Only listen for success or failure events
          return current is ServicePostLoadSuccess ||
              current is ServicePostLoadFailure;
        },
        bloc: widget.servicePostBloc,
        listener: (context, state) {
          if (state is ServicePostLoadSuccess) {
            _handleCategoryPostLoadSuccess(
                state.servicePosts, state.hasReachedMax);
          } else if (state is ServicePostLoadFailure) {
            setState(() {
              _hasError = true;
              _errorMessage = state.errorMessage;
              _isLoadingMore = false;
            });
          }
        },
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // If we have posts, show them
    if (_servicePostsCategory.isNotEmpty) {
      return _buildPostsList();
    }
    // If we have an error, show error state
    else if (_hasError) {
      return _buildErrorState();
    }
    // Otherwise show loading state
    else {
      return const ServicePostScreenShimmer();
    }
  }

  Widget _buildPostsList() {
    return RefreshIndicator(
      onRefresh: _handleRefreshCategoryPost,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCategoryPostController,
              itemCount: _hasReachedMax
                  ? _servicePostsCategory.length
                  : _servicePostsCategory.length + 1,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                // Show loading indicator at the end if not at max
                if (index >= _servicePostsCategory.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  );
                }

                // Get the service post
                final servicePost = _servicePostsCategory[index];

                // Calculate fade-in delay based on index for staggered animation
                final animationDelay = Duration(milliseconds: 50 * (index % 10));

                // Use staggered animation for smoother loading
                return FutureBuilder(
                  future: Future.delayed(animationDelay),
                  builder: (context, snapshot) {
                    return AnimatedOpacity(
                      opacity: snapshot.connectionState == ConnectionState.done ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                      child: ServicePostCard(
                        key: Key('servicePostCategory_${servicePost.id}'),
                        onPostDeleted: onPostDeleted,
                        servicePost: servicePost,
                        canViewProfile: true,
                        userProfileId: widget.userID,
                        user: widget.user,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    String errorMessage = _errorMessage;
    if (errorMessage.contains('SocketException')) {
      errorMessage = 'No internet connection';
    }

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _handleRefreshCategoryPost,
            icon: const Icon(Icons.refresh),
          ),
          Text('Some error occurred: $errorMessage'),
        ],
      ),
    );
  }
}