import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// Assuming these are imported from your project structure
import '../../blocs/service_post/service_post_bloc.dart';
import '../../blocs/service_post/service_post_event.dart';
import '../../blocs/service_post/service_post_state.dart';
import '../../data/models/service_post.dart';
import '../../data/models/user.dart';
import '../../screens/service_post/service_post_card.dart';
import '../../provider/language.dart';
import '../widgets/shimmer_widgets.dart';

class FavoritePostScreen extends StatefulWidget {
  final int userID;
  final User user;

  const FavoritePostScreen({
    super.key,
    required this.userID,
    required this.user,
  });

  @override
  _FavoritePostScreenState createState() => _FavoritePostScreenState();
}

class _FavoritePostScreenState extends State<FavoritePostScreen> {
  final ScrollController _scrollController = ScrollController();
  late ServicePostBloc _servicePostBloc;

  int _currentPage = 1;
  bool _hasReachedMax = false;
  final Language _language = Language();

  List<ServicePost> _favoriteServicePosts = [];

  @override
  void initState() {
    super.initState();

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Initialize bloc and fetch initial data
    _servicePostBloc = BlocProvider.of<ServicePostBloc>(context);
    _servicePostBloc.add(GetServicePostsByUserFavouriteEvent(userId: widget.userID, page: _currentPage));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasReachedMax &&
        _scrollController.hasClients &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _currentPage++;
      _servicePostBloc.add(GetServicePostsByUserFavouriteEvent(userId: widget.userID, page: _currentPage));
    }
  }

  Future<void> _refreshFavoritePosts() async {
    setState(() {
      _currentPage = 1;
      _hasReachedMax = false;
      _favoriteServicePosts.clear();
    });
    _servicePostBloc.add(GetServicePostsByUserFavouriteEvent(userId: widget.userID, page: _currentPage));
  }

  void _handlePostDeleted(int postId) {
    setState(() {
      _favoriteServicePosts.removeWhere((post) => post.id == postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _language.tFavoriteText(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
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
            return const ServicePostScreenShimmer();
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

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
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
              ShimmerWidget.rectangular(
                width: 180,
                height: 180,
              ),
              const SizedBox(height: 16),
              ShimmerWidget.rectangular(
                height: 20,
                width: 250,
              ),
              const SizedBox(height: 8),
              ShimmerWidget.rectangular(
                height: 16,
                width: 300,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refreshFavoritePosts,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShimmerWidget.rectangular(
              width: 220,
              height: 220,
            ),
            const SizedBox(height: 16),
            ShimmerWidget.rectangular(
              height: 24,
              width: 200,
            ),
            const SizedBox(height: 8),
            ShimmerWidget.rectangular(
              height: 16,
              width: 300,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(), // Return to explore page
              icon: const Icon(Icons.explore),
              label: const Text('Explore Posts'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
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

  Widget _buildFavoritePostsList() {
    return RefreshIndicator(
      onRefresh: _refreshFavoritePosts,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
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
            child: _buildPaginationIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationIndicator() {
    // Only show loading or end indicator if there are posts
    if (_favoriteServicePosts.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show shimmer for loading more
    if (!_hasReachedMax) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: ServicePostScreenShimmer(),
      );
    }

    // Show end of list text
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Text(
          'You\'ve reached the end',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}