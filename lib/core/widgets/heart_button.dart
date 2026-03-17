import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../features/favorites/presentation/bloc/favorites_event.dart';
import '../../features/favorites/presentation/bloc/favorites_state.dart';
import '../../features/home/domain/entities/song_entity.dart';

/// Botón de corazón reutilizable que conecta directamente con [FavoritesBloc].
/// Hace optimistic update inmediato (el color cambia al instante).
/// Muestra un SnackBar opcional de feedback.
class HeartButton extends StatelessWidget {
  final SongEntity song;
  final double size;
  final bool showSnackBar;

  const HeartButton({
    super.key,
    required this.song,
    this.size = 26,
    this.showSnackBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        final isFav = state is FavoritesLoaded && state.isFavorite(song.id);
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            transitionBuilder: (child, anim) {
              return ScaleTransition(
                scale: CurvedAnimation(
                  parent: anim,
                  curve: Curves.elasticOut,
                  reverseCurve: Curves.easeIn,
                ),
                child: child,
              );
            },
            child: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isFav),
              color: isFav ? Colors.red : Colors.white70,
              size: size,
            ),
          ),
          onPressed: () => _toggle(context, isFav),
        );
      },
    );
  }

  void _toggle(BuildContext context, bool isFav) {
    final favBloc = context.read<FavoritesBloc>();
    if (isFav) {
      favBloc.add(RemoveFavoriteEvent(song.id));
      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eliminado de Mis Favoritos'),
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      favBloc.add(AddFavoriteEvent(song.id, song: song));
      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Añadido a Mis Favoritos'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
