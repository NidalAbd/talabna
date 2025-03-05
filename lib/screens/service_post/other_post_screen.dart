import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/service_post/service_post_card.dart';
import 'package:talbna/screens/widgets/shimmer_widgets.dart'; // Import shimmer widgets

class UserPostScreen extends StatefulWidget {
  const UserPostScreen({super.key, required this.userID, required this.user});
  final int userID;
  final User user;

  @override
  UserPostScreenState createState() => UserPostScreenState();
}

class UserPostScreenState extends State<UserPostScreen> {
  final ScrollController _scrollOtherUserController = ScrollController();
  late ServicePostBloc _servicePostBloc;
  int _currentPage = 1;
  bool _hasReachedMax = false;
  List<ServicePost> _servicePostsOtherUser = [];
  late Function onPostDeleted = (int postId) {
    setState(() {
      _servicePostsOtherUser.removeWhere((post) => post.id == postId);
    });
  };

  @override
  void initState() {
    super.initState();
    _scrollOtherUserController.addListener(_onScrollOtherUserPost);
    _servicePostBloc = BlocProvider.of<ServicePostBloc>(context);
    _handleRefreshOtherUserPost(); // Reset the state when the widget is created
  }

  void _onScrollOtherUserPost() {
    if (!_hasReachedMax &&
        _scrollOtherUserController.hasClients &&
        _scrollOtherUserController.position.pixels >=
            _scrollOtherUserController.position.maxScrollExtent - 200) {
      _currentPage++;
      _servicePostBloc
          .add(GetServicePostsByUserIdEvent(widget.userID, _currentPage));
    }
  }

  Future<void> _handleRefreshOtherUserPost() async {
    setState(() {
      _currentPage = 1;
      _hasReachedMax = false;
      _servicePostsOtherUser.clear();
    });
    _servicePostBloc
        .add(GetServicePostsByUserIdEvent(widget.userID, _currentPage));
  }

  void _handleOtherUserPostLoadSuccess(
      List<ServicePost> servicePosts, bool hasReachedMax) {
    setState(() {
      _hasReachedMax = hasReachedMax;
      _servicePostsOtherUser = [..._servicePostsOtherUser, ...servicePosts];
    });
  }

  Future<bool> _onWillPopOtherUserPost() async {
    if (_scrollOtherUserController.positions.isNotEmpty &&
        _scrollOtherUserController.offset > 0) {
      _scrollOtherUserController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInToLinear,
      );
      // Wait for the duration of the scrolling animation before refreshing
      await Future.delayed(const Duration(milliseconds: 1000));
      // Trigger a refresh after reaching the top
      _handleRefreshOtherUserPost();
      return false;
    } else {
      return true;
    }
  }

  @override
  void dispose() {
    _scrollOtherUserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPopOtherUserPost,
      child: Scaffold(
        body: BlocListener<ServicePostBloc, ServicePostState>(
          bloc: _servicePostBloc,
          listener: (context, state) {
            if (state is ServicePostLoadSuccess) {
              _handleOtherUserPostLoadSuccess(state.servicePosts, state.hasReachedMax);
            }
          },
          child: BlocBuilder<ServicePostBloc, ServicePostState>(
            bloc: _servicePostBloc,
            builder: (context, state) {
              // Initial loading state
              if (state is ServicePostLoading && _servicePostsOtherUser.isEmpty) {
                return const ServicePostScreenShimmer();
              }

              // Error state
              if (state is ServicePostLoadFailure) {
                return _buildErrorState(state.errorMessage);
              }

              // Empty state
              if (_servicePostsOtherUser.isEmpty) {
                return _buildEmptyState();
              }

              // Posts list with pagination
              return _buildPostsList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
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
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleRefreshOtherUserPost,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.post_add,
            size: 100,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Posts Yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This user hasn\'t created any posts yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    return RefreshIndicator(
      onRefresh: _handleRefreshOtherUserPost,
      child: ListView.builder(
        controller: _scrollOtherUserController,
        itemCount: _hasReachedMax
            ? _servicePostsOtherUser.length
            : _servicePostsOtherUser.length + 1,
        itemBuilder: (context, index) {
          // Pagination loading indicator
          if (index >= _servicePostsOtherUser.length) {
            return const ServicePostScreenShimmer();
          }

          // Regular post item
          final servicePost = _servicePostsOtherUser[index];
          return AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
            child: ServicePostCard(
              key: Key('servicePostProfile_${servicePost.id}'),
              onPostDeleted: onPostDeleted,
              userProfileId: widget.userID,
              servicePost: servicePost,
              canViewProfile: false,
              user: widget.user,
            ),
          );
        },
      ),
    );
  }
}