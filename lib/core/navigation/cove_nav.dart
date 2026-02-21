import 'package:go_router/go_router.dart';

typedef HistorySaveFn = Future<void> Function(List<String> history);
typedef HistoryLoadFn = Future<List<String>> Function();

class CoveNav {
  CoveNav._();

  static GoRouter? _router;
  static final List<String> _history = [];

  static HistorySaveFn? _saveFn;
  static HistoryLoadFn? _loadFn;

  /// Initialize with the application's [GoRouter].
  /// Optionally provide [save] and [load] hooks for persistence.
  static Future<void> init(GoRouter router, {HistorySaveFn? save, HistoryLoadFn? load}) async {
    _router = router;
    _saveFn = save;
    _loadFn = load;

    if (_loadFn != null) {
      try {
        final loaded = await _loadFn!();
        _history.clear();
        _history.addAll(loaded);
      } catch (_) {
        // ignore load errors
      }
    }
  }

  static List<String> get history => List.unmodifiable(_history);
  static String? get current => _history.isNotEmpty ? _history.last : null;

  static void _ensureRouter() {
    if (_router == null) throw StateError('CoveNav not initialized. Call CoveNav.init(router) first.');
  }

  static Future<void> push(String location, {Object? extra}) async {
    _ensureRouter();
    _history.add(location);
    await _router!.push(location, extra: extra);
    await _persist();
  }

  static Future<void> pushNamed(String name,
      {Map<String, String>? pathParameters,
      Map<String, dynamic>? queryParameters,
      Object? extra}) async {
    _ensureRouter();
    // Use router instance to build location from named route
    final location = _router!.namedLocation(
      name,
      pathParameters: pathParameters ?? const {},
      queryParameters: queryParameters ?? const {},
    );
    _history.add(location);
    await _router!.push(location, extra: extra);
    await _persist();
  }

  static Future<void> replace(String location, {Object? extra}) async {
    _ensureRouter();
    if (_history.isNotEmpty) _history.removeLast();
    _history.add(location);
    await _router!.replace(location, extra: extra);
    await _persist();
  }

  static Future<void> go(String location, {Object? extra}) async {
    _ensureRouter();
    _history.add(location);
    _router!.go(location, extra: extra);
    await _persist();
  }

  static Future<void> pop() async {
    _ensureRouter();
    if (_history.isNotEmpty) _history.removeLast();
    _router!.pop();
    await _persist();
  }

  /// Pop until the given route is reached in our history. If the route is not found, do nothing.
  static Future<void> popUntil(String route) async {
    _ensureRouter();
    if (!_history.contains(route)) return;

    while (_history.isNotEmpty && _history.last != route) {
      _history.removeLast();
      if (_router!.canPop()) {
        _router!.pop();
      } else {
        break;
      }
    }
    await _persist();
  }

  /// Clear history and navigate to [location] (useful for login/ logout flows)
  static Future<void> clearAndPush(String location, {Object? extra}) async {
    _ensureRouter();
    _history.clear();
    _history.add(location);
    _router!.go(location, extra: extra);
    await _persist();
  }

  /// Directly add a value to history without navigation
  static Future<void> addToHistory(String route) async {
    _history.add(route);
    await _persist();
  }

  /// Clear persisted and in-memory history
  static Future<void> clearHistory({bool persist = true}) async {
    _history.clear();
    if (persist && _saveFn != null) await _saveFn!(_history);
  }

  static Future<void> _persist() async {
    if (_saveFn != null) {
      try {
        await _saveFn!(_history);
      } catch (_) {}
    }
  }
}
