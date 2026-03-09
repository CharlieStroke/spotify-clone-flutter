import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:spotify_clone/injection_container.dart';
import 'package:spotify_clone/features/create/presentation/bloc/create_playlist_bloc.dart';
import 'package:spotify_clone/features/create/presentation/bloc/create_playlist_event.dart';
import 'package:spotify_clone/features/create/presentation/bloc/create_playlist_state.dart';
import 'package:spotify_clone/core/theme/app_colors.dart';
import 'package:spotify_clone/features/library/presentation/bloc/library_bloc.dart';
import 'package:spotify_clone/features/library/presentation/bloc/library_event.dart';
import 'package:spotify_clone/features/playlist_detail/presentation/pages/playlist_detail_page.dart';
import 'package:spotify_clone/features/home/domain/entities/album_entity.dart';
import 'package:spotify_clone/core/widgets/page_layout.dart';
import 'package:spotify_clone/features/artist/presentation/bloc/artist_bloc.dart';
import 'package:spotify_clone/features/artist/presentation/bloc/artist_event.dart';
import 'package:spotify_clone/features/artist/presentation/bloc/artist_state.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<CreatePlaylistBloc>()),
        BlocProvider(create: (_) => sl<ArtistBloc>()..add(CheckArtistStatusEvent())),
      ],
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
  File? _selectedImage;

  Future<void> _pickImage(StateSetter setStateDialog) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setStateDialog(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final bloc = context.read<CreatePlaylistBloc>();
    _selectedImage = null; // Reset al abrir

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF282828),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center, // Centrado para la imagen
                children: [
                  const Text(
                    'Nombra tu playlist',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  // Selector de Imagen de Portada
                  GestureDetector(
                    onTap: () => _pickImage(setStateDialog),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                        image: _selectedImage != null 
                          ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                          : null,
                      ),
                      child: _selectedImage == null 
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: Colors.white54, size: 40),
                              SizedBox(height: 8),
                              Text('Elegir portada', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          )
                        : null,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: 'Nombre de la playlist',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(color: Colors.grey),
                  TextField(
                    controller: descController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                    decoration: const InputDecoration(
                      hintText: 'Descripción (opcional)',
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
                            bloc.add(SubmitPlaylistEvent(
                              name: name, 
                              description: descController.text.trim(),
                              image: _selectedImage,
                            ));
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
          }
        );
      },
    );
  }

  void _showArtistRegistrationDialog(BuildContext context) {
    final stageNameController = TextEditingController();
    final bioController = TextEditingController();
    final bloc = context.read<ArtistBloc>();
    _selectedImage = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF282828),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Crear perfil de Artista', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _pickImage(setStateDialog),
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    shape: BoxShape.circle,
                    image: _selectedImage != null ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover) : null,
                  ),
                  child: _selectedImage == null ? const Icon(Icons.camera_alt, color: Colors.white54) : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: stageNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'Nombre Artístico', hintStyle: TextStyle(color: Colors.grey)),
              ),
              TextField(
                controller: bioController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'Biografía (breve)', hintStyle: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (stageNameController.text.isNotEmpty && _selectedImage != null) {
                    bloc.add(RegisterArtistEvent(
                      stageName: stageNameController.text.trim(),
                      bio: bioController.text.trim(),
                      image: _selectedImage!,
                    ));
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
                child: const Text('Comenzar mi carrera'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateAlbumDialog(BuildContext context) {
    final titleController = TextEditingController();
    final bloc = context.read<ArtistBloc>();
    _selectedImage = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF282828),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Crear Álbum', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _pickImage(setStateDialog),
                child: Container(
                  width: 150, height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    image: _selectedImage != null ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover) : null,
                  ),
                  child: _selectedImage == null ? const Icon(Icons.add_a_photo, color: Colors.white54, size: 40) : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'Título del álbum', hintStyle: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty && _selectedImage != null) {
                    bloc.add(CreateAlbumEvent(title: titleController.text.trim(), cover: _selectedImage!));
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
                child: const Text('Crear Álbum'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadSongDialog(BuildContext context) {
    final titleController = TextEditingController();
    final bloc = context.read<ArtistBloc>();
    _selectedImage = null;
    File? selectedAudio;
    int? selectedAlbumId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF282828),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => BlocProvider.value(
        value: bloc,
        child: StatefulBuilder(
          builder: (context, setStateDialog) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              left: 20, right: 20, top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Subir Canción', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _pickImage(setStateDialog),
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      image: _selectedImage != null ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover) : null,
                    ),
                    child: _selectedImage == null ? const Icon(Icons.add_a_photo, color: Colors.white54) : null,
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Portada de la canción', style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(hintText: 'Título de la canción', hintStyle: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 20),
                
                // Selector de Álbum
                BlocBuilder<ArtistBloc, ArtistState>(
                  builder: (context, state) {
                    List<AlbumEntity> albums = [];
                    if (state is ArtistAlbumsLoaded) {
                      albums = state.albums;
                    } else if (bloc.state is ArtistAlbumsLoaded) {
                      albums = (bloc.state as ArtistAlbumsLoaded).albums;
                    }

                    return DropdownButtonFormField<int>(
                      dropdownColor: const Color(0xFF282828),
                      initialValue: selectedAlbumId,
                      hint: const Text('Seleccionar Álbum', style: TextStyle(color: Colors.grey)),
                      items: albums.map((a) => DropdownMenuItem(
                        value: a.id,
                        child: Text(a.title, style: const TextStyle(color: Colors.white)),
                      )).toList(),
                      onChanged: (val) => setStateDialog(() => selectedAlbumId = val),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
                    if (result != null) {
                      setStateDialog(() => selectedAudio = File(result.files.single.path!));
                    }
                  },
                  icon: const Icon(Icons.audio_file),
                  label: Text(selectedAudio == null ? 'Seleccionar Audio' : 'Audio: ${selectedAudio!.path.split('/').last}'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white12, foregroundColor: Colors.white),
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty && selectedAudio != null && _selectedImage != null && selectedAlbumId != null) {
                      bloc.add(UploadSongEvent(
                        title: titleController.text.trim(),
                        albumId: selectedAlbumId!,
                        audio: selectedAudio!,
                        cover: _selectedImage!,
                      ));
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
                  child: const Text('Subir Canción'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CreatePlaylistBloc, CreatePlaylistState>(
          listener: (context, state) {
            if (state is CreatePlaylistSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Playlist "${state.playlist.name}" creada'), backgroundColor: AppColors.primary));
              context.read<LibraryBloc>().add(LoadLibraryEvent());
              Navigator.push(context, MaterialPageRoute(builder: (_) => PlaylistDetailPage(
                id: state.playlist.id.toString(),
                title: state.playlist.name,
                type: 'playlist',
                coverUrl: state.playlist.coverUrl,
                ownerId: state.playlist.userId,
              )));
            } else if (state is CreatePlaylistFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: Colors.red));
            }
          },
        ),
        BlocListener<ArtistBloc, ArtistState>(
          listener: (context, state) {
            if (state is ArtistRegistrationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Ya eres artista!'), backgroundColor: AppColors.primary));
              context.read<ArtistBloc>().add(CheckArtistStatusEvent());
            } else if (state is CreateAlbumSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Álbum "${state.album.title}" creado'), backgroundColor: AppColors.primary));
              context.read<ArtistBloc>().add(LoadArtistAlbumsEvent()); // Recargar álbumes
            } else if (state is UploadSongSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Canción "${state.song.title}" subida'), backgroundColor: AppColors.primary));
            } else if (state is ArtistFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
        ),
      ],
      child: PageLayout(
        title: 'Crear',
        child: BlocBuilder<ArtistBloc, ArtistState>(
          builder: (context, artistState) {
            if (artistState is ArtistLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            bool isArtist = false;
            if (artistState is ArtistStatusLoaded) {
              isArtist = artistState.isArtist;
            } else if (artistState is ArtistRegistrationSuccess) {
              isArtist = true;
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildOptionCard(
                    title: 'Playlist',
                    subtitle: 'Crea una recopilación de tus canciones favoritas.',
                    icon: Icons.queue_music,
                    onTap: () => _showCreateDialog(context),
                  ),
                  if (isArtist) ...[
                    const SizedBox(height: 15),
                    _buildOptionCard(
                      title: 'Álbum',
                      subtitle: 'Publica una nueva colección de canciones.',
                      icon: Icons.album,
                      color: Colors.blueAccent,
                      onTap: () => _showCreateAlbumDialog(context),
                    ),
                    const SizedBox(height: 15),
                    _buildOptionCard(
                      title: 'Canción',
                      subtitle: 'Sube un nuevo track para tus fans.',
                      icon: Icons.audiotrack,
                      color: Colors.orangeAccent,
                      onTap: () {
                        context.read<ArtistBloc>().add(LoadArtistAlbumsEvent());
                        _showUploadSongDialog(context);
                      },
                    ),
                  ],
                  if (!isArtist && artistState is! ArtistLoading) ...[
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.star, color: AppColors.primary, size: 40),
                          const SizedBox(height: 10),
                          const Text('¿Eres músico?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          const Text(
                            'Conviértete en artista para subir tus propias canciones y álbumes a Spotify Clone.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: () => _showArtistRegistrationDialog(context),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
                            child: const Text('Hacerse Artista', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color color = AppColors.primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF282828),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
