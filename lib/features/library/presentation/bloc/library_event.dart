abstract class LibraryEvent {}

class LoadLibraryEvent extends LibraryEvent {
  final bool forceRefresh;
  LoadLibraryEvent({this.forceRefresh = false});
}

class ResetLibraryEvent extends LibraryEvent {}
