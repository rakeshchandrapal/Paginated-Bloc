import 'package:flutter/widgets.dart';

/// Defines the visual properties for pagination widgets.
///
/// Used by [PaginationTheme] to provide default widget builders
/// for all [PaginatedDataWidget] descendants.
///
/// See also:
/// - [PaginationTheme], an InheritedWidget that propagates the theme.
/// - [PaginatedDataWidget], which uses these values.
class PaginationThemeData {
  /// Builder for the first page loading widget.
  ///
  /// Called when the first page is being loaded.
  final Widget Function(BuildContext context)? firstPageLoadingBuilder;

  /// Builder for the load more loading widget.
  ///
  /// Called when subsequent pages are being loaded.
  final Widget Function(BuildContext context)? loadMoreLoadingBuilder;

  /// Builder for the first page error widget.
  ///
  /// Receives the error message and a retry callback.
  final Widget Function(
    BuildContext context,
    String error,
    VoidCallback retry,
  )? firstPageErrorBuilder;

  /// Builder for the load more error widget.
  ///
  /// Receives the error message and a retry callback.
  final Widget Function(
    BuildContext context,
    String error,
    VoidCallback retry,
  )? loadMoreErrorBuilder;

  /// Builder for the empty state widget.
  ///
  /// Called when the list is empty after a successful load.
  final Widget Function(BuildContext context)? emptyBuilder;

  /// Creates a [PaginationThemeData] instance.
  ///
  /// All parameters are optional. When a builder is not provided,
  /// [PaginatedDataWidget] will use its default widget.
  const PaginationThemeData({
    this.firstPageLoadingBuilder,
    this.loadMoreLoadingBuilder,
    this.firstPageErrorBuilder,
    this.loadMoreErrorBuilder,
    this.emptyBuilder,
  });

  /// Creates a copy of this theme data with the given fields replaced.
  PaginationThemeData copyWith({
    Widget Function(BuildContext context)? firstPageLoadingBuilder,
    Widget Function(BuildContext context)? loadMoreLoadingBuilder,
    Widget Function(
      BuildContext context,
      String error,
      VoidCallback retry,
    )? firstPageErrorBuilder,
    Widget Function(
      BuildContext context,
      String error,
      VoidCallback retry,
    )? loadMoreErrorBuilder,
    Widget Function(BuildContext context)? emptyBuilder,
  }) {
    return PaginationThemeData(
      firstPageLoadingBuilder:
          firstPageLoadingBuilder ?? this.firstPageLoadingBuilder,
      loadMoreLoadingBuilder:
          loadMoreLoadingBuilder ?? this.loadMoreLoadingBuilder,
      firstPageErrorBuilder:
          firstPageErrorBuilder ?? this.firstPageErrorBuilder,
      loadMoreErrorBuilder: loadMoreErrorBuilder ?? this.loadMoreErrorBuilder,
      emptyBuilder: emptyBuilder ?? this.emptyBuilder,
    );
  }

  /// Merges this theme data with another, preferring values from [other].
  PaginationThemeData merge(PaginationThemeData? other) {
    if (other == null) return this;
    return PaginationThemeData(
      firstPageLoadingBuilder:
          other.firstPageLoadingBuilder ?? firstPageLoadingBuilder,
      loadMoreLoadingBuilder:
          other.loadMoreLoadingBuilder ?? loadMoreLoadingBuilder,
      firstPageErrorBuilder:
          other.firstPageErrorBuilder ?? firstPageErrorBuilder,
      loadMoreErrorBuilder: other.loadMoreErrorBuilder ?? loadMoreErrorBuilder,
      emptyBuilder: other.emptyBuilder ?? emptyBuilder,
    );
  }
}

/// An InheritedWidget that provides [PaginationThemeData] to its descendants.
///
/// Wrap your app or a subtree with [PaginationTheme] to provide default
/// widget builders for all [PaginatedDataWidget] descendants.
///
/// ## Example
///
/// ```dart
/// PaginationTheme(
///   data: PaginationThemeData(
///     firstPageLoadingBuilder: (context) => const Center(
///       child: CircularProgressIndicator(),
///     ),
///     emptyBuilder: (context) => const Center(
///       child: Text('No items found'),
///     ),
///   ),
///   child: MaterialApp(
///     home: MyHomePage(),
///   ),
/// )
/// ```
///
/// ## Resolution Order
///
/// Widget builders are resolved in the following order:
/// 1. Local widget parameter (passed directly to [PaginatedDataWidget])
/// 2. [PaginationTheme] data (from nearest ancestor)
/// 3. Default built-in widget
///
/// ## Scoped Overrides
///
/// You can nest [PaginationTheme] widgets to override settings for specific
/// parts of your app:
///
/// ```dart
/// PaginationTheme(
///   data: PaginationThemeData(
///     firstPageLoadingBuilder: (context) => AdminLoader(),
///   ),
///   child: AdminSection(),
/// )
/// ```
class PaginationTheme extends InheritedWidget {
  /// The pagination theme data for this subtree.
  final PaginationThemeData data;

  /// Creates a [PaginationTheme] widget.
  ///
  /// The [data] and [child] arguments must not be null.
  const PaginationTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// Returns the [PaginationThemeData] from the closest [PaginationTheme]
  /// ancestor, or null if there is no ancestor.
  ///
  /// Use this when you want to check if a theme exists without
  /// requiring one.
  static PaginationThemeData? maybeOf(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<PaginationTheme>();
    return theme?.data;
  }

  /// Returns the [PaginationThemeData] from the closest [PaginationTheme]
  /// ancestor.
  ///
  /// Returns an empty [PaginationThemeData] if no ancestor is found.
  ///
  /// Typical usage:
  /// ```dart
  /// final themeData = PaginationTheme.of(context);
  /// final loadingBuilder = themeData.firstPageLoadingBuilder;
  /// ```
  static PaginationThemeData of(BuildContext context) {
    return maybeOf(context) ?? const PaginationThemeData();
  }

  @override
  bool updateShouldNotify(PaginationTheme oldWidget) {
    return data != oldWidget.data;
  }
}
