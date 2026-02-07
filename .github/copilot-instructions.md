# Copilot Instructions for paginated_bloc_widget

## Project Overview
This is a **Flutter package** (not an app) that provides a generic, BLoC-based pagination solution. It's published to pub.dev and must maintain backward compatibility.

## Architecture

### Core Components (Data Flow)
```
PaginatedDataRepository<T>  →  PaginatedDataBloc<T>  →  PaginatedDataWidget<T>
       (data source)              (state mgmt)              (UI)
```

1. **Repository** ([lib/src/repository/paginated_data_repository.dart](lib/src/repository/paginated_data_repository.dart)) - Abstract class users implement to fetch data. Returns `PaginatedResponse<T>`.
2. **BLoC** ([lib/src/bloc/paginated_data_bloc.dart](lib/src/bloc/paginated_data_bloc.dart)) - Manages pagination state via events (`LoadFirstPage`, `LoadMoreData`, `RefreshData`, `UpdateItem`, `RemoveItem`, `AddItem`).
3. **Widget** ([lib/src/widgets/paginated_data_widget.dart](lib/src/widgets/paginated_data_widget.dart)) - Renders paginated content with multiple layout types (ListView, GridView, PageView, Slivers).

### Key Patterns
- **Generic types `<T>`** are used throughout - always preserve type parameters when modifying code
- **part/part of** pattern for BLoC events and state (single file split)
- State uses `copyWith` pattern with `Equatable` for immutability
- All public APIs have documentation comments (required for pub.dev)

## File Structure
```
lib/
├── paginated_bloc_widget.dart    # Barrel export file - update when adding new exports
└── src/
    ├── bloc/                     # BLoC, Events, State (part files)
    ├── config/                   # PaginationConfig for global defaults
    ├── enums/                    # PaginationStatus, PaginatedLayoutType
    ├── models/                   # PaginatedResponse<T>
    ├── repository/               # Abstract repo + InMemoryPaginatedRepository
    └── widgets/                  # PaginatedDataWidget
```

## Development Commands
```bash
# Run from package root
flutter pub get
flutter analyze                   # Must pass before commits
flutter test                      # Run all tests

# Run example app
cd example && flutter run
```

## Coding Conventions

### When Adding New Features
1. Add exports to `lib/paginated_bloc_widget.dart`
2. Include `///` doc comments on all public APIs
3. Add `@required` parameters for mandatory fields
4. Use `PaginationConfig` for configurable defaults

### BLoC Events Pattern
```dart
// Events extend PaginatedDataEvent with const constructors
class NewEvent<T> extends PaginatedDataEvent {
  final T data;
  const NewEvent(this.data);
  @override
  List<Object?> get props => [data];
}
```

### State Transitions
State uses `PaginationStatus` enum - handle all status transitions in widgets:
- `firstPageLoading` / `firstPageError` / `firstPageSuccess`
- `loadingMore` / `loadMoreError` / `loadMoreSuccess`
- `refreshing` / `refreshError` / `refreshSuccess`

## Testing
- Use `InMemoryPaginatedRepository<T>` for unit tests (see [lib/src/repository/paginated_data_repository.dart#L48](lib/src/repository/paginated_data_repository.dart))
- Use `mocktail` for mocking (already in dev_dependencies)

## Common Gotchas
- This is a **package**, not an app - no `main.dart` in lib/
- Minimum SDK: Dart 3.0, Flutter 3.10
- Keep `flutter_bloc` version range broad for compatibility (`>=8.1.0 <10.0.0`)

dart pub publish --dry-run
dart pub publish