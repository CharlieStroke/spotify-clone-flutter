import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/public_artist_profile_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/song_widgets.dart';
import '../../../home/domain/entities/album_entity.dart';
import '../../../playlist_detail/presentation/pages/playlist_detail_page.dart';

class PublicArtistProfilePage extends StatefulWidget {
  final int artistId;
  const PublicArtistProfilePage({super.key, required this.artistId});

  @override
  State<PublicArtistProfilePage> createState() => _PublicArtistProfilePageState();
}

class _PublicArtistProfilePageState extends State<PublicArtistProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<PublicArtistProfileCubit>().loadProfile(widget.artistId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<PublicArtistProfileCubit, PublicArtistProfileState>(
        builder: (context, state) {
          if (state is PublicArtistProfileLoading || state is PublicArtistProfileInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is PublicArtistProfileError) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Error',
              message: state.message,
              buttonText: 'Reintentar',
              onButtonPressed: () =>
                  context.read<PublicArtistProfileCubit>().retry(widget.artistId),
            );
          }
          if (state is PublicArtistProfileLoaded) {
            return _buildProfile(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProfile(BuildContext context, PublicArtistProfileLoaded state) {
    final artist = state.artist;
    return CustomScrollView(
      slivers: [
        // ── Header ─────────────────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              artist.stageName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (artist.imageUrl.isNotEmpty)
                  FadeInImage.assetNetwork(
                    placeholder: 'assets/images/logo.png',
                    image: artist.imageUrl,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (_, _, _) =>
                        Container(color: Colors.grey.shade900),
                  )
                else
                  Container(color: Colors.grey.shade900),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Botón Seguir (placeholder v1) ──────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              ),
              child: const Text('Seguir', style: TextStyle(color: Colors.white70)),
            ),
          ),
        ),

        // ── Populares ──────────────────────────────────────────────────────
        if (state.topSongs.isNotEmpty) ...[
          _sectionHeader('Populares'),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = state.topSongs[index];
                return SongListTileWithHeart(
                  song: song,
                  queue: state.topSongs,
                  indexInQueue: index,
                  playlistName: artist.stageName,
                  playlistType: 'artist',
                );
              },
              childCount: state.topSongs.length,
            ),
          ),
        ],

        // ── Lanzamientos ───────────────────────────────────────────────────
        if (state.albums.isNotEmpty) ...[
          _sectionHeader('Lanzamientos'),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _AlbumCard(album: state.albums[index]),
                childCount: state.albums.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],

        // ── Información ────────────────────────────────────────────────────
        if (artist.bio.isNotEmpty) ...[
          _sectionHeader('Información'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    if (artist.imageUrl.isNotEmpty)
                      SizedBox(
                        height: 220,
                        width: double.infinity,
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/images/logo.png',
                          image: artist.imageUrl,
                          fit: BoxFit.cover,
                          imageErrorBuilder: (_, _, _) =>
                              Container(height: 220, color: Colors.grey.shade800),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black87, Colors.transparent],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              artist.stageName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              artist.bio,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  SliverToBoxAdapter _sectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final AlbumEntity album;
  const _AlbumCard({required this.album});

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: album.coverUrl.isNotEmpty
                  ? FadeInImage.assetNetwork(
                      placeholder: 'assets/images/logo.png',
                      image: album.coverUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      imageErrorBuilder: (_, _, _) =>
                          Container(color: Colors.grey.shade800),
                    )
                  : Container(
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.album, color: Colors.white24, size: 40),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            album.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Text('Álbum', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}
