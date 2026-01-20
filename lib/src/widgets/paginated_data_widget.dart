import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/paginated_data_bloc.dart';
import '../config/pagination_config.dart';
import '../config/pagination_theme.dart';
import '../enums/paginated_enums.dart';

/// A flexible widget for displaying paginated data with various layout types.
///
/// This widget automatically handles loading states, error states, empty states,
/// and infinite scrolling. It integrates with [PaginatedDataBloc] for state management.
///
/// Supports multiple layout types:
/// - [PaginatedLayoutType.listView] - Standard scrollable list
/// - [PaginatedLayoutType.gridView] - Grid layout
/// - [PaginatedLayoutType.sliverList] - Sliver-based list
/// - [PaginatedLayoutType.sliverGrid] - Sliver-based grid
/// - [PaginatedLayoutType.customScrollView] - Custom scroll view with slivers
/// - [PaginatedLayoutType.pageView] - Page-by-page view
///
/// Example usage:
/// ```dart
/// BlocProvider(
///   create: (context) => PaginatedDataBloc<User>(
///     repository: userRepository,
///   )..add(const LoadFirstPage()),
///   child: PaginatedDataWidget<User>(
///     layoutType: PaginatedLayoutType.listView,
///     enablePullToRefresh: true,
///     itemBuilder: (context, user, index) => ListTile(
///       leading: CircleAvatar(child: Text(user.initials)),
///       title: Text(user.name),
///       subtitle: Text(user.email),
///     ),
///     emptyWidget: const Center(child: Text('No users found')),
///   ),
/// )
/// ```
class PaginatedDataWidget<T> extends StatefulWidget {
  // ============== Core Properties ==============

  /// Builder function to create a widget for each item.
  ///
  /// This is required and provides the item, index, and context.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  // ============== Layout Configuration ==============

  /// The type of layout to use for displaying items.
  final PaginatedLayoutType layoutType;

  /// The scroll direction of the list.
  final ScrollDirection scrollDirection;

  /// Whether to reverse the scroll direction.
  final bool reverse;

  // ============== Grid Properties ==============

  /// Custom grid delegate for grid layouts.
  ///
  /// If not provided, a default delegate is created using [crossAxisCount],
  /// [childAspectRatio], [crossAxisSpacing], and [mainAxisSpacing].
  final SliverGridDelegate? gridDelegate;

  /// Number of columns in the grid.
  final int? crossAxisCount;

  /// Aspect ratio of grid children.
  final double? childAspectRatio;

  /// Spacing between columns.
  final double? crossAxisSpacing;

  /// Spacing between rows.
  final double? mainAxisSpacing;

  // ============== Scroll Configuration ==============

  /// External scroll controller.
  ///
  /// If provided, the widget will not manage the controller's lifecycle.
  final ScrollController? scrollController;

  /// Scroll physics for the list.
  final ScrollPhysics? physics;

  /// Padding around the list.
  final EdgeInsetsGeometry? padding;

  /// Whether the list should shrink-wrap its content.
  final bool shrinkWrap;

  /// Restoration ID for scroll position restoration.
  final String? restorationId;

  /// Clip behavior for the list.
  final Clip clipBehavior;

  // ============== State Widgets ==============

  /// Widget to show while loading the first page.
  final Widget? firstPageLoadingWidget;

  /// Widget to show while loading more items.
  final Widget? loadMoreLoadingWidget;

  /// Builder for first page error widget.
  final Widget Function(String error, VoidCallback retry)? firstPageErrorWidget;

  /// Builder for load more error widget.
  final Widget Function(String error, VoidCallback retry)? loadMoreErrorWidget;

  /// Widget to show when the list is empty.
  final Widget? emptyWidget;

  /// Widget to show between items in list view.
  final Widget? separatorWidget;

  // ============== Sliver Properties ==============

  /// List of sliver widgets to add before the main content.
  final List<Widget>? sliverHeaders;

  /// App bar widget for NestedScrollView layouts.
  final Widget? appBar;

  /// Whether sliver headers should be pinned.
  final bool pinHeaders;

  // ============== Load More Configuration ==============

  /// Threshold for triggering load more (0.0 to 1.0).
  ///
  /// When the user scrolls past this percentage of the list,
  /// more items are loaded.
  final double? loadMoreThreshold;

  /// Whether to enable pull-to-refresh functionality.
  final bool enablePullToRefresh;

  // ============== PageView Properties ==============

  /// Whether page snapping is enabled for PageView layout.
  final bool enablePageSnapping;

  /// External page controller for PageView layout.
  final PageController? pageController;

  /// Creates a new [PaginatedDataWidget] instance.
  const PaginatedDataWidget({
    super.key,
    required this.itemBuilder,
    this.layoutType = PaginatedLayoutType.listView,
    this.scrollDirection = ScrollDirection.vertical,
    this.reverse = false,
    this.gridDelegate,
    this.crossAxisCount,
    this.childAspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.scrollController,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
    this.restorationId,
    this.clipBehavior = Clip.antiAlias,
    this.firstPageLoadingWidget,
    this.loadMoreLoadingWidget,
    this.firstPageErrorWidget,
    this.loadMoreErrorWidget,
    this.emptyWidget,
    this.separatorWidget,
    this.sliverHeaders,
    this.appBar,
    this.pinHeaders = false,
    this.loadMoreThreshold,
    this.enablePullToRefresh = false,
    this.enablePageSnapping = true,
    this.pageController,
  });

  @override
  State<PaginatedDataWidget<T>> createState() => _PaginatedDataWidgetState<T>();
}

class _PaginatedDataWidgetState<T> extends State<PaginatedDataWidget<T>> {
  late ScrollController _scrollController;
  late PageController _pageController;
  bool _isExternalScrollController = false;
  bool _isExternalPageController = false;

  @override
  void initState() {
    super.initState();

    if (widget.scrollController != null) {
      _scrollController = widget.scrollController!;
      _isExternalScrollController = true;
    } else {
      _scrollController = ScrollController();
    }

    if (widget.pageController != null) {
      _pageController = widget.pageController!;
      _isExternalPageController = true;
    } else {
      _pageController = PageController();
    }

    if (widget.layoutType != PaginatedLayoutType.pageView) {
      _scrollController.addListener(_onScroll);
    } else {
      _pageController.addListener(_onPageScroll);
    }
  }

  @override
  void dispose() {
    if (!_isExternalScrollController) {
      _scrollController.removeListener(_onScroll);
      _scrollController.dispose();
    }
    if (!_isExternalPageController) {
      _pageController.removeListener(_onPageScroll);
      _pageController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_shouldLoadMore) {
      context.read<PaginatedDataBloc<T>>().add(const LoadMoreData());
    }
  }

  void _onPageScroll() {
    final currentPage = _pageController.page?.round() ?? 0;
    final totalPages = context.read<PaginatedDataBloc<T>>().state.items.length;

    if (currentPage >=
        totalPages - PaginationConfig.defaultPageViewLoadMoreOffset) {
      context.read<PaginatedDataBloc<T>>().add(const LoadMoreData());
    }
  }

  /// Checks if the viewport is not filled and loads more data if needed.
  ///
  /// This is called after successful data loads to handle cases where
  /// the initial items don't fill the viewport (making scroll impossible).
  void _checkAndLoadMoreIfNeeded() {
    // Skip for PageView as it has its own pagination logic
    if (widget.layoutType == PaginatedLayoutType.pageView) return;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;

      final state = context.read<PaginatedDataBloc<T>>().state;
      if (state.hasReachedMax || state.isLoadingMore) return;

      // If content doesn't fill the viewport, load more
      if (_scrollController.position.maxScrollExtent == 0) {
        context.read<PaginatedDataBloc<T>>().add(const LoadMoreData());
      }
    });
  }

  bool get _shouldLoadMore {
    if (!_scrollController.hasClients) return false;

    final state = context.read<PaginatedDataBloc<T>>().state;

    // Don't load more if already loading or reached max
    if (state.hasReachedMax || state.isLoadingMore) return false;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    // If content doesn't fill the screen, maxScroll will be 0
    // In that case, we should load more if not at max
    if (maxScroll == 0) return true;

    return currentScroll >=
        (maxScroll *
            (widget.loadMoreThreshold ??
                PaginationConfig.defaultLoadMoreThreshold));
  }

  SliverGridDelegate get _effectiveGridDelegate {
    if (widget.gridDelegate != null) return widget.gridDelegate!;

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: widget.crossAxisCount ?? 2,
      childAspectRatio: widget.childAspectRatio ?? 1.0,
      crossAxisSpacing: widget.crossAxisSpacing ?? 0.0,
      mainAxisSpacing: widget.mainAxisSpacing ?? 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaginatedDataBloc<T>, PaginatedDataState<T>>(
      listenWhen: (previous, current) {
        // Listen only for success states that might need viewport fill check
        return current.status == PaginationStatus.firstPageSuccess ||
            current.status == PaginationStatus.loadMoreSuccess ||
            current.status == PaginationStatus.refreshSuccess;
      },
      listener: (context, state) {
        _checkAndLoadMoreIfNeeded();
      },
      child: BlocBuilder<PaginatedDataBloc<T>, PaginatedDataState<T>>(
        builder: (context, state) {
          final theme = PaginationTheme.of(context);

          // First page loading
          if (state.isFirstPageLoading) {
            return widget.firstPageLoadingWidget ??
                theme.firstPageLoadingBuilder?.call(context) ??
                _buildDefaultLoadingWidget();
          }

          // First page error
          if (state.status == PaginationStatus.firstPageError) {
            final error =
                state.error ?? 'Something went wrong. Please try again.';
            void retry() => context.read<PaginatedDataBloc<T>>().add(
                  const LoadFirstPage(),
                );
            return widget.firstPageErrorWidget?.call(error, retry) ??
                theme.firstPageErrorBuilder?.call(context, error, retry) ??
                _buildDefaultErrorWidget(state.error, isFirstPage: true);
          }

          // Empty state
          if (state.isEmpty) {
            return widget.emptyWidget ??
                theme.emptyBuilder?.call(context) ??
                _buildDefaultEmptyWidget();
          }

          // Build the appropriate layout
          return _buildLayout(state);
        },
      ),
    );
  }

  Widget _buildLayout(PaginatedDataState<T> state) {
    switch (widget.layoutType) {
      case PaginatedLayoutType.listView:
        return _buildListView(state);
      case PaginatedLayoutType.sliverList:
        return _buildSliverLayout(state);
      case PaginatedLayoutType.gridView:
        return _buildGridView(state);
      case PaginatedLayoutType.sliverGrid:
        return _buildSliverLayout(state);
      case PaginatedLayoutType.customScrollView:
        return _buildCustomScrollView(state);
      case PaginatedLayoutType.pageView:
        return _buildPageView(state);
    }
  }

  Widget _buildListView(PaginatedDataState<T> state) {
    final content = ListView.separated(
      controller: _scrollController,
      scrollDirection: _getAxisDirection(),
      reverse: widget.reverse,
      padding: widget.padding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      itemCount: state.items.length + (state.hasReachedMax ? 0 : 1),
      separatorBuilder: (context, index) {
        if (index < state.items.length - 1) {
          return widget.separatorWidget ?? const SizedBox.shrink();
        }
        return const SizedBox.shrink();
      },
      itemBuilder: (context, index) => _buildListItem(state, index),
    );

    return widget.enablePullToRefresh
        ? RefreshIndicator(onRefresh: _onRefresh, child: content)
        : content;
  }

  Widget _buildGridView(PaginatedDataState<T> state) {
    final theme = PaginationTheme.of(context);

    // Build the load more widget separately for grids
    Widget? loadMoreWidget;
    if (!state.hasReachedMax) {
      if (state.isLoadingMore) {
        loadMoreWidget = widget.loadMoreLoadingWidget ??
            theme.loadMoreLoadingBuilder?.call(context) ??
            _buildLoadMoreIndicator();
      } else if (state.status == PaginationStatus.loadMoreError) {
        final error = state.error ?? 'Unknown error';
        void retry() =>
            context.read<PaginatedDataBloc<T>>().add(const LoadMoreData());
        loadMoreWidget = widget.loadMoreErrorWidget?.call(error, retry) ??
            theme.loadMoreErrorBuilder?.call(context, error, retry) ??
            _buildLoadMoreErrorWidget(state.error);
      }
    }

    // Always use CustomScrollView for consistency to avoid scroll position reset
    final slivers = <Widget>[
      SliverPadding(
        padding: widget.padding ?? EdgeInsets.zero,
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                widget.itemBuilder(context, state.items[index], index),
            childCount: state.items.length,
          ),
          gridDelegate: _effectiveGridDelegate,
        ),
      ),
      if (loadMoreWidget != null)
        SliverToBoxAdapter(child: loadMoreWidget),
    ];

    final content = CustomScrollView(
      controller: _scrollController,
      scrollDirection: _getAxisDirection(),
      reverse: widget.reverse,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      slivers: slivers,
    );

    return widget.enablePullToRefresh
        ? RefreshIndicator(onRefresh: _onRefresh, child: content)
        : content;
  }

  Widget _buildSliverLayout(PaginatedDataState<T> state) {
    return _buildCustomScrollView(state);
  }

  Widget _buildCustomScrollView(PaginatedDataState<T> state) {
    final slivers = <Widget>[];
    final theme = PaginationTheme.of(context);

    // Add custom headers
    if (widget.sliverHeaders != null) {
      slivers.addAll(widget.sliverHeaders!);
    }

    // Add main content sliver
    if (widget.layoutType == PaginatedLayoutType.gridView ||
        widget.layoutType == PaginatedLayoutType.sliverGrid) {
      slivers.add(_buildSliverGridOnly(state));

      // Add load more widget as separate sliver for grids (centered)
      if (!state.hasReachedMax) {
        Widget? loadMoreWidget;
        if (state.isLoadingMore) {
          loadMoreWidget = widget.loadMoreLoadingWidget ??
              theme.loadMoreLoadingBuilder?.call(context) ??
              _buildLoadMoreIndicator();
        } else if (state.status == PaginationStatus.loadMoreError) {
          final error = state.error ?? 'Unknown error';
          void retry() =>
              context.read<PaginatedDataBloc<T>>().add(const LoadMoreData());
          loadMoreWidget = widget.loadMoreErrorWidget?.call(error, retry) ??
              theme.loadMoreErrorBuilder?.call(context, error, retry) ??
              _buildLoadMoreErrorWidget(state.error);
        }
        if (loadMoreWidget != null) {
          slivers.add(SliverToBoxAdapter(child: loadMoreWidget));
        }
      }
    } else {
      slivers.add(_buildSliverList(state));
    }

    final scrollView = CustomScrollView(
      controller: _scrollController,
      scrollDirection: _getAxisDirection(),
      reverse: widget.reverse,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      slivers: slivers,
    );

    if (widget.appBar != null) {
      return NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [widget.appBar!],
        body: widget.enablePullToRefresh
            ? RefreshIndicator(onRefresh: _onRefresh, child: scrollView)
            : scrollView,
      );
    }

    return widget.enablePullToRefresh
        ? RefreshIndicator(onRefresh: _onRefresh, child: scrollView)
        : scrollView;
  }

  Widget _buildSliverList(PaginatedDataState<T> state) {
    return SliverPadding(
      padding: widget.padding ?? EdgeInsets.zero,
      sliver: SliverList.separated(
        itemCount: state.items.length + (state.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) => _buildListItem(state, index),
        separatorBuilder: (context, index) {
          if (index < state.items.length - 1) {
            return widget.separatorWidget ?? const SizedBox.shrink();
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSliverGridOnly(PaginatedDataState<T> state) {
    return SliverPadding(
      padding: widget.padding ?? EdgeInsets.zero,
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) =>
              widget.itemBuilder(context, state.items[index], index),
          childCount: state.items.length,
        ),
        gridDelegate: _effectiveGridDelegate,
      ),
    );
  }

  Widget _buildPageView(PaginatedDataState<T> state) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: _getAxisDirection(),
      reverse: widget.reverse,
      physics: widget.physics,
      pageSnapping: widget.enablePageSnapping,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      itemCount: state.items.length + (state.hasReachedMax ? 0 : 1),
      itemBuilder: (context, index) => _buildPageItem(state, index),
    );
  }

  Widget _buildListItem(PaginatedDataState<T> state, int index) {
    // Regular item
    if (index < state.items.length) {
      return widget.itemBuilder(context, state.items[index], index);
    }

    final theme = PaginationTheme.of(context);

    // Loading more indicator or error
    if (state.isLoadingMore) {
      return widget.loadMoreLoadingWidget ??
          theme.loadMoreLoadingBuilder?.call(context) ??
          _buildLoadMoreIndicator();
    } else if (state.status == PaginationStatus.loadMoreError) {
      final error = state.error ?? 'Unknown error';
      void retry() =>
          context.read<PaginatedDataBloc<T>>().add(const LoadMoreData());
      return widget.loadMoreErrorWidget?.call(error, retry) ??
          theme.loadMoreErrorBuilder?.call(context, error, retry) ??
          _buildLoadMoreErrorWidget(state.error);
    }

    return const SizedBox.shrink();
  }

  Widget _buildPageItem(PaginatedDataState<T> state, int index) {
    // Regular item
    if (index < state.items.length) {
      return Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: widget.itemBuilder(context, state.items[index], index),
      );
    }

    final theme = PaginationTheme.of(context);

    // Loading more indicator
    if (state.isLoadingMore) {
      return widget.loadMoreLoadingWidget ??
          theme.loadMoreLoadingBuilder?.call(context) ??
          _buildLoadMoreIndicator();
    }

    return const SizedBox.shrink();
  }

  Axis _getAxisDirection() {
    return widget.scrollDirection == ScrollDirection.horizontal
        ? Axis.horizontal
        : Axis.vertical;
  }

  Future<void> _onRefresh() async {
    context.read<PaginatedDataBloc<T>>().add(const RefreshData());
    await context.read<PaginatedDataBloc<T>>().stream.firstWhere(
          (state) => state.status != PaginationStatus.refreshing,
        );
  }

  // ============== Default Widgets ==============

  Widget _buildDefaultLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading...'),
        ],
      ),
    );
  }

  Widget _buildDefaultErrorWidget(String? error, {bool isFirstPage = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              isFirstPage ? 'Failed to load data' : 'Failed to load more items',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (isFirstPage) {
                  context.read<PaginatedDataBloc<T>>().add(
                        const LoadFirstPage(),
                      );
                } else {
                  context.read<PaginatedDataBloc<T>>().add(
                        const LoadMoreData(),
                      );
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Text(
            'There are no items to display',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (widget.scrollDirection == ScrollDirection.horizontal) {
      return const SizedBox(
        width: 60,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildLoadMoreErrorWidget(String? error) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Failed to load more items',
            style: TextStyle(color: Colors.red[700]),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              context.read<PaginatedDataBloc<T>>().add(const LoadMoreData());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
