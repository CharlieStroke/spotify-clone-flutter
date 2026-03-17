import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../home/presentation/bloc/home_state.dart';
import '../../../playlist_detail/presentation/pages/playlist_detail_page.dart';
import '../../../home/domain/entities/song_entity.dart';
import '../../../../core/widgets/song_widgets.dart';
import '../../../../core/widgets/page_layout.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SearchView();
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
  void initState() {
    super.initState();
    context.read<SearchBloc>().add(LoadRecentSearches());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Buscar',
      useScroll: false,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  if (state is SearchLoading) {
                    return const PlaylistDetailSkeleton();
                  } else if (state is SearchFailure) {
                    return EmptyStateWidget(
                      icon: Icons.error_outline,
                      title: 'Error de búsqueda',
                      message: state.error,
                      buttonText: 'Reintentar',
                      onButtonPressed: () {
                        context.read<SearchBloc>().add(SearchQueryChanged(_searchController.text));
                      },
                    );
                  } else if (state is SearchRecentLoaded) {
                    if (state.recentSearches.isEmpty) {
                      return _buildDiscoverGrid(context);
                    }
                    return _buildRecentSearches(state.recentSearches);
                  } else if (state is SearchLoaded) {
                    return _buildSearchResults(state);
                  }
                  return _buildDiscoverGrid(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches(List<String> searches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Búsquedas recientes',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.read<SearchBloc>().add(ClearRecentSearches()),
              child: const Text('Borrar todo', style: TextStyle(color: Colors.grey, fontSize: 13)),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: searches.length,
            itemBuilder: (context, index) {
              final query = searches[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(query, style: const TextStyle(color: Colors.white70)),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                  onPressed: () => context.read<SearchBloc>().add(RemoveRecentSearch(query)),
                ),
                onTap: () {
                  _searchController.text = query;
                  context.read<SearchBloc>().add(SearchQueryChanged(query));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Estado Inicial: Muestra álbumes y playlists reales
  Widget _buildDiscoverGrid(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const HomeSkeleton();
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
                      'Explorar todo',
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
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              if (album.coverUrl.isNotEmpty)
                                Positioned.fill(
                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'assets/images/logo.png', // Fallback placeholder
                                    image: album.coverUrl,
                                    fit: BoxFit.cover,
                                    imageErrorBuilder: (e, s, t) => const Icon(Icons.album, color: Colors.white10),
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
                                  child: Text(
                                    album.title,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
                    childAspectRatio: 1.5,
                  ),
                ),
              ],
              // Playlists del usuario
              if (playlists.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 12),
                    child: Text(
                      'Para ti',
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
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.queue_music, color: AppColors.primary),
                        ),
                        title: Text(playlist.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('Playlist • ${playlist.creatorName}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
      return const EmptyStateWidget(
        icon: Icons.search_off,
        title: 'No encontramos resultados',
        message: 'Intenta buscar con otras palabras o revisa la ortografía.',
      );
    }

    return ListView(
      children: [
        if (state.songs.isNotEmpty) _buildSectionTitle('Canciones'),
        if (state.songs.isNotEmpty)
          ...state.songs.cast<SongEntity>().asMap().entries.map((entry) {
            final index = entry.key;
            final song = entry.value;
            final songs = state.songs.cast<SongEntity>().toList();
            return SongListTileWithHeart(
              song: song,
              queue: songs,
              indexInQueue: index,
              playlistName: 'Resultados de búsqueda',
              playlistType: 'playlist',
            );
          }),

        if (state.albums.isNotEmpty) _buildSectionTitle('Álbumes'),
        if (state.albums.isNotEmpty)
          ...state.albums.map((album) => ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 50,
                height: 50,
                child: album.coverUrl.isNotEmpty
                    ? FadeInImage.assetNetwork(
                        placeholder: 'assets/images/logo.png',
                        image: album.coverUrl,
                        fit: BoxFit.cover,
                        imageErrorBuilder: (e, s, t) => _iconBox(Icons.album),
                      )
                    : _iconBox(Icons.album),
              ),
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
            subtitle: Text('Playlist • ${playlist.creatorName}', style: const TextStyle(color: Colors.grey)),
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
