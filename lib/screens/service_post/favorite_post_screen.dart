import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';

// Assuming these are imported from your project structure
import '../../blocs/service_post/service_post_bloc.dart';
import '../../blocs/service_post/service_post_event.dart';
import '../../blocs/service_post/service_post_state.dart';
import '../../data/models/service_post.dart';
import '../../data/models/user.dart';
import '../../screens/service_post/service_post_card.dart';
import '../../provider/language.dart';

class FavoritePostScreen extends StatefulWidget {
  final int userID;
  final User user;

  const FavoritePostScreen({
    super.key,
    required this.userID,
    required this.user
  });

  @override
  _FavoritePostScreenState createState() => _FavoritePostScreenState();
}

class _FavoritePostScreenState extends State<FavoritePostScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late ServicePostBloc _servicePostBloc;
  late AnimationController _animationController;

  int _currentPage = 1;
  bool _hasReachedMax = false;
  final Language _language = Language();

  List<ServicePost> _favoriteServicePosts = [];

  @override
  void initState() {
    super.initState();

    // Animation controller for loading and empty states
    _animationController = AnimationController(vsync: this);

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Initialize bloc and fetch initial data
    _servicePostBloc = BlocProvider.of<ServicePostBloc>(context);
    _servicePostBloc.add(GetServicePostsByUserFavouriteEvent(widget.userID, _currentPage));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _favoriteServicePosts.clear();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasReachedMax &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _currentPage++;
      _servicePostBloc.add(GetServicePostsByUserFavouriteEvent(widget.userID, _currentPage));
    }
  }

  Future<void> _refreshFavoritePosts() async {
    setState(() {
      _currentPage = 1;
      _hasReachedMax = false;
      _favoriteServicePosts.clear();
    });
    _servicePostBloc.add(GetServicePostsByUserFavouriteEvent(widget.userID, _currentPage));
  }

  void _handlePostDeleted(int postId) {
    setState(() {
      _favoriteServicePosts.removeWhere((post) => post.id == postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? const Color(0xFFF5F7FA)
          : const Color(0xFF1A1D21),
      appBar: AppBar(
        title: Text(
          _language.tFavoriteText(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocConsumer<ServicePostBloc, ServicePostState>(
        listener: (context, state) {
          if (state is ServicePostLoadSuccess) {
            setState(() {
              _hasReachedMax = state.hasReachedMax;
              _favoriteServicePosts = [
                ..._favoriteServicePosts,
                ...state.servicePosts
              ];
            });
          }
        },
        builder: (context, state) {
          // Loading state (first page)
          if (state is ServicePostLoading && _favoriteServicePosts.isEmpty) {
            return _buildLoadingState();
          }

          // Error state
          if (state is ServicePostLoadFailure) {
            return _buildErrorState(state.errorMessage);
          }

          // Empty state
          if (_favoriteServicePosts.isEmpty) {
            return _buildEmptyState();
          }

          // Favorite posts list
          return _buildFavoritePostsList();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/loading.json',
            controller: _animationController,
            onLoaded: (composition) {
              _animationController
                ..duration = composition.duration
                ..forward();
            },
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your favorites...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/error.json',
              width: 180,
              height: 180,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshFavoritePosts,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/empty_favorite.json',
            width: 220,
            height: 220,
          ),
          const SizedBox(height: 16),
          Text(
            'No Favorites Yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Text(
              'Find posts you love and tap the heart to see them here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop(); // Return to explore page
            },
            icon: const Icon(Icons.explore),
            label: const Text('Explore Posts'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritePostsList() {
    return RefreshIndicator(
      onRefresh: _refreshFavoritePosts,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // User favorites section header
          // Small spacing at the top
          SliverToBoxAdapter(
            child: const SizedBox(height: 8),
          ),

          // Favorite posts list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final servicePost = _favoriteServicePosts[index];

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                          child: ServicePostCard(
                            key: ValueKey(servicePost.id),
                            onPostDeleted: _handlePostDeleted,
                            userProfileId: widget.userID,
                            servicePost: servicePost,
                            canViewProfile: false,
                            user: widget.user,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: _favoriteServicePosts.length,
              ),
            ),
          ),

          // Loading indicator at the bottom for pagination
          SliverToBoxAdapter(
            child: !_hasReachedMax
                ? Padding(
              padding: const EdgeInsets.all(2.0),
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            )
                : _favoriteServicePosts.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'You\'ve reached the end',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}