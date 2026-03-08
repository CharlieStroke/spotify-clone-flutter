import '../../../../core/services/audio_service.dart';

abstract class PlayerState {}

class PlayerInitial extends PlayerState {}

class PlayerUpdate extends PlayerState {
  final AudioState audioState;
  
  PlayerUpdate(this.audioState);
}
