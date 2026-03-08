import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../playlist_detail/presentation/pages/playlist_detail_page.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_state.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LibraryView();
  }
}

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<LibraryBloc>();
    // Siempre recargamos si es Initial (primera vez) o si ya hay datos cargados
    // (puede ser de un usuario anterior luego de hacer logout + nuevo login)
    if (bloc.state is LibraryInitial || bloc.state is LibraryLoaded) {
      bloc.add(LoadLibraryEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20.0, top: 40.0, bottom: 20.0),
              child: Text(
                'Tu biblioteca',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // --- Tarjeta especial: Mis Favoritos ---
            _buildFavoritesCard(context),
            Expanded(
              child: BlocBuilder<LibraryBloc, LibraryState>(
                builder: (context, state) {
                  if (state is LibraryLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  } else if (state is LibraryFailure) {
                    return Center(child: Text(state.error, style: const TextStyle(color: Colors.red)));
                  } else if (state is LibraryLoaded) {
                    return _buildGrid(state.playlists);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesCard(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        final count = state is FavoritesLoaded ? state.songs.length : 0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PlaylistDetailPage(
                  id: 'favorites',
                  title: 'Mis Favoritos',
                  type: 'favorites',
                ),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A0E8F), Color(0xFF1A0A3A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.star, color: Colors.amber, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mis Favoritos',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$count ${count == 1 ? 'canción' : 'canciones'}',
                          style: const TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white54),
                ],
              ),
            ),
          ),
        );
      },
    );
  }   // ← cierre de _buildFavoritesCard

  Widget _buildGrid(List<dynamic> playlists) {
    // Si la lista está vacía mostramos un mensaje amigable
    if (playlists.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_music_outlined, color: Colors.white24, size: 80),
            SizedBox(height: 16),
            Text(
              'Aún no tienes playlists',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Crea tu primera playlist en la pestaña \'+\'',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      );
    }
    
    final itemsCount = playlists.length; 

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        itemCount: itemsCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, 
          crossAxisSpacing: 15,
          mainAxisSpacing: 25,
          childAspectRatio: 0.65, // Ajustar para acomodar imagen + texto
        ),
        itemBuilder: (context, index) {
          
          String title = 'Título';
          String subtitle = 'Playlist o álbum';
          String? coverUrl;
          String id = '';
          int? ownerId;

          if (playlists.isNotEmpty && index < playlists.length) {
            title = playlists[index].name;
            subtitle = 'Playlist'; 
            id = playlists[index].id.toString();
            coverUrl = null; // Las playlists no tienen cover_url en la BD actual
            ownerId = playlists[index].userId;
          }

          return GestureDetector(
            onTap: () {
              if (id.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaylistDetailPage(
                      id: id,
                      title: title,
                      type: 'playlist', // Asumimos playlist por ahora hasta introducir mixtos
                      coverUrl: coverUrl,
                      ownerId: ownerId,
                    ),
                  ),
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Cuadro Morado
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A2C50), // Color morado del mockup
                    borderRadius: BorderRadius.circular(2), // Bordes ligeramente redondeados o cuadrados
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.photo_outlined, 
                      color: Colors.white, 
                      size: 45,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Subtítulo (Playlist o álbum)
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Título principal
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    ),
  );
}
}
