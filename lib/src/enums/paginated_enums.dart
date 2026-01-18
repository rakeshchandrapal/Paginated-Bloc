/// Status enum representing all possible states during pagination.
///
/// Use these states to track the current pagination status and render
/// appropriate UI elements.
enum PaginationStatus {
  /// Initial state before any data is loaded.
  initial,

  /// Loading the first page of data.
  firstPageLoading,

  /// First page loaded successfully.
  firstPageSuccess,

  /// Error occurred while loading the first page.
  firstPageError,

  /// Loading more data (subsequent pages).
  loadingMore,

  /// Successfully loaded more data.
  loadMoreSuccess,

  /// Error occurred while loading more data.
  loadMoreError,

  /// Currently refreshing the data.
  refreshing,

  /// Data refreshed successfully.
  refreshSuccess,

  /// Error occurred during refresh.
  refreshError,
}

/// Layout types supported by [PaginatedDataWidget].
///
/// Choose the appropriate layout based on your UI requirements.
enum PaginatedLayoutType {
  /// Standard scrollable list.
  listView,

  /// Sliver-based list for use in CustomScrollView.
  sliverList,

  /// Grid layout with multiple columns.
  gridView,

  /// Sliver-based grid for use in CustomScrollView.
  sliverGrid,

  /// Custom scroll view with sliver support.
  customScrollView,

  /// Page-by-page view with snapping.
  pageView,
}

/// Scroll direction for the paginated widget.
enum ScrollDirection {
  /// Vertical scrolling (default).
  vertical,

  /// Horizontal scrolling.
  horizontal,
}
