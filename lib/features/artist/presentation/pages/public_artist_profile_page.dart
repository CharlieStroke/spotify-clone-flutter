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

        // ── Stats + Follow ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatPlays(artist.totalPlays),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_formatCount(artist.followersCount)} seguidores',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => context
                      .read<PublicArtistProfileCubit>()
                      .toggleFollow(widget.artistId),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: artist.isFollowing ? AppColors.primary : Colors.white54,
                    ),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                  child: Text(
                    artist.isFollowing ? 'Siguiendo' : 'Seguir',
                    style: TextStyle(
                      color: artist.isFollowing ? AppColors.primary : Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
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
                  showPlays: true,
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
              child: GestureDetector(
                onTap: () => _showBioModal(context, artist.stageName,
                    artist.imageUrl, artist.bio),
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
                                    fontSize: 18),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                artist.bio,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Ver más',
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
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
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  void _showBioModal(
      BuildContext context, String name, String imageUrl, String bio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(0)),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/logo.png',
                    image: imageUrl,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (_, _, _) =>
                        Container(height: 220, color: Colors.grey.shade800),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      bio,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

  String _formatPlays(int plays) {
    if (plays >= 1000000) {
      return '${(plays / 1000000).toStringAsFixed(1)} M reproducciones';
    }
    if (plays >= 1000) {
      return '${(plays / 1000).toStringAsFixed(1)} K reproducciones';
    }
    return '$plays reproducciones';
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)} M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)} K';
    return count.toString();
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
                      child: const Icon(Icons.album,
                          color: Colors.white24, size: 40),
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
          const Text('Álbum',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}
