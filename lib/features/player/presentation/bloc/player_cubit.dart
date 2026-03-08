import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/audio_service.dart';
import '../../../home/domain/entities/song_entity.dart';
import 'player_state.dart';
import 'dart:async';

class PlayerCubit extends Cubit<PlayerState> {
  final AudioService _audioService;
  StreamSubscription? _audioSubscription;

  PlayerCubit(this._audioService) : super(PlayerInitial()) {
    _audioSubscription = _audioService.audioStateStream.listen((state) {
      if (state.currentSong == null) {
        emit(PlayerInitial());
      } else {
        emit(PlayerUpdate(state));
      }
    });
  }

  void playPlaylist(List<SongEntity> songs, {int initialIndex = 0}) {
    _audioService.playPlaylist(songs, initialIndex: initialIndex);
  }

  void play() => _audioService.play();
  void pause() => _audioService.pause();
  void seek(Duration position) => _audioService.seek(position);
  void seekToNext() => _audioService.seekToNext();
  void seekToPrevious() => _audioService.seekToPrevious();
  void stop() => _audioService.stop();

  @override
  Future<void> close() {
    _audioSubscription?.cancel();
    return super.close();
  }
}
