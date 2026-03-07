abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<dynamic> songs;
  final List<dynamic> albums;
  final List<dynamic> playlists;

  SearchLoaded({required this.songs, required this.albums, required this.playlists});
}

class SearchFailure extends SearchState {
  final String error;
  SearchFailure(this.error);
}
