# Paginated BLoC Widget - Example

This example demonstrates how to use the `paginated_bloc_widget` package.

## Getting Started

1. Navigate to the example directory:
   ```bash
   cd example
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Examples Included

### 1. ListView Example
Basic paginated list with:
- Pull-to-refresh
- Item separators
- Tap handling

### 2. GridView Example
Grid layout with:
- 2-column grid
- Custom aspect ratio
- Card-based items

### 3. PageView Example
Page-by-page navigation with:
- Horizontal scrolling
- Page snapping
- Full-page cards

### 4. Sliver Example
CustomScrollView with:
- SliverAppBar with flexible space
- Header sections
- Floating app bar

## Key Implementation Points

### Creating a Repository

```dart
class UserRepository extends PaginatedDataRepository<User> {
  @override
  Future<PaginatedResponse<User>> fetchData({
    required int page,
    int limit = 10,
    Map<String, dynamic>? filters,
  }) async {
    // Fetch data from your API
    final response = await api.getUsers(page: page, limit: limit);
    
    return PaginatedResponse<User>(
      data: response.users,
      hasMore: page < response.totalPages,
      currentPage: page,
      totalPages: response.totalPages,
    );
  }
}
```

### Using the Widget

```dart
BlocProvider(
  create: (context) => PaginatedDataBloc<User>(
    repository: UserRepository(),
  )..add(const LoadFirstPage()),
  child: PaginatedDataWidget<User>(
    itemBuilder: (context, user, index) => ListTile(
      title: Text(user.name),
    ),
  ),
)
```
