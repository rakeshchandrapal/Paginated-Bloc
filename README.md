# Paginated BLoC Widget

[![pub package](https://img.shields.io/pub/v/paginated_bloc_widget.svg)](https://pub.dev/packages/paginated_bloc_widget)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A powerful, flexible, and production-ready pagination widget for Flutter using the BLoC pattern. This package provides a complete solution for implementing infinite scroll pagination with support for ListView, GridView, PageView, CustomScrollView, and Slivers.

## ✨ Features

- 🎯 **Generic Type Support** - Works with any data model
- 📱 **Multiple Layout Types** - ListView, GridView, PageView, Slivers
- 🔄 **Built-in States** - Loading, error, empty, and success states
- ♻️ **Pull-to-Refresh** - Native refresh indicator support
- 📏 **Customizable Threshold** - Configure when to trigger load more
- 🎨 **Fully Customizable** - Override any widget state
- 🧪 **Testable** - Includes in-memory repository for testing
- 📦 **Zero Dependencies** - Only relies on `flutter_bloc` and `equatable`

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  paginated_bloc_widget: ^1.1.0
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

### 1. Create Your Model

```dart
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
  );
}
```

### 2. Implement the Repository

```dart
import 'package:paginated_bloc_widget/paginated_bloc_widget.dart';

class UserRepository extends PaginatedDataRepository<User> {
  final ApiClient _client;

  UserRepository(this._client);

  @override
  Future<PaginatedResponse<User>> fetchData({
    required int page,
    int limit = 10,
    Map<String, dynamic>? filters,
  }) async {
    final response = await _client.getUsers(page: page, limit: limit);
    
    return PaginatedResponse(
      data: response.users.map((e) => User.fromJson(e)).toList(),
      hasMore: page < response.totalPages,
      currentPage: page,
      totalPages: response.totalPages,
      totalItems: response.totalCount,
    );
  }
}
```

### 3. Use the Widget

```dart
import 'package:paginated_bloc_widget/paginated_bloc_widget.dart';

class UserListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaginatedDataBloc<User>(
        repository: UserRepository(context.read<ApiClient>()),
        itemsPerPage: 20,
      )..add(const LoadFirstPage()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Users')),
        body: PaginatedDataWidget<User>(
          enablePullToRefresh: true,
          itemBuilder: (context, user, index) => ListTile(
            leading: CircleAvatar(child: Text(user.name[0])),
            title: Text(user.name),
            subtitle: Text(user.email),
          ),
        ),
      ),
    );
  }
}
```

## 📖 Usage Examples

### ListView with Separator

```dart
PaginatedDataWidget<User>(
  layoutType: PaginatedLayoutType.listView,
  separatorWidget: const Divider(height: 1),
  enablePullToRefresh: true,
  itemBuilder: (context, user, index) => ListTile(
    title: Text(user.name),
  ),
)
```

### GridView

```dart
PaginatedDataWidget<Product>(
  layoutType: PaginatedLayoutType.gridView,
  crossAxisCount: 2,
  childAspectRatio: 0.75,
  crossAxisSpacing: 8,
  mainAxisSpacing: 8,
  padding: const EdgeInsets.all(16),
  itemBuilder: (context, product, index) => ProductCard(product: product),
)
```

### Horizontal PageView

```dart
PaginatedDataWidget<Story>(
  layoutType: PaginatedLayoutType.pageView,
  scrollDirection: ScrollDirection.horizontal,
  enablePageSnapping: true,
  itemBuilder: (context, story, index) => StoryPage(story: story),
)
```

### CustomScrollView with Sliver Headers

```dart
PaginatedDataWidget<Item>(
  layoutType: PaginatedLayoutType.sliverList,
  sliverHeaders: [
    SliverAppBar(
      title: const Text('My Items'),
      floating: true,
    ),
    SliverToBoxAdapter(
      child: Container(
        height: 100,
        child: const Text('Header Content'),
      ),
    ),
  ],
  itemBuilder: (context, item, index) => ItemTile(item: item),
)
```

### Custom State Widgets (Local Override)

Override state widgets for a specific widget (highest priority over global theme):

```dart
PaginatedDataWidget<User>(
  firstPageLoadingWidget: const ShimmerList(),
  loadMoreLoadingWidget: const SmallLoader(),
  emptyWidget: const EmptyState(
    icon: Icons.people_outline,
    message: 'No users found',
  ),
  firstPageErrorWidget: (error, retry) => ErrorWidget(
    message: error,
    onRetry: retry,
  ),
  loadMoreErrorWidget: (error, retry) => TextButton(
    onPressed: retry,
    child: Text('Error: $error. Tap to retry'),
  ),
  itemBuilder: (context, user, index) => UserTile(user: user),
)
```

**Tip:** For app-wide consistent styling, use `PaginationTheme` instead of repeating customizations in every widget.

### With Filters

```dart
PaginatedDataBloc<User>(
  repository: userRepository,
  filters: {
    'status': 'active',
    'role': 'admin',
    'sortBy': 'createdAt',
  },
)..add(const LoadFirstPage())
```

## 🔧 BLoC Events

| Event | Description |
|-------|-------------|
| `LoadFirstPage()` | Load the first page of data |
| `LoadMoreData()` | Load the next page |
| `RefreshData()` | Refresh and reload first page |
| `ResetPagination()` | Reset to initial state |
| `UpdateItem<T>(item, matcher)` | Update an existing item |
| `RemoveItem<T>(item, matcher)` | Remove an item from the list |
| `AddItem<T>(item, insertAtStart)` | Add a new item |

### Updating Items

```dart
// Update a user in the list
context.read<PaginatedDataBloc<User>>().add(
  UpdateItem<User>(
    updatedUser,
    matcher: (oldItem, newItem) => oldItem.id == newItem.id,
  ),
);
```

### Removing Items

```dart
// Remove a user by ID
context.read<PaginatedDataBloc<User>>().add(
  RemoveItem<User>(
    matcher: (item) => item.id == deletedUserId,
  ),
);
```

### Adding Items

```dart
// Add a new user at the start
context.read<PaginatedDataBloc<User>>().add(
  AddItem<User>(newUser, insertAtStart: true),
);
```

## 📊 State Properties

Access state properties in your UI:

```dart
BlocBuilder<PaginatedDataBloc<User>, PaginatedDataState<User>>(
  builder: (context, state) {
    // Helper getters
    state.isInitial          // Initial state
    state.isFirstPageLoading // Loading first page
    state.isLoadingMore      // Loading more items
    state.isRefreshing       // Refreshing data
    state.hasError           // Any error occurred
    state.isEmpty            // No items loaded
    state.isSuccess          // Data loaded successfully
    
    // Data access
    state.items              // List of loaded items
    state.itemCount          // Number of items
    state.currentPage        // Current page number
    state.hasReachedMax      // All pages loaded
    state.totalItems         // Total items (if known)
    state.totalPages         // Total pages (if known)
    state.loadProgress       // Loading progress (0.0 - 1.0)
    state.error              // Error message
    
    return YourWidget();
  },
)
```

## 🧪 Testing

Use the included `InMemoryPaginatedRepository` for testing:

```dart
final testRepository = InMemoryPaginatedRepository<User>(
  items: List.generate(100, (i) => User(id: i, name: 'User $i')),
  simulatedDelay: const Duration(milliseconds: 500),
);

final bloc = PaginatedDataBloc<User>(
  repository: testRepository,
  itemsPerPage: 10,
);
```

## ⚙️ Configuration

### Global Configuration with PaginationConfig

Set global defaults for all pagination widgets at app startup:

```dart
void main() {
  // Initialize global pagination settings
  PaginationConfig.init(
    itemsPerPage: 20,              // Default items per page
    loadMoreThreshold: 0.85,       // Scroll threshold (0.0 to 1.0)
    pageViewLoadMoreOffset: 2,     // Pages from end to load more in PageView
  );
  
  runApp(const MyApp());
}
```

**PaginationConfig Defaults:**

| Setting | Default | Description |
|---------|---------|-------------|
| `itemsPerPage` | `10` | Number of items to fetch per page |
| `loadMoreThreshold` | `0.8` | Scroll position threshold (80% scrolled) |
| `pageViewLoadMoreOffset` | `3` | Pages from end to trigger load in PageView |

### Global Widget Theming with PaginationTheme

Provide custom widget builders for all paginated widgets in your app:

```dart
@override
Widget build(BuildContext context) {
  return PaginationTheme(
    data: PaginationThemeData(
      firstPageLoadingBuilder: (context) => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
      loadMoreLoadingBuilder: (context) => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      firstPageErrorBuilder: (context, error, retry) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: retry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      loadMoreErrorBuilder: (context, error, retry) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: retry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      emptyBuilder: (context) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No items found'),
          ],
        ),
      ),
    ),
    child: MaterialApp(
      home: MyHomePage(),
    ),
  );
}
```

### Local Widget Override

Override global theme for specific widgets (highest priority):

```dart
PaginatedDataWidget<User>(
  // These override the global PaginationTheme
  firstPageLoadingWidget: const CustomLoader(),
  loadMoreLoadingWidget: const SmallSpinner(),
  emptyWidget: const CustomEmptyState(),
  firstPageErrorWidget: (error, retry) => CustomErrorWidget(
    message: error,
    onRetry: retry,
  ),
  itemBuilder: (context, user, index) => UserTile(user: user),
)
```

**Resolution Order:**
1. Local widget parameter (passed to `PaginatedDataWidget`)
2. Global `PaginationTheme` data
3. Default built-in widget

### Complete Setup Example

```dart
void main() {
  // Step 1: Set global pagination config
  PaginationConfig.init(
    itemsPerPage: 15,
    loadMoreThreshold: 0.9,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginationTheme(
      // Step 2: Set global theme for all widgets
      data: PaginationThemeData(
        firstPageLoadingBuilder: (context) => const CustomAppLoader(),
        emptyBuilder: (context) => const CustomEmptyState(),
      ),
      child: MaterialApp(
        home: UserListPage(),
      ),
    );
  }
}

class UserListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaginatedDataBloc<User>(
        repository: UserRepository(),
        itemsPerPage: 20, // Override global config (10 → 20)
      )..add(const LoadFirstPage()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Users')),
        // Step 3: Optional - override theme for this widget only
        body: PaginatedDataWidget<User>(
          firstPageLoadingWidget: const LinearProgressIndicator(), // Override theme
          itemBuilder: (context, user, index) => UserTile(user: user),
        ),
      ),
    );
  }
}
```

### Widget Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `layoutType` | `PaginatedLayoutType` | `listView` | Layout type to use |
| `scrollDirection` | `ScrollDirection` | `vertical` | Scroll direction |
| `loadMoreThreshold` | `double?` | Global value | Scroll threshold to trigger load more |
| `enablePullToRefresh` | `bool` | `false` | Enable pull-to-refresh |
| `shrinkWrap` | `bool` | `false` | Shrink wrap content |
| `crossAxisCount` | `int?` | `2` | Grid columns |
| `childAspectRatio` | `double?` | `1.0` | Grid item aspect ratio |

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📣 Support

If you find this package helpful, please give it a ⭐ on GitHub!

For bugs and feature requests, please [open an issue](https://github.com/rakeshchandrapal/Paginated-Bloc/issues).

## 👥 Contributors

- [Yash Parmar](https://github.com/YashParmar0001)
