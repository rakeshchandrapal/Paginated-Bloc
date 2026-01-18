/// Configuration class for pagination settings.
///
/// This class provides default values and allows customization of pagination
/// behavior across the application.
class PaginationConfig {
  /// Default number of items to fetch per page.
  ///
  /// This can be overridden in the [PaginatedDataBloc] constructor.
  static const int defaultItemsPerPage = 10;

  /// Default threshold for triggering load more.
  ///
  /// When the user scrolls past this percentage of the list, more items
  /// will be loaded automatically.
  static const double defaultLoadMoreThreshold = 0.8;

  /// Default number of pages from end to trigger load more in PageView.
  static const int defaultPageViewLoadMoreOffset = 3;

  /// Private constructor to prevent instantiation.
  PaginationConfig._();
}
