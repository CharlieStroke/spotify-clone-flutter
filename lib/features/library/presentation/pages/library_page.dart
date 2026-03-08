import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../playlist_detail/presentation/pages/playlist_detail_page.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LibraryBloc>()..add(LoadLibraryEvent()),
      child: const LibraryView(),
    );
  }
}

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // O gradient
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20.0, top: 40.0, bottom: 20.0),
              child: Text(
                'Tu biblioteca',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<LibraryBloc, LibraryState>(
                builder: (context, state) {
                  if (state is LibraryLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  } else if (state is LibraryFailure) {
                    return Center(child: Text(state.error, style: const TextStyle(color: Colors.red)));
                  } else if (state is LibraryLoaded) {
                    return _buildGrid(state.playlists);
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

  Widget _buildGrid(List<dynamic> playlists) {
    // Si la lista está vacía podemos mostrar placeholders temporales o un mensaje
    final itemsCount = playlists.isEmpty ? 12 : playlists.length; 

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        itemCount: itemsCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, 
          crossAxisSpacing: 15,
          mainAxisSpacing: 25,
          childAspectRatio: 0.65, // Ajustar para acomodar imagen + texto
        ),
        itemBuilder: (context, index) {
          
          String title = 'Título';
          String subtitle = 'Playlist o álbum';
          String? coverUrl;
          String id = '';

          if (playlists.isNotEmpty && index < playlists.length) {
            title = playlists[index].name;
            subtitle = 'Playlist'; 
            id = playlists[index].id.toString();
            coverUrl = null; // Las playlists no tienen cover_url en la BD actual
          }

          return GestureDetector(
            onTap: () {
              if (id.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaylistDetailPage(
                      id: id,
                      title: title,
                      type: 'playlist', // Asumimos playlist por ahora hasta introducir mixtos
                      coverUrl: coverUrl,
                    ),
                  ),
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Cuadro Morado
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A2C50), // Color morado del mockup
                    borderRadius: BorderRadius.circular(2), // Bordes ligeramente redondeados o cuadrados
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.photo_outlined, 
                      color: Colors.white, 
                      size: 45,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Subtítulo (Playlist o álbum)
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Título principal
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

