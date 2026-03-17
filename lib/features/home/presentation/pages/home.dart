import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../domain/entities/album_entity.dart';
import '../../../playlist_detail/presentation/pages/playlist_detail_page.dart';
import '../../../../core/widgets/song_widgets.dart';
import '../../../../core/widgets/page_layout.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<HomeBloc>();
    // Solo cargamos si no se ha cargado previamente para evitar 429
    if (bloc.state is HomeInitial || bloc.state is HomeFailure) {
      bloc.add(GetSongsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
        title: 'Inicio',
        useScroll: false,
        padding: EdgeInsets.zero,
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const HomeSkeleton();
            } else if (state is HomeFailure) {
              return EmptyStateWidget(
                icon: Icons.wifi_off_rounded,
                title: 'No pudimos cargar el contenido',
                message: state.errorMessage,
                buttonText: 'Reintentar',
                onButtonPressed: () => context.read<HomeBloc>().add(GetSongsEvent()),
              );
            } else if (state is HomeLoaded) {
              final playlists = state.playlists;
              final albums = state.albums;
              final recientes = [...playlists, ...albums];

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(GetSongsEvent());
                },
                color: AppColors.primary,
                backgroundColor: const Color(0xFF282828),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // --- Sección 1: Playlists Rápidas (Grid 2 columnas) ---
                          if (playlists.isNotEmpty)
                            GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2.8,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: playlists.length > 8 ? 8 : playlists.length,
                              itemBuilder: (context, index) {
                                final playlist = playlists[index];
                                return HomePlaylistChip(
                                  name: playlist.name,
                                  coverUrl: playlist.coverUrl,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PlaylistDetailPage(
                                        id: playlist.id.toString(),
                                        title: playlist.name,
                                        type: 'playlist',
                                        coverUrl: playlist.coverUrl,
                                        ownerId: playlist.userId,
                                      ),
                                    ),
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
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          if (albums.isNotEmpty)
                            SizedBox(
                              height: 220,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: albums.length,
                                itemBuilder: (context, index) {
                                  final album = albums[index];
                                  return AlbumCard(
                                    title: album.title,
                                    artistName: album.artistName,
                                    coverUrl: album.coverUrl,
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
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          if (recientes.isNotEmpty)
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: recientes.length > 5 ? 5 : recientes.length,
                                itemBuilder: (context, index) {
                                  final dynamic item = recientes[index];
                                  final isAlbum = item is AlbumEntity;

                                  return AlbumCard(
                                    title: isAlbum ? item.title : item.name,
                                    artistName: isAlbum ? item.artistName : 'Playlist',
                                    coverUrl: isAlbum ? item.coverUrl : item.coverUrl,
                                    width: 130,
                                    imageSize: 130,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PlaylistDetailPage(
                                          id: item.id.toString(),
                                          title: isAlbum ? item.title : item.name,
                                          type: isAlbum ? 'album' : 'playlist',
                                          coverUrl: isAlbum ? item.coverUrl : item.coverUrl,
                                          ownerId: isAlbum ? null : item.userId,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                          if (recientes.isEmpty)
                            const Text('No hay actividad reciente.', style: TextStyle(color: Colors.grey)),

                          const SizedBox(height: 40),
                        ]),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Algo salió mal', style: TextStyle(color: Colors.white)));
          },
        ),
    );
  }
}