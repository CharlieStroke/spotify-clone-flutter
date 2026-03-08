abstract class LibraryActionState {}

class LibraryActionInitial extends LibraryActionState {}

class LibraryActionLoading extends LibraryActionState {}

class LibraryActionSuccess extends LibraryActionState {
  final String message;
  LibraryActionSuccess(this.message);
}

class LibraryActionFailure extends LibraryActionState {
  final String error;
  LibraryActionFailure(this.error);
}
