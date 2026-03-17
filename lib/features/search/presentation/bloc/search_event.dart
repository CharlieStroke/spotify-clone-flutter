abstract class SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  final String query;
  SearchQueryChanged(this.query);
}

class LoadRecentSearches extends SearchEvent {}

class ClearRecentSearches extends SearchEvent {}

class RemoveRecentSearch extends SearchEvent {
  final String query;
  RemoveRecentSearch(this.query);
}
