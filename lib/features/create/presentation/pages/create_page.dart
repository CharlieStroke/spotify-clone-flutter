import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/create_playlist_bloc.dart';
import '../bloc/create_playlist_event.dart';
import '../bloc/create_playlist_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../library/presentation/bloc/library_bloc.dart';
import '../../../library/presentation/bloc/library_event.dart';
import '../../../playlist_detail/presentation/pages/playlist_detail_page.dart';
import '../../../../core/widgets/page_layout.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CreatePlaylistBloc>(),
      child: const CreatePlaylistView(),
    );
  }
}

class CreatePlaylistView extends StatefulWidget {
  const CreatePlaylistView({super.key});

  @override
  State<CreatePlaylistView> createState() => _CreatePlaylistViewState();
}

class _CreatePlaylistViewState extends State<CreatePlaylistView> {
  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final bloc = context.read<CreatePlaylistBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF282828),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nombra tu playlist',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: nameController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'Ej. Canciones tristes para llorar',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                  border: InputBorder.none,
                ),
              ),
              const Divider(color: Colors.grey),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white70),
                decoration: const InputDecoration(
                  hintText: 'Agrega una descripción opcional...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(bottomSheetContext),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isNotEmpty) {
                        bloc.add(SubmitPlaylistEvent(name: name, description: descController.text.trim()));
                        Navigator.pop(bottomSheetContext);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Crear', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreatePlaylistBloc, CreatePlaylistState>(
      listener: (context, state) {
        if (state is CreatePlaylistSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Playlist "${state.playlist.name}" creada con éxito'),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 3),
            ),
          );
          // Actualizamos la biblioteca
          context.read<LibraryBloc>().add(LoadLibraryEvent());
          // Navegamos al detalle de la playlist
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaylistDetailPage(
                id: state.playlist.id.toString(),
                title: state.playlist.name,
                type: 'playlist',
                coverUrl: null,
                ownerId: state.playlist.userId,
              ),
            ),
          );
        } else if (state is CreatePlaylistFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: PageLayout(
        title: 'Crear Playlist',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Icon(Icons.queue_music, size: 80, color: Colors.grey.shade700),
            const SizedBox(height: 20),
            const Text(
              'Crea tu primera playlist',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),          
            const SizedBox(height: 30),
            BlocBuilder<CreatePlaylistBloc, CreatePlaylistState>(
              builder: (context, state) {
                if (state is CreatePlaylistLoading) {
                  return const CircularProgressIndicator(color: AppColors.primary);
                }
                
                return ElevatedButton(
                  onPressed: () => _showCreateDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  ),
                  child: const Text('Crear playlist', style: TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
