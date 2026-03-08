import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../../../../core/theme/app_colors.dart';
// Modelos necesarios (podemos reusar los que ya existen para pintar resultados)

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchBloc>(),
      child: const SearchView(),
    );
  }
}

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // O gradient
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Buscar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Search Input Box
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: '¿Qué quieres escuchar?',
                    hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    prefixIcon: Icon(Icons.search, color: Colors.black, size: 28),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (query) {
                    context.read<SearchBloc>().add(SearchQueryChanged(query));
                  },
                ),
              ),
              const SizedBox(height: 25),
              // Resultados dinámicos
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchInitial) {
                      return _buildEmptyStateCategoryGrid();
                    } else if (state is SearchLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    } else if (state is SearchFailure) {
                      return Center(child: Text(state.error, style: const TextStyle(color: Colors.red)));
                    } else if (state is SearchLoaded) {
                      return _buildSearchResults(state);
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

  // Explorar Tu Música Mockup: Cuadrícula con cajas de colores
  Widget _buildEmptyStateCategoryGrid() {
    final List<String> categories = ['Podcasts', 'Eventos en vivo', 'Nuevos lanzamientos', 'Pop', 'Hip-Hop', 'Rock', 'Latina', 'Dance / Electrónica'];
    final List<Color> colors = [Colors.deepOrange, Colors.purple, Colors.pink, Colors.green, Colors.orange, Colors.redAccent, Colors.teal, Colors.blueAccent];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explora todo',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: GridView.builder(
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Text(
                  categories[index],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // UI Mostrar Resultados (Canciones, Álbumes y Playlists)
  Widget _buildSearchResults(SearchLoaded state) {
    if (state.songs.isEmpty && state.albums.isEmpty && state.playlists.isEmpty) {
      return const Center(child: Text('No encontramos resultados.', style: TextStyle(color: Colors.white)));
    }

    return ListView(
      children: [
        if (state.songs.isNotEmpty) _buildSectionTitle('Canciones'),
        if (state.songs.isNotEmpty)
          ...state.songs.map((song) => ListTile(
            leading: _buildCover(song.coverUrl),
            title: Text(song.title, style: const TextStyle(color: Colors.white)),
            subtitle: const Text('Canción', style: TextStyle(color: Colors.grey)),
            onTap: () {}, // Reproducir
          )),

        if (state.albums.isNotEmpty) _buildSectionTitle('Álbumes'),
        if (state.albums.isNotEmpty)
          ...state.albums.map((album) => ListTile(
            leading: _buildCover(album.coverUrl),
            title: Text(album.title, style: const TextStyle(color: Colors.white)),
            subtitle: Text('Álbum • ${album.artistName}', style: const TextStyle(color: Colors.grey)),
          )),

        if (state.playlists.isNotEmpty) _buildSectionTitle('Playlists'),
        if (state.playlists.isNotEmpty)
          ...state.playlists.map((playlist) => ListTile(
            leading: _buildCover(null, isPlaylist: true),
            title: Text(playlist.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(playlist.description ?? 'Lista', style: const TextStyle(color: Colors.grey)),
          )),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCover(String? url, {bool isPlaylist = false}) {
    if (isPlaylist || url == null) {
      return Container(
        width: 50, height: 50,
        color: Colors.grey.shade800,
        child: const Icon(Icons.music_note, color: Colors.white),
      );
    }
    return Image.network(url, width: 50, height: 50, fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 50, height: 50,
        color: Colors.grey.shade800,
        child: const Icon(Icons.music_note, color: Colors.white),
      ),
    );
  }
}
