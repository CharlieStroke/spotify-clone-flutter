import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/detail_bloc.dart';
import '../bloc/detail_event.dart';
import '../bloc/detail_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../library/presentation/widgets/add_to_playlist_sheet.dart';
import '../../../library/presentation/widgets/search_song_to_add_sheet.dart';

class PlaylistDetailPage extends StatelessWidget {
  final String id;
  final String title;
  final String type; // 'playlist' o 'album'
  final String? coverUrl;

  const PlaylistDetailPage({
    super.key,
    required this.id,
    required this.title,
    required this.type,
    this.coverUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PlaylistDetailBloc>()..add(LoadPlaylistDetailEvent(id: id, type: type)),
      child: PlaylistDetailView(id: id, title: title, type: type, coverUrl: coverUrl),
    );
  }
}

class PlaylistDetailView extends StatelessWidget {
  final String id;
  final String title;
  final String type;
  final String? coverUrl;

  const PlaylistDetailView({
    super.key, 
    required this.id, 
    required this.title, 
    required this.type, 
    this.coverUrl
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
                  // Botón Agregar Canciones
                  if (type == 'playlist') ...[
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
                          SearchSongToAddSheet.show(context, id);
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
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () {
                            AddToPlaylistSheet.show(context, song);
                          },
                        ),
                        onTap: () {
                          // Play individual song
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
