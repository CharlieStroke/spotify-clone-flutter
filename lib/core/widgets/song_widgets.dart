import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/home/domain/entities/song_entity.dart';
import '../../features/player/presentation/bloc/player_cubit.dart';
import '../../features/player/presentation/pages/player_screen.dart';
import '../../features/library/presentation/widgets/add_to_playlist_sheet.dart';
import 'heart_button.dart';

/// ListTile de canción reutilizable con:
/// - Portada (Image.network o ícono fallback)
/// - Título y subtítulo
/// - Botón ❤️ de favoritos (optimistic)
/// - Menú de 3 puntos con opciones configurables
/// - onTap para reproducir (toda la cola)
class SongListTile extends StatelessWidget {
  final SongEntity song;
  final List<SongEntity> queue; // Cola completa para reproducir
  final int indexInQueue;
  final String playlistName;
  final String playlistType;

  /// Si se provee, aparece la opción "Quitar de esta playlist" en el menú
  final VoidCallback? onRemoveFromPlaylist;

  /// Si true, NO aparece la opción "Añadir a otra playlist"
  final bool isFavoritesView;

  const SongListTile({
    super.key,
    required this.song,
    required this.queue,
    required this.indexInQueue,
    this.playlistName = '',
    this.playlistType = 'playlist',
    this.onRemoveFromPlaylist,
    this.isFavoritesView = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: Hero(
        tag: 'song_${song.id}', // Usamos un tag único basado en el ID
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: song.coverUrl.isNotEmpty
              ? Image.network(
                  song.coverUrl.trim(),
                  width: 52, height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (e, s, t) => _fallbackIcon(),
                )
              : _fallbackIcon(),
        ),
      ),
      title: Text(
        song.title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artistName.isNotEmpty ? song.artistName : (song.album.isNotEmpty ? song.album : 'Artista Desconocido'),
        style: const TextStyle(color: Colors.white70, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _buildTrailing(context),
      onTap: () => _play(context),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white70),
      color: const Color(0xFF282828),
      onSelected: (value) async {
        if (value == 'playlist') {
          AddToPlaylistSheet.show(context, song);
        } else if (value == 'remove') {
          onRemoveFromPlaylist?.call();
        }
      },
      itemBuilder: (_) => [
        if (!isFavoritesView)
          const PopupMenuItem(
            value: 'playlist',
            child: Row(children: [
              Icon(Icons.playlist_add, color: Colors.white70, size: 20),
              SizedBox(width: 10),
              Text('Añadir a playlist', style: TextStyle(color: Colors.white)),
            ]),
          ),
        // El Heart button dentro del menú NO funciona bien, usamos PopupMenuItem visual
        // El toggle real se hace con HeartButton en el row de trailing
        if (isFavoritesView || onRemoveFromPlaylist != null)
          PopupMenuItem(
            value: 'remove',
            child: Row(children: [
              Icon(
                isFavoritesView ? Icons.favorite_border : Icons.remove_circle_outline,
                color: Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                isFavoritesView ? 'Quitar de favoritos' : 'Quitar de playlist',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ]),
          ),
      ],
    );
  }

  Widget _fallbackIcon() {
    return Container(
      width: 52, height: 52,
      color: Colors.grey.shade800,
      child: const Icon(Icons.music_note, color: Colors.white54),
    );
  }

  void _play(BuildContext context) {
    context.read<PlayerCubit>().playPlaylist(
      queue,
      initialIndex: indexInQueue,
      playlistName: playlistName,
      playlistType: playlistType,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PlayerScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}

/// Variante de [SongListTile] con el HeartButton visible directamente
/// en el trailing (sin PopupMenu de favoritos).
class SongListTileWithHeart extends StatelessWidget {
  final SongEntity song;
  final List<SongEntity> queue;
  final int indexInQueue;
  final String playlistName;
  final String playlistType;
  final VoidCallback? onRemoveFromPlaylist;
  final bool isFavoritesView;

  const SongListTileWithHeart({
    super.key,
    required this.song,
    required this.queue,
    required this.indexInQueue,
    this.playlistName = '',
    this.playlistType = 'playlist',
    this.onRemoveFromPlaylist,
    this.isFavoritesView = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: Hero(
        tag: 'song_heart_${song.id}', // Tag único para la vista de favoritos
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: song.coverUrl.isNotEmpty
              ? Image.network(
                  song.coverUrl.trim(),
                  width: 52, height: 52, fit: BoxFit.cover,
                  errorBuilder: (e, s, t) => _fallbackIcon(),
                )
              : _fallbackIcon(),
        ),
      ),
      title: Text(song.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(song.artistName.isNotEmpty ? song.artistName : (song.album.isNotEmpty ? song.album : 'Artista Desconocido'),
          style: const TextStyle(color: Colors.white70, fontSize: 12),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeartButton(song: song, size: 22),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            color: const Color(0xFF282828),
            onSelected: (value) {
              if (value == 'playlist') AddToPlaylistSheet.show(context, song);
              if (value == 'remove') onRemoveFromPlaylist?.call();
            },
            itemBuilder: (_) => [
              if (!isFavoritesView)
                const PopupMenuItem(value: 'playlist', child: Row(children: [
                  Icon(Icons.playlist_add, color: Colors.white70, size: 20),
                  SizedBox(width: 10),
                  Text('Añadir a playlist', style: TextStyle(color: Colors.white)),
                ])),
              if (isFavoritesView || onRemoveFromPlaylist != null)
                PopupMenuItem(value: 'remove', child: Row(children: [
                  Icon(isFavoritesView ? Icons.favorite_border : Icons.remove_circle_outline,
                      color: Colors.redAccent, size: 20),
                  const SizedBox(width: 10),
                  Text(isFavoritesView ? 'Quitar de favoritos' : 'Quitar de playlist',
                      style: const TextStyle(color: Colors.redAccent)),
                ])),
            ],
          ),
        ],
      ),
      onTap: () {
        context.read<PlayerCubit>().playPlaylist(
          queue, initialIndex: indexInQueue,
          playlistName: playlistName, playlistType: playlistType,
        );
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const PlayerScreen(), fullscreenDialog: true,
        ));
      },
    );
  }

  Widget _fallbackIcon() => Container(
    width: 52, height: 52,
    color: Colors.grey.shade800,
    child: const Icon(Icons.music_note, color: Colors.white54),
  );
}

/// Tarjeta de playlist en la biblioteca (imagen cuadrada + nombre)
class PlaylistCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? coverUrl;
  final VoidCallback onTap;

  const PlaylistCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.coverUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Hero(
              tag: 'playlist_cover_$title',
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF6A2C50),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: coverUrl != null && coverUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Image.network(
                          coverUrl!.trim(),
                          fit: BoxFit.cover,
                          errorBuilder: (e, s, t) => const Center(
                            child: Icon(Icons.photo_outlined, color: Colors.white, size: 40),
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.photo_outlined, color: Colors.white, size: 40),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ALBUM CARD - Tarjeta vertical de álbum (cover + título + artista)
// ─────────────────────────────────────────────────────────────────────────────

/// Tarjeta vertical de álbum para secciones horizontales (home, search).
class AlbumCard extends StatelessWidget {
  final String title;
  final String artistName;
  final String? coverUrl;
  final double width;
  final double imageSize;
  final VoidCallback onTap;

  const AlbumCard({
    super.key,
    required this.title,
    required this.artistName,
    this.coverUrl,
    this.width = 150,
    this.imageSize = 150,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'album_cover_$title',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (coverUrl != null && coverUrl!.trim().isNotEmpty)
                    ? Image.network(
                        coverUrl!.trim(),
                        width: width,
                        height: imageSize,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            width: width, height: imageSize,
                            color: Colors.white10,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                            ),
                          );
                        },
                        errorBuilder: (e, s, t) => _fallback(),
                      )
                    : _fallback(),
              ),
            ),
            const SizedBox(height: 6),
            Text('Álbum',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(artistName,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _fallback() => Container(
    width: width, height: imageSize,
    decoration: BoxDecoration(
      color: Colors.deepPurple,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.album, size: 50, color: Colors.white54),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME PLAYLIST CHIP - Chip rectangular para el grid 2x de playlists rápidas
// ─────────────────────────────────────────────────────────────────────────────

/// Chip rectangular del grid de playlists rápidas del Home.
class HomePlaylistChip extends StatelessWidget {
  final String name;
  final String? coverUrl;
  final VoidCallback onTap;

  const HomePlaylistChip({
    super.key,
    required this.name,
    this.coverUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(20, 255, 255, 255), // Sutilmente blanco
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Hero(
              tag: 'playlist_cover_$name',
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white10,
                  ),
                  child: (coverUrl != null && coverUrl!.isNotEmpty)
                      ? Image.network(
                          coverUrl!.trim(),
                          fit: BoxFit.cover,
                          errorBuilder: (e, s, t) =>
                              const Center(child: Icon(Icons.music_note, color: Colors.white38)),
                        )
                      : const Center(child: Icon(Icons.music_note, color: Colors.white38)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FAVORITES CARD - Tarjeta especial de "Mis Favoritos" con gradiente morado
// ─────────────────────────────────────────────────────────────────────────────

/// Tarjeta especial de "Mis Favoritos" que muestra el conteo de canciones.
/// Conectada a [FavoritesBloc] para mostrar el número correcto.
class FavoritesCard extends StatelessWidget {
  final VoidCallback onTap;

  const FavoritesCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Accedemos al FavoritesBloc a través del context (ya está provisto globalmente)
    // Usamos un Builder para leer correctamente los blocs
    return GestureDetector(
      onTap: onTap,
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
              width: 54, height: 54,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.favorite, color: Colors.redAccent, size: 30),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mis Favoritos',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Tus canciones favoritas',
                    style: TextStyle(color: Colors.white60, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
