import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/audio_service.dart';
import '../../../home/domain/entities/song_entity.dart';
import '../../../home/domain/usecases/increment_play_count_usecase.dart';
import 'player_state.dart';
import 'dart:async';

class PlayerCubit extends Cubit<PlayerState> {
  final AudioService _audioService;
  final IncrementPlayCountUseCase _incrementPlayCount;
  StreamSubscription? _audioSubscription;
  String? _lastTrackedSongId;

  PlayerCubit(this._audioService, this._incrementPlayCount)
      : super(PlayerInitial()) {
    _audioSubscription = _audioService.audioStateStream.listen((audioState) {
      if (audioState.currentSong == null) {
        _lastTrackedSongId = null;
        emit(PlayerInitial());
      } else {
        final song = audioState.currentSong!;
        if (song.id != _lastTrackedSongId) {
          _lastTrackedSongId = song.id;
          _incrementPlayCount.call(song.id).catchError((_) {});
        }
        emit(PlayerUpdate(audioState));
      }
    });
  }

  void playPlaylist(List<SongEntity> songs,
      {int initialIndex = 0,
      String playlistName = '',
      String playlistType = 'playlist'}) {
    _audioService.playPlaylist(songs,
        initialIndex: initialIndex,
        playlistName: playlistName,
        playlistType: playlistType);
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
