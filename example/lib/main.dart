import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paginated_bloc_widget/paginated_bloc_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paginated BLoC Widget Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagination Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          _buildExampleTile(
            context,
            'ListView Example',
            'Basic list with pagination',
            Icons.list,
            const ListViewExample(),
          ),
          _buildExampleTile(
            context,
            'GridView Example',
            'Grid layout with pagination',
            Icons.grid_view,
            const GridViewExample(),
          ),
          _buildExampleTile(
            context,
            'PageView Example',
            'Page-by-page navigation',
            Icons.view_carousel,
            const PageViewExample(),
          ),
          _buildExampleTile(
            context,
            'CustomScrollView Example',
            'With sliver headers',
            Icons.view_agenda,
            const SliverExample(),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Widget page,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      ),
    );
  }
}

// ============================================================
// Sample User Model
// ============================================================

class User {
  final int id;
  final String name;
  final String email;
  final String avatar;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
  });
}

// ============================================================
// Sample Repository using InMemoryPaginatedRepository
// ============================================================

class UserRepository extends PaginatedDataRepository<User> {
  final List<User> _users = List.generate(
    100,
    (index) => User(
      id: index + 1,
      name: 'User ${index + 1}',
      email: 'user${index + 1}@example.com',
      avatar: 'https://i.pravatar.cc/150?img=${(index % 70) + 1}',
    ),
  );

  @override
  Future<PaginatedResponse<User>> fetchData({
    required int page,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate occasional errors for demo
    // if (page == 3 && Random().nextBool()) {
    //   throw Exception('Simulated network error');
    // }

    final effectiveLimit = limit ?? 10;
    final startIndex = (page - 1) * effectiveLimit;
    final endIndex = startIndex + effectiveLimit;

    if (startIndex >= _users.length) {
      return PaginatedResponse<User>(
        data: [],
        hasMore: false,
        currentPage: page,
        totalPages: (_users.length / effectiveLimit).ceil(),
        totalItems: _users.length,
      );
    }

    final pageUsers = _users.sublist(
      startIndex,
      endIndex > _users.length ? _users.length : endIndex,
    );

    return PaginatedResponse<User>(
      data: pageUsers,
      hasMore: endIndex < _users.length,
      currentPage: page,
      totalPages: (_users.length / effectiveLimit).ceil(),
      totalItems: _users.length,
    );
  }
}

// ============================================================
// ListView Example
// ============================================================

class ListViewExample extends StatelessWidget {
  const ListViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaginatedDataBloc<User>(
        repository: UserRepository(),
        itemsPerPage: 15,
      )..add(const LoadFirstPage()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ListView Example'),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<PaginatedDataBloc<User>>().add(
                        const RefreshData(),
                      );
                },
              ),
            ),
          ],
        ),
        body: PaginatedDataWidget<User>(
          layoutType: PaginatedLayoutType.listView,
          enablePullToRefresh: true,
          separatorWidget: const Divider(height: 1),
          padding: const EdgeInsets.symmetric(vertical: 8),
          emptyWidget: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No users found'),
              ],
            ),
          ),
          itemBuilder: (context, user, index) => ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.avatar),
            ),
            title: Text(user.name),
            subtitle: Text(user.email),
            trailing: Text('#${user.id}'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tapped on ${user.name}')),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ============================================================
// GridView Example
// ============================================================

class GridViewExample extends StatelessWidget {
  const GridViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaginatedDataBloc<User>(
        repository: UserRepository(),
        itemsPerPage: 20,
      )..add(const LoadFirstPage()),
      child: Scaffold(
        appBar: AppBar(title: const Text('GridView Example')),
        body: PaginatedDataWidget<User>(
          layoutType: PaginatedLayoutType.gridView,
          enablePullToRefresh: true,
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, user, index) => Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Image.network(
                    user.avatar,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, size: 48),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PageView Example
// ============================================================

class PageViewExample extends StatelessWidget {
  const PageViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaginatedDataBloc<User>(
        repository: UserRepository(),
        itemsPerPage: 10,
      )..add(const LoadFirstPage()),
      child: Scaffold(
        appBar: AppBar(title: const Text('PageView Example')),
        body: PaginatedDataWidget<User>(
          layoutType: PaginatedLayoutType.pageView,
          scrollDirection: ScrollDirection.horizontal,
          padding: const EdgeInsets.all(24),
          itemBuilder: (context, user, index) => Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(user.avatar),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 16),
                  Chip(label: Text('User #${user.id}')),
                  const Spacer(),
                  Text(
                    'Swipe to see more →',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Sliver Example
// ============================================================

class SliverExample extends StatelessWidget {
  const SliverExample({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaginatedDataBloc<User>(
        repository: UserRepository(),
        itemsPerPage: 15,
      )..add(const LoadFirstPage()),
      child: Scaffold(
        body: PaginatedDataWidget<User>(
          layoutType: PaginatedLayoutType.sliverList,
          enablePullToRefresh: true,
          sliverHeaders: [
            SliverAppBar(
              title: const Text('Sliver Example'),
              floating: true,
              snap: true,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.people, size: 48, color: Colors.white),
                        SizedBox(height: 8),
                        Text(
                          'User Directory',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: const Text(
                  'All registered users in the system',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
          separatorWidget: const Divider(height: 1),
          itemBuilder: (context, user, index) => ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.avatar),
            ),
            title: Text(user.name),
            subtitle: Text(user.email),
          ),
        ),
      ),
    );
  }
}
