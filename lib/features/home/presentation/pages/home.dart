import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocProvider(
        create: (context) => di.sl<HomeBloc>()..add(GetSongsEvent()),
        child: SafeArea( // Usamos SafeArea en lugar de SliverAppBar para un inicio limpio
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // --- Sección 1: Playlists Rápidas (Grid 2 columnas) ---
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3, // Ancho / Alto 
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 8, // Basado en el mockup (Playlist 1 al 8)
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              // Ícono cuadrado de la playlist
                              Container(
                                width: 50,
                                decoration: const BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    bottomLeft: Radius.circular(4),
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(Icons.image, color: Colors.white54),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Título de la playlist
                              Expanded(
                                child: Text(
                                  'Playlist ${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.black, // O blanco, depende del contraste. En el mockup el texto oscuro es visible.
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 30),

                    // --- Sección 2: Explora tu música ---
                    const Text(
                      'Explora tu música',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 220, // Altura del contenedor horizontal
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5, // Elementos simulados
                        itemBuilder: (context, index) {
                          return Container(
                            width: 150,
                            margin: const EdgeInsets.only(right: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Portada del álbum
                                Container(
                                  height: 150,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple, // Color del mockup
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.image_outlined, size: 60, color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Álbum',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                const Text(
                                  'Título del álbum',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Text(
                                  'Artista',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- Sección 3: Recientes ---
                    const Text(
                      'Recientes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 200, // Altura ligeramente menor para estos
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 130,
                            margin: const EdgeInsets.only(right: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Portada de Recientes
                                Container(
                                  height: 130,
                                  width: 130,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6A2E44), // Color vino tinto del mockup
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.image_outlined, size: 50, color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Playlist o álbum',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Text(
                                  'Título',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40), // Espacio al final
                  ]),
                ),
              ),

              // Mantengo el BlocBuilder para la versión dinámica en caso de que lo necesitemos más adelante
              // Por ahora, mostrará nuestro diseño estático arriba. Podemos renderizar los reales debajo (opcional) o quitar esto.
              // Lo comentaremos para centrarnos 100% en el mockup, pero dejaremos el bloc por si la UI necesita reaccionar
              /*
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  // ... lógica anterior de Home ...
                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
              */
            ],
          ),
        ),
      ),
    );
  }
}