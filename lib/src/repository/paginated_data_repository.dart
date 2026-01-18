import '../config/pagination_config.dart';
import '../models/paginated_response.dart';

/// Abstract repository for fetching paginated data.
///
/// Implement this class to connect your data source (API, database, etc.)
/// to the pagination system.
///
/// Example implementation:
/// ```dart
/// class UserRepository extends PaginatedDataRepository<User> {
///   final ApiClient _client;
///
///   UserRepository(this._client);
///
///   @override
///   Future<PaginatedResponse<User>> fetchData({
///     required int page,
///     int limit = 10,
///     Map<String, dynamic>? filters,
///   }) async {
///     final response = await _client.getUsers(page: page, limit: limit);
///     return PaginatedResponse(
///       data: response.users,
///       hasMore: page < response.totalPages,
///       currentPage: page,
///       totalPages: response.totalPages,
///     );
///   }
/// }
/// ```
abstract class PaginatedDataRepository<T> {
  /// Fetches paginated data from the data source.
  ///
  /// [page] - The page number to fetch (1-based).
  /// [limit] - Number of items per page.
  /// [filters] - Optional filters to apply to the query.
  ///
  /// Returns a [PaginatedResponse] containing the data and pagination metadata.
  Future<PaginatedResponse<T>> fetchData({
    required int page,
    int limit = PaginationConfig.defaultItemsPerPage,
    Map<String, dynamic>? filters,
  });
}

/// A simple in-memory repository implementation for testing purposes.
///
/// This repository simulates pagination with a local list of items.
class InMemoryPaginatedRepository<T> extends PaginatedDataRepository<T> {
  /// The complete list of items to paginate.
  final List<T> items;

  /// Optional delay to simulate network latency.
  final Duration? simulatedDelay;

  /// Creates an in-memory repository with the given items.
  InMemoryPaginatedRepository({
    required this.items,
    this.simulatedDelay,
  });

  @override
  Future<PaginatedResponse<T>> fetchData({
    required int page,
    int limit = PaginationConfig.defaultItemsPerPage,
    Map<String, dynamic>? filters,
  }) async {
    if (simulatedDelay != null) {
      await Future.delayed(simulatedDelay!);
    }

    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;

    if (startIndex >= items.length) {
      return PaginatedResponse<T>(
        data: [],
        hasMore: false,
        currentPage: page,
        totalPages: (items.length / limit).ceil(),
        totalItems: items.length,
      );
    }

    final pageItems = items.sublist(
      startIndex,
      endIndex > items.length ? items.length : endIndex,
    );

    return PaginatedResponse<T>(
      data: pageItems,
      hasMore: endIndex < items.length,
      currentPage: page,
      totalPages: (items.length / limit).ceil(),
      totalItems: items.length,
    );
  }
}
