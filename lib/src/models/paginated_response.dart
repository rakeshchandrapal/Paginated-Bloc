/// A response model for paginated data from any data source.
///
/// This class encapsulates the paginated response with all necessary
/// metadata for proper pagination handling.
///
/// Example usage:
/// ```dart
/// final response = PaginatedResponse<User>(
///   data: users,
///   hasMore: page < totalPages,
///   currentPage: page,
///   totalPages: 10,
///   totalItems: 100,
/// );
/// ```
class PaginatedResponse<T> {
  /// The list of items for the current page.
  final List<T> data;

  /// The current page number (optional).
  final int? currentPage;

  /// Total number of pages available (optional).
  final int? totalPages;

  /// Total number of items across all pages (optional).
  final int? totalItems;

  /// Whether there are more pages to load.
  ///
  /// This is required and determines if the pagination should continue.
  final bool hasMore;

  /// Creates a new [PaginatedResponse] instance.
  ///
  /// [data] and [hasMore] are required. Other fields are optional and
  /// can be used for additional UI features like progress indicators.
  const PaginatedResponse({
    required this.data,
    this.currentPage,
    this.totalPages,
    this.totalItems,
    required this.hasMore,
  });

  /// Creates an empty response with no items.
  factory PaginatedResponse.empty() => PaginatedResponse<T>(
        data: const [],
        hasMore: false,
      );

  /// Creates a response from a JSON map.
  ///
  /// [fromJson] is a function that converts each item from JSON.
  /// [dataKey] is the key in the map containing the list of items.
  /// [hasMoreKey] is the key indicating if more pages exist.
  factory PaginatedResponse.fromMap(
    Map<String, dynamic> map, {
    required T Function(Map<String, dynamic>) fromJson,
    String dataKey = 'data',
    String hasMoreKey = 'hasMore',
    String? currentPageKey,
    String? totalPagesKey,
    String? totalItemsKey,
  }) {
    final List<dynamic> rawData = map[dataKey] ?? [];

    return PaginatedResponse<T>(
      data: rawData.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      hasMore: map[hasMoreKey] ?? false,
      currentPage: currentPageKey != null ? map[currentPageKey] : null,
      totalPages: totalPagesKey != null ? map[totalPagesKey] : null,
      totalItems: totalItemsKey != null ? map[totalItemsKey] : null,
    );
  }

  /// Converts this response to a JSON map.
  Map<String, dynamic> toMap({
    required Map<String, dynamic> Function(T) toJson,
  }) {
    return {
      'data': data.map((e) => toJson(e)).toList(),
      'hasMore': hasMore,
      if (currentPage != null) 'currentPage': currentPage,
      if (totalPages != null) 'totalPages': totalPages,
      if (totalItems != null) 'totalItems': totalItems,
    };
  }

  @override
  String toString() {
    return 'PaginatedResponse(data: ${data.length} items, hasMore: $hasMore, '
        'currentPage: $currentPage, totalPages: $totalPages, totalItems: $totalItems)';
  }
}
