import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';
import '../bloc/library_action_bloc.dart';
import '../bloc/library_action_event.dart';
import '../bloc/library_action_state.dart';
import '../../../home/domain/entities/song_entity.dart';

class AddToPlaylistSheet extends StatelessWidget {
  final SongEntity song;

  const AddToPlaylistSheet({super.key, required this.song});

  static void show(BuildContext context, SongEntity song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddToPlaylistSheet(song: song),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<LibraryBloc>()..add(LoadLibraryEvent())),
        BlocProvider(create: (_) => sl<LibraryActionBloc>()),
      ],
      child: BlocListener<LibraryActionBloc, LibraryActionState>(
        listener: (context, state) {
          if (state is LibraryActionSuccess) {
            Navigator.pop(context); // Cerrar bottom sheet en éxito
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primary,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is LibraryActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.6, // Ocupa el 60% inicial
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabezal o título del Modal
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Añadir a playlist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Estado de cargando / añadiendo
              BlocBuilder<LibraryActionBloc, LibraryActionState>(
                builder: (context, state) {
                  if (state is LibraryActionLoading) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 20.0),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Lista de tus listas de reproducción leyendo del LibraryBloc
              Expanded(
                child: BlocBuilder<LibraryBloc, LibraryState>(
                  builder: (context, state) {
                    if (state is LibraryLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    } else if (state is LibraryFailure) {
                      return Center(child: Text('Error cargando playlists: ${state.error}', style: const TextStyle(color: Colors.red)));
                    } else if (state is LibraryLoaded) {
                      final playlists = state.playlists;
                      
                      if (playlists.isEmpty) {
                        return const Center(
                          child: Text(
                            'No tienes playlists.\nCrea una desde la Biblioteca.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: playlists.length,
                        itemBuilder: (context, index) {
                          final playlist = playlists[index];
                          
                          return ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              color: const Color(0xFF6A2C50),
                              child: const Icon(Icons.music_note, color: Colors.white),
                            ),
                            title: Text(
                              playlist.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text('Playlist', style: TextStyle(color: Colors.white54)),
                            onTap: () {
                              final playlistId = playlist.id.toString();
                              context.read<LibraryActionBloc>().add(
                                AddSongEvent(
                                  playlistId: playlistId, 
                                  songId: song.id, // Mapeado correctamente
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
