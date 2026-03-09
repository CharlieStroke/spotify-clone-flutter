import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../playlist_detail/presentation/pages/playlist_detail_page.dart';
import '../../../../core/widgets/song_widgets.dart';

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
                style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold),
              ),
            ),
            // ── Tarjeta Mis Favoritos ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_music_outlined, color: Colors.white24, size: 80),
            SizedBox(height: 16),
            Text('Aún no tienes playlists', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Crea tu primera playlist en la pestaña '+'", style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlaylistDetailPage(
                  id: playlist.id.toString(),
                  title: playlist.name,
                  type: 'playlist',
                  coverUrl: null,
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
