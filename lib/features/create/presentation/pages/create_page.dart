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
import 'package:spotify_clone/core/widgets/empty_state_widget.dart';
import 'package:spotify_clone/features/artist/presentation/bloc/artist_bloc.dart';
import 'package:spotify_clone/features/artist/presentation/bloc/artist_event.dart';
import 'package:spotify_clone/features/artist/presentation/bloc/artist_state.dart';
import 'package:spotify_clone/features/artist/presentation/cubit/artist_stats_cubit.dart';
import 'package:spotify_clone/features/artist/domain/entities/artist_stats_entity.dart';
import 'package:spotify_clone/core/extensions/extensions.dart';

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
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Disparar verificación de artista cuando la pantalla ya está montada
    // (el usuario está autenticado en este punto)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ArtistBloc>().add(CheckArtistStatusEvent());
      }
    });
  }

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
    final durationController = TextEditingController();
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
                const SizedBox(height: 12),
                TextField(
                  controller: durationController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Duración en segundos (ej: 210)',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
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
                  label: Text(selectedAudio == null ? 'Seleccionar Audio' : 'Audio: ${selectedAudio!.path.split(RegExp(r"[\\/]")).last}'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white12, foregroundColor: Colors.white),
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final dur = int.tryParse(durationController.text.trim());
                    if (titleController.text.isNotEmpty && selectedAudio != null && _selectedImage != null && selectedAlbumId != null && dur != null && dur > 0) {
                      bloc.add(UploadSongEvent(
                        title: titleController.text.trim(),
                        albumId: selectedAlbumId!,
                        audio: selectedAudio!,
                        cover: _selectedImage!,
                        duration: dur,
                      ));
                      Navigator.pop(context);
                    } else if (dur == null || dur <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ingresa una duración válida en segundos'), backgroundColor: Colors.orange),
                      );
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Playlist "${state.playlist.name}" creada'),
                  backgroundColor: AppColors.primary));
              context.read<LibraryBloc>().add(LoadLibraryEvent());
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PlaylistDetailPage(
                            id: state.playlist.id.toString(),
                            title: state.playlist.name,
                            type: 'playlist',
                            coverUrl: state.playlist.coverUrl,
                            ownerId: state.playlist.userId,
                          )));
            } else if (state is CreatePlaylistFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error), backgroundColor: Colors.red));
            }
          },
        ),
        BlocListener<ArtistBloc, ArtistState>(
          listener: (context, state) {
            if (state is ArtistRegistrationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('¡Ya eres artista!'), backgroundColor: AppColors.primary));
              context.read<ArtistBloc>().add(CheckArtistStatusEvent());
            } else if (state is CreateAlbumSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Álbum "${state.album.title}" creado'),
                  backgroundColor: AppColors.primary));
              context.read<ArtistBloc>().add(LoadArtistAlbumsEvent());
            } else if (state is UploadSongSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Canción "${state.song.title}" subida'),
                  backgroundColor: AppColors.primary));
              context.read<ArtistBloc>().add(LoadArtistAlbumsEvent());
            } else if (state is UploadSongFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Error al subir: ${state.message}'), backgroundColor: Colors.red));
              context.read<ArtistBloc>().add(LoadArtistAlbumsEvent());
            } else if (state is CreateAlbumFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Error: ${state.message}'), backgroundColor: Colors.red));
              context.read<ArtistBloc>().add(CheckArtistStatusEvent());
            } else if (state is ArtistFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
        ),
      ],
      child: PageLayout(
        title: 'Crear',
        useScroll: false,
        padding: EdgeInsets.zero,
        child: BlocBuilder<ArtistBloc, ArtistState>(
          builder: (context, artistState) {
            if (artistState is ArtistLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            final isArtist = artistState is ArtistStatusLoaded
                ? artistState.isArtist
                : (artistState is ArtistRegistrationSuccess ||
                    artistState is ArtistAlbumsLoaded ||
                    artistState is CreateAlbumSuccess ||
                    artistState is UploadSongSuccess);

            if (!isArtist) {
              return _buildCreateContent(context, isArtist: false);
            }

            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: AppColors.primary,
                    indicatorColor: AppColors.primary,
                    unselectedLabelColor: Colors.white54,
                    tabs: const [
                      Tab(text: 'Crear'),
                      Tab(text: 'Estadísticas'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildCreateContent(context, isArtist: true),
                        BlocProvider(
                          create: (_) => sl<ArtistStatsCubit>()..loadStats(),
                          child: const _ArtistStatsTabBody(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCreateContent(BuildContext context, {required bool isArtist}) {
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
          const SizedBox(height: 40),
        ],
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

// ─── Stats Tab ────────────────────────────────────────────────────────────────

class _ArtistStatsTabBody extends StatelessWidget {
  const _ArtistStatsTabBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArtistStatsCubit, ArtistStatsState>(
      builder: (context, state) {
        if (state is ArtistStatsLoading || state is ArtistStatsInitial) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is ArtistStatsError) {
          return EmptyStateWidget(
            icon: Icons.bar_chart,
            title: 'Error al cargar estadísticas',
            message: state.message,
            buttonText: 'Reintentar',
            onButtonPressed: () => context.read<ArtistStatsCubit>().retry(),
          );
        }
        if (state is ArtistStatsLoaded) {
          final stats = state.stats;
          if (stats.totalSongs == 0) {
            return const EmptyStateWidget(
              icon: Icons.bar_chart,
              title: 'Sin datos',
              message: 'Aún no tienes canciones subidas',
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TotalPlaysCard(stats: stats),
                const SizedBox(height: 24),
                _TopSongsSection(songs: stats.topSongs),
                const SizedBox(height: 24),
                _PlaysByAlbumSection(albums: stats.playsByAlbum),
                const SizedBox(height: 40),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _TotalPlaysCard extends StatelessWidget {
  final ArtistStatsEntity stats;
  const _TotalPlaysCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.6), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.music_note, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            '${formatPlays(stats.totalPlays)} reproducciones',
            style: const TextStyle(
                color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${stats.totalSongs} canciones · ${stats.totalAlbums} álbumes',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _TopSongsSection extends StatelessWidget {
  final List<TopSongEntity> songs;
  const _TopSongsSection({required this.songs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Top canciones',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...songs.asMap().entries.map((entry) {
          final i = entry.key;
          final song = entry.value;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  child: Text('${i + 1}',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    song.coverUrl,
                    width: 44, height: 44, fit: BoxFit.cover,
                    errorBuilder: (_, e, s) =>
                        Container(width: 44, height: 44, color: AppColors.coverPlaceholder),
                  ),
                ),
              ],
            ),
            title: Text(song.title,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            trailing: Text(formatPlays(song.plays),
                style: const TextStyle(color: Colors.white54, fontSize: 13)),
          );
        }),
      ],
    );
  }
}

class _PlaysByAlbumSection extends StatelessWidget {
  final List<AlbumPlaysEntity> albums;
  const _PlaysByAlbumSection({required this.albums});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Por álbum',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: albums
                .map((a) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              a.coverUrl,
                              width: 100, height: 100, fit: BoxFit.cover,
                              errorBuilder: (_, e, s) => Container(
                                  width: 100,
                                  height: 100,
                                  color: AppColors.coverPlaceholder),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 100,
                            child: Text(a.title,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center),
                          ),
                          Text(formatPlays(a.plays),
                              style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
