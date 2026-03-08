import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../home/presentation/bloc/home_event.dart';
import '../../../home/presentation/bloc/home_state.dart';
import '../../../playlist_detail/presentation/pages/playlist_detail_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<SearchBloc>()),
        BlocProvider(create: (_) => sl<HomeBloc>()..add(GetSongsEvent())),
      ],
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
      backgroundColor: Colors.black,
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
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchInitial) {
                      return _buildDiscoverGrid(context);
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

  /// Estado Inicial: Muestra álbumes y playlists reales
  Widget _buildDiscoverGrid(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (state is HomeLoaded) {
          final albums = state.albums;
          final playlists = state.playlists;

          return CustomScrollView(
            slivers: [
              // Álbumes disponibles
              if (albums.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Álbumes',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final album = albums[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlaylistDetailPage(
                              id: album.id.toString(),
                              title: album.title,
                              type: 'album',
                              coverUrl: album.coverUrl,
                            ),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade800,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              if (album.coverUrl.isNotEmpty)
                                Positioned.fill(
                                  child: Image.network(
                                    album.coverUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const SizedBox(),
                                  ),
                                ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [Colors.black87, Colors.transparent],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        album.title,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        album.artistName,
                                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: albums.length > 6 ? 6 : albums.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                ),
              ],
              // Playlists del usuario
              if (playlists.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 12),
                    child: Text(
                      'Tus Playlists',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final playlist = playlists[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.queue_music, color: AppColors.primary),
                        ),
                        title: Text(playlist.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: const Text('Playlist', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlaylistDetailPage(
                              id: playlist.id.toString(),
                              title: playlist.name,
                              type: 'playlist',
                              ownerId: playlist.userId,
                              coverUrl: null,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: playlists.length,
                  ),
                ),
              ],
              if (albums.isEmpty && playlists.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, color: Colors.white24, size: 80),
                        SizedBox(height: 16),
                        Text('Busca canciones, álbumes o artistas', style: TextStyle(color: Colors.white54, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }

        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, color: Colors.white24, size: 80),
              SizedBox(height: 16),
              Text('Busca canciones, álbumes o artistas', style: TextStyle(color: Colors.white54, fontSize: 16)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(SearchLoaded state) {
    if (state.songs.isEmpty && state.albums.isEmpty && state.playlists.isEmpty) {
      return const Center(child: Text('No encontramos resultados.', style: TextStyle(color: Colors.white)));
    }

    return ListView(
      children: [
        if (state.songs.isNotEmpty) _buildSectionTitle('Canciones'),
        if (state.songs.isNotEmpty)
          ...state.songs.map((song) => ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: song.coverUrl.isNotEmpty
                  ? Image.network(song.coverUrl, width: 50, height: 50, fit: BoxFit.cover,
                      errorBuilder: (e, s, t) => _iconBox(Icons.music_note))
                  : _iconBox(Icons.music_note),
            ),
            title: Text(song.title, style: const TextStyle(color: Colors.white)),
            subtitle: Text(song.album.isNotEmpty ? song.album : 'Canción', style: const TextStyle(color: Colors.grey)),
            onTap: () {},
          )),

        if (state.albums.isNotEmpty) _buildSectionTitle('Álbumes'),
        if (state.albums.isNotEmpty)
          ...state.albums.map((album) => ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: album.coverUrl.isNotEmpty
                  ? Image.network(album.coverUrl, width: 50, height: 50, fit: BoxFit.cover,
                      errorBuilder: (e, s, t) => _iconBox(Icons.album))
                  : _iconBox(Icons.album),
            ),
            title: Text(album.title, style: const TextStyle(color: Colors.white)),
            subtitle: Text('Álbum • ${album.artistName}', style: const TextStyle(color: Colors.grey)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlaylistDetailPage(
                  id: album.id.toString(),
                  title: album.title,
                  type: 'album',
                  coverUrl: album.coverUrl,
                  ownerId: null,
                ),
              ),
            ),
          )),

        if (state.playlists.isNotEmpty) _buildSectionTitle('Playlists'),
        if (state.playlists.isNotEmpty)
          ...state.playlists.map((playlist) => ListTile(
            leading: _iconBox(Icons.queue_music, color: AppColors.primary),
            title: Text(playlist.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(playlist.description ?? 'Playlist', style: const TextStyle(color: Colors.grey)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlaylistDetailPage(
                  id: playlist.id.toString(),
                  title: playlist.name,
                  type: 'playlist',
                  ownerId: playlist.userId,
                  coverUrl: null,
                ),
              ),
            ),
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

  Widget _iconBox(IconData icon, {Color color = Colors.white54}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, color: color),
    );
  }
}
