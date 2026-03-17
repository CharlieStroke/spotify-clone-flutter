import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../playlist_detail/presentation/pages/playlist_detail_page.dart';
import '../../../../core/widgets/song_widgets.dart';
import '../../../../core/widgets/page_layout.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../core/widgets/empty_state_widget.dart';

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
    if (bloc.state is LibraryInitial || bloc.state is LibraryLoaded) {
      bloc.add(LoadLibraryEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Biblioteca',
      useScroll: false,
      padding: EdgeInsets.zero,
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<LibraryBloc>().add(LoadLibraryEvent());
        },
        color: AppColors.primary,
        backgroundColor: const Color(0xFF282828),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tarjeta Mis Favoritos ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FavoritesCard(
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
              ),
            ),
            // ── Grid de playlists del usuario ─────────────────────────────
            Expanded(
              child: BlocBuilder<LibraryBloc, LibraryState>(
                builder: (context, state) {
                  if (state is LibraryLoading) {
                    return const LibrarySkeleton();
                  } else if (state is LibraryFailure) {
                    return Center(child: Text(state.error, style: const TextStyle(color: Colors.red)));
                  } else if (state is LibraryLoaded) {
                    return _buildGrid(context, state.playlists);
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

  Widget _buildGrid(BuildContext context, List<dynamic> playlists) {
    if (playlists.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.library_music_outlined,
        title: 'Aún no tienes playlists',
        message: "Crea tu primera playlist en la pestaña '+' para empezar a construir tu colección.",
        buttonText: 'Crear Playlist',
        onButtonPressed: () {
          // Navegar a la pestaña de creación (índice 3 en MainPage)
          // O podrías abrir el diálogo de creación aquí mismo.
          // Por ahora, solo cerramos el mensaje informativo.
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        itemCount: playlists.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 15,
          mainAxisSpacing: 25,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return PlaylistCard(
            title: playlist.name,
            subtitle: 'Playlist',
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
    );
  }
}
