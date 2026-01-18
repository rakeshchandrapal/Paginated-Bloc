# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-18

### Added

- Initial release of `paginated_bloc_widget`
- `PaginatedDataBloc` - Generic BLoC for pagination state management
- `PaginatedDataWidget` - Flexible widget supporting multiple layouts
- `PaginatedDataRepository` - Abstract repository for data fetching
- `InMemoryPaginatedRepository` - In-memory implementation for testing
- `PaginatedResponse` - Response model with pagination metadata

### Features

- Support for ListView, GridView, PageView, and Sliver layouts
- Built-in loading, error, and empty states
- Pull-to-refresh support
- Customizable load more threshold
- Item update, remove, and add operations
- Horizontal and vertical scrolling
- Sliver headers support for CustomScrollView
- Full documentation and examples

### Layout Types

- `PaginatedLayoutType.listView`
- `PaginatedLayoutType.gridView`
- `PaginatedLayoutType.pageView`
- `PaginatedLayoutType.sliverList`
- `PaginatedLayoutType.sliverGrid`
- `PaginatedLayoutType.customScrollView`

### Events

- `LoadFirstPage` - Load initial data
- `LoadMoreData` - Load next page
- `RefreshData` - Refresh and reload
- `ResetPagination` - Reset to initial state
- `UpdateItem<T>` - Update existing item
- `RemoveItem<T>` - Remove item from list
- `AddItem<T>` - Add new item to list
