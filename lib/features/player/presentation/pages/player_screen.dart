import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/player_cubit.dart';
import '../bloc/player_state.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import '../../../../core/widgets/heart_button.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<PlayerCubit, PlayerState>(
        builder: (context, state) {
          if (state is! PlayerUpdate || state.audioState.currentSong == null) {
            return const Center(child: Text('Sin canción reproduciendose', style: TextStyle(color: Colors.white)));
          }

          final audioState = state.audioState;
          final song = audioState.currentSong!;
          final double progress = audioState.totalDuration.inMilliseconds > 0 
              ? audioState.position.inMilliseconds / audioState.totalDuration.inMilliseconds 
              : 0.0;

          return SafeArea(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                // Si la velocidad es positiva, deslizó a la derecha (Anterior)
                // Si la velocidad es negativa, deslizó a la izquierda (Siguiente)
                if (details.primaryVelocity! > 500) {
                  context.read<PlayerCubit>().seekToPrevious();
                } else if (details.primaryVelocity! < -500) {
                  context.read<PlayerCubit>().seekToNext();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Column(
                        children: [
                          Text(
                            audioState.playlistType == 'album' 
                              ? 'REPRODUCIENDO DESDE ÁLBUM'
                              : 'REPRODUCIENDO DESDE PLAYLIST',
                            style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            audioState.playlistName?.isNotEmpty == true 
                              ? audioState.playlistName!
                              : (song.album.isNotEmpty ? song.album : 'Desconocido'),
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Portada del Álbum
                  Expanded(
                    child: Center(
                      child: Hero(
                        tag: song.coverUrl.isNotEmpty ? song.coverUrl.trim() : song.title,
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 350, maxHeight: 350),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6A2C50),
                            borderRadius: BorderRadius.circular(0), // Portada cuadrada como el mockup
                            image: song.coverUrl.isNotEmpty 
                              ? DecorationImage(image: NetworkImage(song.coverUrl), fit: BoxFit.cover)
                              : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              )
                            ]
                          ),
                          child: song.coverUrl.isEmpty 
                            ? const Icon(Icons.music_note, color: Colors.white, size: 100)
                            : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Info de la Canción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              song.album.isNotEmpty ? song.album : 'Artista Desconocido',
                              style: const TextStyle(color: Colors.white70, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Corazón de Favoritos (widget reutilizable con animación y optimistic update)
                      HeartButton(song: song, size: 28),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Barra de Progreso
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4.0,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    child: Slider(
                      value: progress.clamp(0.0, 1.0),
                      onChanged: (value) {
                        final newPosition = Duration(
                          milliseconds: (value * audioState.totalDuration.inMilliseconds).round()
                        );
                        context.read<PlayerCubit>().seek(newPosition);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(audioState.position), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      Text(_formatDuration(audioState.totalDuration), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Controles de Reproducción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shuffle, color: Colors.white, size: 28),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
                        onPressed: () {
                          context.read<PlayerCubit>().seekToPrevious();
                        },
                      ),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(
                          begin: 1.0,
                          end: audioState.isPlaying ? 1.0 : 0.95,
                        ),
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: audioState.isPlaying ? AppColors.primary : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              if (audioState.isPlaying)
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                )
                            ],
                          ),
                          child: IconButton(
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: Icon(
                                audioState.isPlaying ? Icons.pause : Icons.play_arrow, 
                                key: ValueKey<bool>(audioState.isPlaying),
                                color: Colors.black, 
                                size: 36
                              ),
                            ),
                            onPressed: () {
                              if (audioState.isPlaying) {
                                context.read<PlayerCubit>().pause();
                              } else {
                                if (audioState.processingState == ProcessingState.completed) {
                                  context.read<PlayerCubit>().seek(Duration.zero);
                                }
                                context.read<PlayerCubit>().play();
                              }
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
                        onPressed: () {
                          context.read<PlayerCubit>().seekToNext();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.repeat, color: Colors.white, size: 28),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Barra Inferior de Iconos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.devices, color: Colors.white54, size: 24),
                        onPressed: () {},
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share_outlined, color: Colors.white54, size: 24),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white54, size: 24),
                            onPressed: () {},
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
