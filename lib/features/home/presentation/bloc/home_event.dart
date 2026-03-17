abstract class HomeEvent {}

class GetSongsEvent extends HomeEvent {
  final bool forceRefresh;
  GetSongsEvent({this.forceRefresh = false});
}

class ResetHomeEvent extends HomeEvent {}