import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Aplicamos el fondo oscuro con degradado superior sutil
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 81, 21, 88), // Azul muy oscuro profundo
              Color(0xFF000000), // Negro puro
            ],
          ),
        ),
        child: BlocProvider(
          create: (context) => di.sl<HomeBloc>()..add(GetSongsEvent()),
          child: CustomScrollView(
            slivers: [
              // AppBar moderno y transparente que desaparece al hacer scroll
              const SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                centerTitle: true,
                title: Text(
                  'Explora tu música',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: Colors.green)),
                    );
                  }

                  if (state is HomeLoaded) {
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final song = state.songs[index];
                            return _SongCard(song: song);
                          },
                          childCount: state.songs.length,
                        ),
                      ),
                    );
                  }

                  if (state is HomeFailure) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          state.errorMessage,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget de Tarjeta de Canción Estilizado
class _SongCard extends StatelessWidget {
  final dynamic song; // Usa tu SongEntity aquí

  const _SongCard({required this.song});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), // Efecto cristal esmerilado
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            song.coverUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            // Si el bucket es privado y falla, muestra un placeholder elegante
            errorBuilder: (_, __, ___) => Container(
              width: 60,
              height: 60,
              color: Colors.grey[800],
              child: const Icon(Icons.music_note, color: Colors.greenAccent),
            ),
          ),
        ),
        title: Text(
          song.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.album,
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.play_circle_fill, color: Colors.greenAccent, size: 35),
          onPressed: () {
            // TODO: Implementar lógica de reproducción
          },
        ),
      ),
    );
  }
}