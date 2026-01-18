part of 'paginated_data_bloc.dart';

/// State class for [PaginatedDataBloc].
///
/// Contains all the state information for pagination including the items,
/// loading status, errors, and pagination metadata.
class PaginatedDataState<T> extends Equatable {
  /// The list of loaded items.
  final List<T>? itemsList;

  /// Current pagination status.
  final PaginationStatus status;

  /// Error message if any error occurred.
  final String? error;

  /// Current page number (1-based).
  final int currentPage;

  /// Whether all pages have been loaded.
  final bool hasReachedMax;

  /// Whether this is the first time loading data.
  final bool isFirstLoad;

  /// Total number of items available (if known).
  final int? totalItems;

  /// Total number of pages available (if known).
  final int? totalPages;

  /// Creates a new [PaginatedDataState] instance.
  const PaginatedDataState({
    this.itemsList,
    this.status = PaginationStatus.initial,
    this.error,
    this.currentPage = 0,
    this.hasReachedMax = false,
    this.isFirstLoad = true,
    this.totalItems,
    this.totalPages,
  });

  /// Creates a copy of this state with the given fields replaced.
  PaginatedDataState<T> copyWith({
    List<T>? itemsList,
    PaginationStatus? status,
    String? error,
    int? currentPage,
    bool? hasReachedMax,
    bool? isFirstLoad,
    int? totalItems,
    int? totalPages,
  }) {
    return PaginatedDataState<T>(
      itemsList: itemsList ?? this.itemsList,
      status: status ?? this.status,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFirstLoad: isFirstLoad ?? this.isFirstLoad,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  // ============== Helper Getters ==============

  /// Returns true if the status is initial (no data loaded yet).
  bool get isInitial => status == PaginationStatus.initial;

  /// Returns true if the first page is currently loading.
  bool get isFirstPageLoading => status == PaginationStatus.firstPageLoading;

  /// Returns true if more items are currently loading.
  bool get isLoadingMore => status == PaginationStatus.loadingMore;

  /// Returns true if data is currently being refreshed.
  bool get isRefreshing => status == PaginationStatus.refreshing;

  /// Returns true if any error occurred.
  bool get hasError =>
      status == PaginationStatus.firstPageError ||
      status == PaginationStatus.loadMoreError ||
      status == PaginationStatus.refreshError;

  /// Returns true if the first page loaded with an error.
  bool get hasFirstPageError => status == PaginationStatus.firstPageError;

  /// Returns true if loading more items failed.
  bool get hasLoadMoreError => status == PaginationStatus.loadMoreError;

  /// Returns true if refresh failed.
  bool get hasRefreshError => status == PaginationStatus.refreshError;

  /// Returns true if the list is empty (after loading).
  bool get isEmpty => items.isEmpty && !isFirstPageLoading && !isInitial;

  /// Returns true if data was loaded successfully.
  bool get isSuccess =>
      status == PaginationStatus.firstPageSuccess ||
      status == PaginationStatus.loadMoreSuccess ||
      status == PaginationStatus.refreshSuccess;

  /// Returns the list of items, or an empty list if null.
  List<T> get items => itemsList ?? <T>[];

  /// Returns the number of loaded items.
  int get itemCount => items.length;

  /// Returns the loading progress as a percentage (0.0 to 1.0).
  ///
  /// Returns null if total items is unknown.
  double? get loadProgress {
    if (totalItems == null || totalItems == 0) return null;
    return items.length / totalItems!;
  }

  @override
  List<Object?> get props => [
        itemsList,
        status,
        error,
        currentPage,
        hasReachedMax,
        isFirstLoad,
        totalItems,
        totalPages,
      ];

  @override
  String toString() {
    return 'PaginatedDataState('
        'status: $status, '
        'items: ${items.length}, '
        'page: $currentPage, '
        'hasReachedMax: $hasReachedMax, '
        'error: $error)';
  }
}
