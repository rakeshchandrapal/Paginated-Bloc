part of 'paginated_data_bloc.dart';

/// Base class for all pagination events.
///
/// All events that can be dispatched to [PaginatedDataBloc] extend this class.
abstract class PaginatedDataEvent extends Equatable {
  const PaginatedDataEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load the first page of data.
///
/// Dispatch this event when initializing the list or when you want to
/// reload from scratch.
class LoadFirstPage extends PaginatedDataEvent {
  const LoadFirstPage();
}

/// Event to load more data (next page).
///
/// Dispatch this event when the user scrolls near the end of the list.
/// The bloc will automatically handle pagination state and prevent
/// duplicate requests.
class LoadMoreData extends PaginatedDataEvent {
  const LoadMoreData();
}

/// Event to refresh the data.
///
/// Dispatch this event for pull-to-refresh functionality.
/// This reloads the first page while potentially keeping the scroll position.
class RefreshData extends PaginatedDataEvent {
  const RefreshData();
}

/// Event to reset pagination to initial state.
///
/// Dispatch this event to clear all loaded data and reset to initial state.
class ResetPagination extends PaginatedDataEvent {
  const ResetPagination();
}

/// Event to update an existing item in the list.
///
/// Use [matcher] to find the item to update. If [matcher] is null,
/// equality comparison is used.
///
/// Example:
/// ```dart
/// bloc.add(UpdateItem<User>(
///   updatedUser,
///   matcher: (oldItem, newItem) => oldItem.id == newItem.id,
/// ));
/// ```
class UpdateItem<T> extends PaginatedDataEvent {
  /// The updated item to replace in the list.
  final T updatedItem;

  /// Optional matcher function to find the item to update.
  final bool Function(T oldItem, T newItem)? matcher;

  const UpdateItem(this.updatedItem, {this.matcher});

  @override
  List<Object?> get props => [updatedItem, matcher];
}

/// Event to remove an item from the list.
///
/// Use either [item] with equality comparison or [matcher] for custom matching.
///
/// Example:
/// ```dart
/// bloc.add(RemoveItem<User>(
///   matcher: (item) => item.id == deletedId,
/// ));
/// ```
class RemoveItem<T> extends PaginatedDataEvent {
  /// The item to remove (uses equality comparison).
  final T? item;

  /// Optional matcher function to find the item to remove.
  final bool Function(T item)? matcher;

  const RemoveItem({this.item, this.matcher})
      : assert(
          item != null || matcher != null,
          'Either item or matcher must be provided',
        );

  @override
  List<Object?> get props => [item, matcher];
}

/// Event to add a new item to the list.
///
/// By default, items are added at the end. Set [insertAtStart] to true
/// to prepend the item.
///
/// Example:
/// ```dart
/// bloc.add(AddItem<User>(newUser, insertAtStart: true));
/// ```
class AddItem<T> extends PaginatedDataEvent {
  /// The item to add to the list.
  final T item;

  /// Whether to insert at the start of the list.
  final bool insertAtStart;

  const AddItem(this.item, {this.insertAtStart = false});

  @override
  List<Object?> get props => [item, insertAtStart];
}
