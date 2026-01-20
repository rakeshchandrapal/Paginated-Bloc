/// A powerful, flexible, and production-ready pagination widget for Flutter
/// using BLoC pattern.
///
/// This package provides a complete solution for implementing infinite scroll
/// pagination with support for ListView, GridView, PageView, CustomScrollView,
/// and Slivers.
///
/// ## Features
/// - Generic type support for any data model
/// - Multiple layout types (ListView, GridView, PageView, Slivers)
/// - Built-in loading, error, and empty states
/// - Pull-to-refresh support
/// - Customizable threshold for triggering load more
/// - Easy to extend with custom repositories
///
/// ## Usage
/// ```dart
/// BlocProvider(
///   create: (context) => PaginatedDataBloc<MyModel>(
///     repository: MyRepository(),
///   )..add(const LoadFirstPage()),
///   child: PaginatedDataWidget<MyModel>(
///     itemBuilder: (context, item, index) => ListTile(
///       title: Text(item.name),
///     ),
///   ),
/// )
/// ```
library paginated_bloc_widget;

// BLoC exports
export 'src/bloc/paginated_data_bloc.dart';

// Models
export 'src/models/paginated_response.dart';

// Repository
export 'src/repository/paginated_data_repository.dart';

// Enums
export 'src/enums/paginated_enums.dart';

// Widgets
export 'src/widgets/paginated_data_widget.dart';

// Configuration
export 'src/config/pagination_config.dart';
export 'src/config/pagination_theme.dart';
