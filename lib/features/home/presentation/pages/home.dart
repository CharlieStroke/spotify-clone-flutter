import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../domain/entities/album_entity.dart';
import '../../domain/entities/playlist_entity.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocProvider(
        create: (context) => di.sl<HomeBloc>()..add(GetSongsEvent()),
        child: SafeArea( // Usamos SafeArea en lugar de SliverAppBar para un inicio limpio
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.green));
              } else if (state is HomeFailure) {
                return Center(child: Text(state.errorMessage, style: const TextStyle(color: Colors.red)));
              } else if (state is HomeLoaded) {
                final playlists = state.playlists;
                final albums = state.albums;
                final recientes = [...playlists, ...albums]; // Simulación temporal de recientes combinando ambos

                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                    // --- Sección 1: Playlists Rápidas (Grid 2 columnas) ---
                    if (playlists.isNotEmpty)
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3, // Ancho / Alto 
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        // Mostrar máximo 8
                        itemCount: playlists.length > 8 ? 8 : playlists.length, 
                        itemBuilder: (context, index) {
                          final playlist = playlists[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                // Ícono cuadrado de la playlist
                                Container(
                                  width: 50,
                                  decoration: const BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      bottomLeft: Radius.circular(4),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.queue_music, color: Colors.white54),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Título de la playlist
                                Expanded(
                                  child: Text(
                                    playlist.name,
                                    style: const TextStyle(
                                      color: Colors.black, 
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    if (playlists.isEmpty)
                      const Text('Aún no tienes playlists creadas.', style: TextStyle(color: Colors.grey)),
                    
                    const SizedBox(height: 30),

                    // --- Sección 2: Explora tu música ---
                    const Text(
                      'Explora tu música',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (albums.isNotEmpty)
                      SizedBox(
                        height: 220, // Altura del contenedor horizontal
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: albums.length, 
                          itemBuilder: (context, index) {
                            final album = albums[index];
                            return Container(
                              width: 150,
                              margin: const EdgeInsets.only(right: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Portada del álbum
                                  Container(
                                    height: 150,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple, // Color base por si no carga la imagen
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(album.coverUrl),
                                        fit: BoxFit.cover,
                                        onError: (_, __) => const Icon(Icons.album, size: 60, color: Colors.white),
                                      )
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Álbum',
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    album.title,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    album.artistName,
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    if (albums.isEmpty)
                      const Text('No hay álbumes disponibles.', style: TextStyle(color: Colors.grey)),

                    const SizedBox(height: 30),

                    // --- Sección 3: Recientes ---
                    const Text(
                      'Recientes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (recientes.isNotEmpty)
                      SizedBox(
                        height: 200, 
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: recientes.length > 5 ? 5 : recientes.length,
                          itemBuilder: (context, index) {
                            final item = recientes[index];
                            final isAlbum = item is AlbumEntity;

                            return Container(
                              width: 130,
                              margin: const EdgeInsets.only(right: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Portada de Recientes
                                  Container(
                                    height: 130,
                                    width: 130,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6A2E44), 
                                      borderRadius: BorderRadius.circular(8),
                                      image: isAlbum ? DecorationImage(
                                        image: NetworkImage((item as AlbumEntity).coverUrl),
                                        fit: BoxFit.cover,
                                      ) : null,
                                    ),
                                    child: !isAlbum ? const Icon(Icons.queue_music, size: 50, color: Colors.white54) : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    isAlbum ? 'Álbum' : 'Playlist',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    isAlbum ? (item as AlbumEntity).title : (item as PlaylistEntity).name,
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    
                    if (recientes.isEmpty)
                      const Text('No hay actividad reciente.', style: TextStyle(color: Colors.grey)),
                      
                    const SizedBox(height: 40), // Espacio al final
                  ]),
                ),
              ),
            ],
          );
        }
        return const Center(child: Text('Algo salió mal', style: TextStyle(color: Colors.white)));
      },
      ),
        ),
      ),
    );
  }
}