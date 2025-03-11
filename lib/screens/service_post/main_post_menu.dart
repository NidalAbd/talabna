import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/service_post/service_post_category.dart';
import 'package:talbna/screens/service_post/subcategory_grid_view.dart';
import 'package:talbna/utils/debug_logger.dart';
import 'package:talbna/blocs/category/subcategory_bloc.dart';
import 'package:talbna/blocs/category/subcategory_event.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';

class MainMenuPostScreen extends StatefulWidget {
  final int category;
  final int userID;
  final User user;
  final bool showSubcategoryGridView;
  final ServicePostBloc servicePostBloc;

  const MainMenuPostScreen({
    super.key,
    required this.category,
    required this.userID,
    required this.servicePostBloc,
    required this.showSubcategoryGridView,
    required this.user,
  });

  @override
  MainMenuPostScreenState createState() => MainMenuPostScreenState();
}

class MainMenuPostScreenState extends State<MainMenuPostScreen>
    with AutomaticKeepAliveClientMixin<MainMenuPostScreen> {

  // Keep this widget alive when switching tabs
  @override
  bool get wantKeepAlive => true;

  bool isRealScreen = false;

  // Performance tracking
  final Stopwatch _renderStopwatch = Stopwatch();

  // Cache for child widgets to avoid rebuilds
  late Widget _subcategoryWidget;
  late Widget _servicePostWidget;

  // Flag to determine if widgets have been initialized
  bool _hasInitializedWidgets = false;

  @override
  void initState() {
    super.initState();

    // Start performance tracking
    _renderStopwatch.start();

    // Phase 1: Load from cache first (show loading state)
    _loadInitialData();

    // Phase 2: After UI is displayed, refresh in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _refreshDataInBackground();
        });
      }
    });
    // Determine if this is a reals screen
    isRealScreen = widget.category == 8;

    // Initialize child widgets
    _initializeChildWidgets();

    // Prefetch subcategories if not a reals screen and not category 6
    if (!isRealScreen && widget.category != 6) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prefetchSubcategories();
      });
    }

    // For category 6, trigger service post fetching directly

  }


  void _loadInitialData() {
    // Load subcategories if showing subcategory grid view
    if (widget.showSubcategoryGridView) {
      final subcategoryBloc = BlocProvider.of<SubcategoryBloc>(context);
      subcategoryBloc.add(
        FetchSubcategories(
          categoryId: widget.category,
          showLoadingState: true,
          forceRefresh: false,
        ),
      );
    } else {
      // Load service posts
      widget.servicePostBloc.add(
        GetServicePostsByCategoryEvent(
          widget.category,
          1,
          forceRefresh: false,
        ),
      );
    }
  }

  void _refreshDataInBackground() {
    if (!mounted) return;

    // Refresh data silently in background
    if (widget.showSubcategoryGridView) {
      final subcategoryBloc = BlocProvider.of<SubcategoryBloc>(context);
      subcategoryBloc.add(
        FetchSubcategories(
          categoryId: widget.category,
          showLoadingState: false,
          forceRefresh: true,
        ),
      );
    } else {
      widget.servicePostBloc.add(
        GetServicePostsByCategoryEvent(
          widget.category,
          1,
          forceRefresh: true,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(MainMenuPostScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If category or showSubcategoryGridView changed, we need to reinitialize
    if (oldWidget.category != widget.category ||
        oldWidget.showSubcategoryGridView != widget.showSubcategoryGridView) {

      // Start performance tracking
      _renderStopwatch.reset();
      _renderStopwatch.start();

      // Update isRealScreen flag
      isRealScreen = widget.category == 8;

      // Re-initialize widgets for the new category
      _initializeChildWidgets();

      // Prefetch subcategories if not a reals screen and not category 6
      if (!isRealScreen && widget.category != 6) {
        _prefetchSubcategories();
      }

      // For category 6, trigger service post fetching directly

    }
  }

  void _initializeChildWidgets() {
    // Create the widgets only once and cache them
    _subcategoryWidget = SubcategoryListView(
      key: ValueKey('subcategory_${widget.category}'),
      categoryId: widget.category,
      userId: widget.userID,
      servicePostBloc: widget.servicePostBloc,
      userProfileBloc: BlocProvider.of<UserProfileBloc>(context),
      user: widget.user,
    );

    _servicePostWidget = ServicePostScreen(
      key: ValueKey('service_post_${widget.category}'),
      category: widget.category,
      userID: widget.userID,
      servicePostBloc: widget.servicePostBloc,
      showSubcategoryGridView: widget.showSubcategoryGridView,
      user: widget.user,
    );

    _hasInitializedWidgets = true;
  }

  void _prefetchSubcategories() {
    try {
      // Prefetch subcategories for this category
      final subcategoryBloc = BlocProvider.of<SubcategoryBloc>(context);
      subcategoryBloc.add(FetchSubcategories(
        categoryId: widget.category,
        showLoadingState: false,
      ));

      DebugLogger.log('Prefetching subcategories for category ${widget.category}',
          category: 'MAIN_MENU');
    } catch (e) {
      DebugLogger.log('Error prefetching subcategories: $e',
          category: 'MAIN_MENU');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Required for AutomaticKeepAliveClientMixin
    super.build(context);

    // Use RepaintBoundary to optimize rendering performance
    return RepaintBoundary(
      child: Stack(
        children: [
          // Special handling for category 6 (location-based)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: _hasInitializedWidgets
                ? (widget.category == 6
                ? _servicePostWidget  // Always show service posts for category 6
                : (widget.showSubcategoryGridView
                ? _subcategoryWidget
                : _servicePostWidget))
                : const Center(child: CircularProgressIndicator()),
          ),

          // Performance tracker
          _buildPerformanceOverlay(),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverlay() {
    // Stop the stopwatch if it's still running
    if (_renderStopwatch.isRunning) {
      _renderStopwatch.stop();
      DebugLogger.log(
          'MainMenuPostScreen for category ${widget.category} rendered in ${_renderStopwatch.elapsedMilliseconds}ms',
          category: 'PERFORMANCE');
    }

    // Return an empty container since we don't want to show the overlay in production
    return Container();
  }

  @override
  void dispose() {
    _renderStopwatch.stop();
    super.dispose();
  }
}