import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../config/pagination_config.dart';
import '../enums/paginated_enums.dart';
import '../repository/paginated_data_repository.dart';

part 'paginated_data_event.dart';
part 'paginated_data_state.dart';

/// A generic BLoC for handling paginated data with any data type.
///
/// This BLoC manages the pagination state including loading, error handling,
/// and data caching for efficient list rendering.
///
/// Type parameter [T] represents the type of items being paginated.
///
/// Example usage:
/// ```dart
/// final bloc = PaginatedDataBloc<User>(
///   repository: userRepository,
///   itemsPerPage: 20,
///   filters: {'status': 'active'},
/// );
///
/// // Load first page
/// bloc.add(const LoadFirstPage());
///
/// // Load more items
/// bloc.add(const LoadMoreData());
///
/// // Refresh data
/// bloc.add(const RefreshData());
/// ```
class PaginatedDataBloc<T>
    extends Bloc<PaginatedDataEvent, PaginatedDataState<T>> {
  /// The repository used to fetch paginated data.
  final PaginatedDataRepository<T> repository;

  /// Number of items to fetch per page.
  final int itemsPerPage;

  /// Optional filters to apply when fetching data.
  final Map<String, dynamic>? filters;

  /// Creates a new [PaginatedDataBloc] instance.
  ///
  /// [repository] is required and provides the data source.
  /// [itemsPerPage] defaults to [PaginationConfig.defaultItemsPerPage].
  /// [filters] are optional and passed to the repository on each request.
  PaginatedDataBloc({required this.repository, int? itemsPerPage, this.filters})
    : itemsPerPage = itemsPerPage ?? PaginationConfig.defaultItemsPerPage,
      super(PaginatedDataState<T>()) {
    on<LoadFirstPage>(_onLoadFirstPage);
    on<LoadMoreData>(_onLoadMoreData);
    on<RefreshData>(_onRefreshData);
    on<ResetPagination>(_onResetPagination);
    on<UpdateItem<T>>(_onUpdateItem);
    on<RemoveItem<T>>(_onRemoveItem);
    on<AddItem<T>>(_onAddItem);
  }

  Future<void> _onLoadFirstPage(
    LoadFirstPage event,
    Emitter<PaginatedDataState<T>> emit,
  ) async {
    emit(
      state.copyWith(status: PaginationStatus.firstPageLoading, error: null),
    );

    try {
      final response = await repository.fetchData(
        page: 1,
        limit: itemsPerPage,
        filters: filters,
      );

      emit(
        state.copyWith(
          status: PaginationStatus.firstPageSuccess,
          itemsList: response.data,
          currentPage: 1,
          hasReachedMax: !response.hasMore,
          isFirstLoad: false,
          totalItems: response.totalItems,
          totalPages: response.totalPages,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: PaginationStatus.firstPageError,
          error: error.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadMoreData(
    LoadMoreData event,
    Emitter<PaginatedDataState<T>> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore) return;

    emit(state.copyWith(status: PaginationStatus.loadingMore));

    try {
      final nextPage = state.currentPage + 1;
      final response = await repository.fetchData(
        page: nextPage,
        limit: itemsPerPage,
        filters: filters,
      );

      emit(
        state.copyWith(
          status: PaginationStatus.loadMoreSuccess,
          itemsList: List.of(state.items)..addAll(response.data),
          currentPage: nextPage,
          hasReachedMax: !response.hasMore,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: PaginationStatus.loadMoreError,
          error: error.toString(),
        ),
      );
    }
  }

  Future<void> _onRefreshData(
    RefreshData event,
    Emitter<PaginatedDataState<T>> emit,
  ) async {
    emit(state.copyWith(status: PaginationStatus.refreshing, error: null));

    try {
      final response = await repository.fetchData(
        page: 1,
        limit: itemsPerPage,
        filters: filters,
      );

      emit(
        state.copyWith(
          status: PaginationStatus.refreshSuccess,
          itemsList: response.data,
          currentPage: 1,
          hasReachedMax: !response.hasMore,
          totalItems: response.totalItems,
          totalPages: response.totalPages,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: PaginationStatus.refreshError,
          error: error.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateItem(
    UpdateItem<T> event,
    Emitter<PaginatedDataState<T>> emit,
  ) async {
    final updatedList = state.itemsList?.map((item) {
      final isMatch = event.matcher != null
          ? event.matcher!(item, event.updatedItem)
          : item == event.updatedItem;

      return isMatch ? event.updatedItem : item;
    }).toList();

    emit(state.copyWith(itemsList: updatedList));
  }

  Future<void> _onRemoveItem(
    RemoveItem<T> event,
    Emitter<PaginatedDataState<T>> emit,
  ) async {
    final updatedList = state.itemsList?.where((item) {
      return event.matcher != null ? !event.matcher!(item) : item != event.item;
    }).toList();

    emit(
      state.copyWith(
        itemsList: updatedList,
        totalItems: state.totalItems != null ? state.totalItems! - 1 : null,
      ),
    );
  }

  Future<void> _onAddItem(
    AddItem<T> event,
    Emitter<PaginatedDataState<T>> emit,
  ) async {
    final currentItems = List<T>.from(state.items);

    if (event.insertAtStart) {
      currentItems.insert(0, event.item);
    } else {
      currentItems.add(event.item);
    }

    emit(
      state.copyWith(
        itemsList: currentItems,
        totalItems: state.totalItems != null ? state.totalItems! + 1 : null,
      ),
    );
  }

  void _onResetPagination(
    ResetPagination event,
    Emitter<PaginatedDataState<T>> emit,
  ) {
    emit(PaginatedDataState<T>());
  }
}
