import 'package:hive_flutter/hive_flutter.dart';

abstract class SearchLocalDataSource {
  Future<void> cacheRecentSearch(String query);
  Future<void> removeRecentSearch(String query);
  Future<List<String>> getRecentSearches();
  Future<void> clearRecentSearches();
}

class SearchLocalDataSourceImpl implements SearchLocalDataSource {
  final Box _box;
  static const String _key = 'recent_searches';

  SearchLocalDataSourceImpl(this._box);

  @override
  Future<void> cacheRecentSearch(String query) async {
    final searches = await getRecentSearches();
    if (searches.contains(query)) {
      searches.remove(query);
    }
    searches.insert(0, query);
    
    // Mantener solo los últimos 10
    if (searches.length > 10) {
      searches.removeRange(10, searches.length);
    }
    
    await _box.put(_key, searches);
  }

  @override
  Future<void> removeRecentSearch(String query) async {
    final searches = await getRecentSearches();
    searches.remove(query);
    await _box.put(_key, searches);
  }

  @override
  Future<List<String>> getRecentSearches() async {
    final List<dynamic>? searches = _box.get(_key);
    return searches?.cast<String>() ?? [];
  }

  @override
  Future<void> clearRecentSearches() async {
    await _box.delete(_key);
  }
}
