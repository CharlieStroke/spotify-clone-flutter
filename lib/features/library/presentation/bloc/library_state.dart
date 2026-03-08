abstract class LibraryState {}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<dynamic> playlists;
  final List<dynamic> albums;

  LibraryLoaded({required this.playlists, required this.albums});
}

class LibraryFailure extends LibraryState {
  final String error;
  LibraryFailure(this.error);
}
