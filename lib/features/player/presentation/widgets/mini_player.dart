import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/player_cubit.dart';
import '../bloc/player_state.dart';
import '../pages/player_screen.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        if (state is! PlayerUpdate || state.audioState.currentSong == null) {
          return const SizedBox.shrink(); 
        }

        final audioState = state.audioState;
        final song = audioState.currentSong!;
        
        final double progress = audioState.totalDuration.inMilliseconds > 0 
            ? audioState.position.inMilliseconds / audioState.totalDuration.inMilliseconds 
            : 0.0;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PlayerScreen(),
                fullscreenDialog: true,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C), // Gris oscuro como en Spotify
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 8, right: 4),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: const Color(0xFF6A2C50),
                      image: song.coverUrl.isNotEmpty 
                        ? DecorationImage(image: NetworkImage(song.coverUrl), fit: BoxFit.cover)
                        : null,
                    ),
                    child: song.coverUrl.isEmpty 
                      ? const Icon(Icons.music_note, color: Colors.white) 
                      : null,
                  ),
                  title: Text(
                    song.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    song.album.isNotEmpty ? song.album : 'Artista',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          audioState.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
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
                    ],
                  ),
                ),
                // Barra de progreso miniatura interactiva
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.transparent,
                  color: Colors.white,
                  minHeight: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
