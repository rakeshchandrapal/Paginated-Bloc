/// Configuration class for pagination settings.
///
/// This class provides default values and allows customization of pagination
/// behavior across the application.
///
/// Call [PaginationConfig.init] at app startup to set global defaults:
///
/// ```dart
/// void main() {
///   PaginationConfig.init(
///     itemsPerPage: 20,
///     loadMoreThreshold: 0.9,
///   );
///   runApp(MyApp());
/// }
/// ```
class PaginationConfig {
  /// Private constructor to prevent instantiation.
  PaginationConfig._();

  // ============== Mutable Global Settings ==============

  static int _itemsPerPage = 10;
  static double _loadMoreThreshold = 0.8;
  static int _pageViewLoadMoreOffset = 3;

  /// Initialize global pagination settings.
  ///
  /// Call this method once at app startup to configure defaults.
  /// These values will be used as defaults across all [PaginatedDataBloc]
  /// and [PaginatedDataWidget] instances.
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   PaginationConfig.init(
  ///     itemsPerPage: 15,
  ///     loadMoreThreshold: 0.85,
  ///     pageViewLoadMoreOffset: 2,
  ///   );
  ///   runApp(MyApp());
  /// }
  /// ```
  static void init({
    int? itemsPerPage,
    double? loadMoreThreshold,
    int? pageViewLoadMoreOffset,
  }) {
    if (itemsPerPage != null) {
      assert(itemsPerPage > 0, 'itemsPerPage must be greater than 0');
      _itemsPerPage = itemsPerPage;
    }
    if (loadMoreThreshold != null) {
      assert(
        loadMoreThreshold > 0 && loadMoreThreshold <= 1,
        'loadMoreThreshold must be between 0 and 1',
      );
      _loadMoreThreshold = loadMoreThreshold;
    }
    if (pageViewLoadMoreOffset != null) {
      assert(
        pageViewLoadMoreOffset >= 0,
        'pageViewLoadMoreOffset must be >= 0',
      );
      _pageViewLoadMoreOffset = pageViewLoadMoreOffset;
    }
  }

  /// Reset all settings to their default values.
  ///
  /// Useful for testing or resetting configuration.
  static void reset() {
    _itemsPerPage = 10;
    _loadMoreThreshold = 0.8;
    _pageViewLoadMoreOffset = 3;
  }

  // ============== Getters for Global Settings ==============

  /// Default number of items to fetch per page.
  ///
  /// This can be overridden in the [PaginatedDataBloc] constructor.
  /// Set globally via [PaginationConfig.init].
  static int get defaultItemsPerPage => _itemsPerPage;

  /// Default threshold for triggering load more (0.0 to 1.0).
  ///
  /// When the user scrolls past this percentage of the list, more items
  /// will be loaded automatically.
  /// Set globally via [PaginationConfig.init].
  static double get defaultLoadMoreThreshold => _loadMoreThreshold;

  /// Default number of pages from end to trigger load more in PageView.
  ///
  /// Set globally via [PaginationConfig.init].
  static int get defaultPageViewLoadMoreOffset => _pageViewLoadMoreOffset;
}
