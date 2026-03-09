import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../../features/home/domain/entities/song_entity.dart';

class AudioState {
  final bool isPlaying;
  final ProcessingState processingState;
  final Duration position;
  final Duration bufferedPosition;
  final Duration totalDuration;
  final SongEntity? currentSong;
  final String? playlistName;
  final String? playlistType; // 'playlist' o 'album'

  AudioState({
    required this.isPlaying,
    required this.processingState,
    required this.position,
    required this.bufferedPosition,
    required this.totalDuration,
    this.currentSong,
    this.playlistName,
    this.playlistType,
  });

  factory AudioState.initial() => AudioState(
        isPlaying: false,
        processingState: ProcessingState.idle,
        position: Duration.zero,
        bufferedPosition: Duration.zero,
        totalDuration: Duration.zero,
      );

  AudioState _copyWith({
    bool? isPlaying,
    ProcessingState? processingState,
    Duration? position,
    Duration? bufferedPosition,
    Duration? totalDuration,
    SongEntity? currentSong,
    String? playlistName,
    String? playlistType,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      processingState: processingState ?? this.processingState,
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      currentSong: currentSong ?? this.currentSong,
      playlistName: playlistName ?? this.playlistName,
      playlistType: playlistType ?? this.playlistType,
    );
  }
}

class AudioService {
  late final AudioPlayer _player;
  List<SongEntity> _currentPlaylist = [];
  int _currentIndex = 0;
  String _playlistName = '';
  String _playlistType = 'playlist';
  SongEntity? get _currentSong => _currentPlaylist.isNotEmpty && _currentIndex >= 0 && _currentIndex < _currentPlaylist.length 
      ? _currentPlaylist[_currentIndex] 
      : null;

  // RxDart Subjects for broadcasting states
  final _audioStateSubject = BehaviorSubject<AudioState>.seeded(AudioState.initial());
  Stream<AudioState> get audioStateStream => _audioStateSubject.stream;
  AudioState get audioState => _audioStateSubject.value;

  Future<void> init() async {
    _player = AudioPlayer();
    
    // Configure audio session for handling interruptions (calls, other audio apps)
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Listen to combined stream of just_audio states to emit a single AudioState
    Rx.combineLatest4<bool, ProcessingState, Duration, Duration, AudioState>(
      _player.playingStream,
      _player.processingStateStream,
      _player.positionStream,
      _player.bufferedPositionStream,
      (playing, processingState, position, bufferedPosition) {
        return AudioState(
          isPlaying: playing,
          processingState: processingState,
          position: position,
          bufferedPosition: bufferedPosition,
          totalDuration: _player.duration ?? Duration.zero,
          currentSong: _currentSong,
          playlistName: _playlistName,
          playlistType: _playlistType,
        );
      },
    ).listen((state) {
      _audioStateSubject.add(state);
    });

    _player.currentIndexStream.listen((index) {
      if (index != null && _currentPlaylist.isNotEmpty) {
        _currentIndex = index;
        // Emit updated state with new current song
        _audioStateSubject.add(audioState._copyWith(currentSong: _currentSong));
      }
    });
  }

  Future<void> playPlaylist(List<SongEntity> songs, {int initialIndex = 0, String playlistName = '', String playlistType = 'playlist'}) async {
    if (songs.isEmpty) return;
    
    _currentPlaylist = songs;
    _currentIndex = initialIndex;
    _playlistName = playlistName;
    _playlistType = playlistType;

    // Emit immediate update with current song to show Mini-Player immediately
    _audioStateSubject.add(AudioState(
      isPlaying: audioState.isPlaying,
      processingState: ProcessingState.loading,
      position: Duration.zero,
      bufferedPosition: Duration.zero,
      totalDuration: Duration.zero,
      currentSong: _currentSong,
      playlistName: _playlistName,
      playlistType: _playlistType,
    ));

    try {
      final playlist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: songs.map((song) {
          return AudioSource.uri(
            Uri.parse(song.audioUrl),
            tag: MediaItem(
              id: song.id,
              album: song.album,
              title: song.title,
              artist: song.artistName,
              artUri: Uri.tryParse(song.coverUrl),
            ),
          );
        }).toList(),
      );
      
      await _player.setAudioSource(playlist, initialIndex: initialIndex, initialPosition: Duration.zero);
      await _player.play();
    } catch (e) {
      // Handle error accordingly, maybe emit failure state
    }
  }

  Future<void> play() async => await _player.play();
  
  Future<void> pause() async => await _player.pause();
  
  Future<void> seek(Duration position) async => await _player.seek(position);

  Future<void> seekToNext() async => await _player.seekToNext();
  Future<void> seekToPrevious() async => await _player.seekToPrevious();

  Future<void> stop() async {
    await _player.stop();
    _currentPlaylist = [];
    _currentIndex = 0;
    _audioStateSubject.add(AudioState.initial());
  }

  void dispose() {
    _player.dispose();
    _audioStateSubject.close();
  }
}
