import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../library/presentation/bloc/library_bloc.dart';
import '../../../library/presentation/bloc/library_event.dart';
import '../bloc/detail_bloc.dart';
import '../bloc/detail_event.dart';
import '../bloc/detail_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../library/presentation/widgets/add_to_playlist_sheet.dart';
import '../../../library/presentation/widgets/search_song_to_add_sheet.dart';
import '../../../../features/player/presentation/bloc/player_cubit.dart';
import '../../../../features/player/presentation/pages/player_screen.dart';
import '../../../../features/player/presentation/widgets/mini_player.dart';
import '../../../library/presentation/bloc/library_action_bloc.dart';
import '../../../library/presentation/bloc/library_action_event.dart';
import '../../../library/presentation/bloc/library_action_state.dart';
import '../../../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../../../features/profile/presentation/bloc/profile_state.dart';

class PlaylistDetailPage extends StatelessWidget {
  final String id;
  final String title;
  final String type; // 'playlist' o 'album'
  final String? coverUrl;
  final int? ownerId;

  const PlaylistDetailPage({
    super.key,
    required this.id,
    required this.title,
    required this.type,
    this.coverUrl,
    this.ownerId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<PlaylistDetailBloc>()..add(LoadPlaylistDetailEvent(id: id, type: type))),
        BlocProvider(create: (_) => sl<LibraryActionBloc>()),
      ],
      child: PlaylistDetailView(id: id, title: title, type: type, coverUrl: coverUrl, ownerId: ownerId),
    );
  }
}

class PlaylistDetailView extends StatelessWidget {
  final String id;
  final String title;
  final String type;
  final String? coverUrl;
  final int? ownerId;

  const PlaylistDetailView({
    super.key, 
    required this.id, 
    required this.title, 
    required this.type, 
    this.coverUrl,
    this.ownerId,
  });

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF282828),
          title: const Text('Eliminar playlist', style: TextStyle(color: Colors.white)),
          content: Text('¿Estás seguro de que quieres eliminar "$title"?', style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Cerrar dialogo
                context.read<LibraryActionBloc>().add(DeletePlaylistEvent(id));
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LibraryActionBloc, LibraryActionState>(
      listener: (context, state) {
        if (state is LibraryActionSuccess) {
          if (state.message.contains('eliminada')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent)
            );
            // Refrescar biblioteca global 
            context.read<LibraryBloc>().add(LoadLibraryEvent());
            // Retrocoder al home
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state.message.contains('removida')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1DB954)) // AppColors.primary
            );
            // Refrescar vista actual
            context.read<PlaylistDetailBloc>().add(LoadPlaylistDetailEvent(id: id, type: type));
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (type == 'playlist' &&
                context.read<ProfileBloc>().state is ProfileLoaded &&
                (context.read<ProfileBloc>().state as ProfileLoaded).user.userId == ownerId)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: const Color(0xFF282828),
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteDialog(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Eliminar playlist', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
          ],
        ),
        extendBodyBehindAppBar: true, // Para que el gradiente o fondo suba
        body: SingleChildScrollView(
          child: Column(
          children: [
            const SizedBox(height: 80), // AppBar padding
            
            // --- PORTADA SUPERIOR ---
            _buildCoverSpace(),
            
            const SizedBox(height: 16),
            
            // --- INFORMACIÓN Y BOTONES ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Fila de Controles (Guardado, Random, Play)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 28),
                          const SizedBox(width: 8),
                          const Text('Guardado', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shuffle, color: AppColors.primary, size: 28),
                            onPressed: () {},
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.play_arrow, color: Colors.black, size: 32),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Botón Agregar Canciones — solo visible para el dueño de la playlist
                  if (type == 'playlist' &&
                      context.read<ProfileBloc>().state is ProfileLoaded &&
                      (context.read<ProfileBloc>().state as ProfileLoaded).user.userId == ownerId) ...[ 
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () {
                          final bloc = context.read<PlaylistDetailBloc>();
                          SearchSongToAddSheet.show(context, id, detailBloc: bloc);
                        },
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text(
                          'Añadir canciones',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 10),

            // --- LISTA DE CANCIONES BLOC ---
            BlocBuilder<PlaylistDetailBloc, PlaylistDetailState>(
              builder: (context, state) {
                if (state is PlaylistDetailLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  );
                } else if (state is PlaylistDetailFailure) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(child: Text(state.error, style: const TextStyle(color: Colors.red))),
                  );
                } else if (state is PlaylistDetailLoaded) {
                  if (state.songs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: Text('Aún no hay canciones.', style: TextStyle(color: Colors.white))),
                    );
                  }
                  
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // Evitar scroll anidado
                    itemCount: state.songs.length,
                    itemBuilder: (context, index) {
                      final song = state.songs[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        leading: Container(
                          width: 50,
                          height: 50,
                          color: const Color(0xFF6A2C50),
                          child: song.coverUrl.isNotEmpty
                              ? Image.network(song.coverUrl, fit: BoxFit.cover)
                              : const Icon(Icons.photo_outlined, color: Colors.white),
                        ),
                        title: Text(
                          song.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          song.album.isNotEmpty ? song.album : 'Desconocido', // album en vez de artistName
                          style: const TextStyle(color: Colors.white70),
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Colors.white),
                              color: const Color(0xFF282828),
                              onSelected: (value) {
                                if (value == 'add') {
                                  AddToPlaylistSheet.show(context, song);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'add',
                                  child: Text('Añadir a otra playlist', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                            if (type == 'playlist' &&
                                context.read<ProfileBloc>().state is ProfileLoaded &&
                                (context.read<ProfileBloc>().state as ProfileLoaded).user.userId == ownerId)
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Colors.white54),
                                color: const Color(0xFF282828),
                                onSelected: (value) {
                                  if (value == 'remove') {
                                    context.read<LibraryActionBloc>().add(
                                      RemoveSongEvent(
                                        playlistId: id,
                                        songId: song.id.toString()
                                      )
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'remove',
                                    child: Text('Quitar de esta playlist', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        onTap: () {
                          // Play full playlist starting from this index
                          context.read<PlayerCubit>().playPlaylist(
                            state.songs,
                            initialIndex: index,
                            playlistName: title,
                            playlistType: type,
                          );
                          // Abrir el reproductor grande
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PlayerScreen(),
                              fullscreenDialog: true,
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
            
              const SizedBox(height: 50), // Margen final
            ],
          ),
        ),
        bottomNavigationBar: const MiniPlayer(),
      ),
    );
  }

  Widget _buildCoverSpace() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          color: const Color(0xFF6A2C50), // Color morado del mockup
          image: coverUrl != null 
            ? DecorationImage(image: NetworkImage(coverUrl!), fit: BoxFit.cover)
            : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ]
        ),
        child: coverUrl == null 
          ? const Icon(Icons.photo_outlined, color: Colors.white, size: 80)
          : null,
      ),
    );
  }
}
