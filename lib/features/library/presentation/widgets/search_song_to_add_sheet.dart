import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../../injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../search/presentation/bloc/search_bloc.dart';
import '../../../search/presentation/bloc/search_event.dart';
import '../../../search/presentation/bloc/search_state.dart';
import '../bloc/library_action_bloc.dart';
import '../bloc/library_action_event.dart';
import '../bloc/library_action_state.dart';

import '../../../playlist_detail/presentation/bloc/detail_bloc.dart';
import '../../../playlist_detail/presentation/bloc/detail_event.dart';

class SearchSongToAddSheet extends StatefulWidget {
  final String playlistId;
  final PlaylistDetailBloc? detailBloc;

  const SearchSongToAddSheet({super.key, required this.playlistId, this.detailBloc});

  static void show(BuildContext context, String playlistId, {PlaylistDetailBloc? detailBloc}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SearchSongToAddSheet(playlistId: playlistId, detailBloc: detailBloc),
    );
  }

  @override
  State<SearchSongToAddSheet> createState() => _SearchSongToAddSheetState();
}

class _SearchSongToAddSheetState extends State<SearchSongToAddSheet> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  late SearchBloc _searchBloc;
  late LibraryActionBloc _actionBloc;

  @override
  void initState() {
    super.initState();
    _searchBloc = sl<SearchBloc>();
    _actionBloc = sl<LibraryActionBloc>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _searchBloc.close(); // Cerrar el bloc local para no consumir memoria al cerrar el modal
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _searchBloc.add(SearchQueryChanged(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _searchBloc),
        BlocProvider.value(value: _actionBloc),
      ],
      child: BlocListener<LibraryActionBloc, LibraryActionState>(
        listener: (context, state) {
          if (state is LibraryActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primary,
                duration: const Duration(seconds: 2),
              ),
            );
            // Refrescar playlist si tenemos el bloc
            if (widget.detailBloc != null) {
              widget.detailBloc!.add(LoadPlaylistDetailEvent(id: widget.playlistId, type: 'playlist'));
            }
          } else if (state is LibraryActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0, // Elevar cuando salga teclado
          ),
          height: MediaQuery.of(context).size.height * 0.8, // Ocupa el 80%
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabezal o título del Modal
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Añadir a esta playlist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Barra de Búsqueda
              Container(
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Buscar canciones...',
                    hintStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.search, color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              
              const SizedBox(height: 16),

              // Resultados de Búsqueda
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    } else if (state is SearchFailure) {
                      return Center(child: Text(state.error, style: const TextStyle(color: Colors.red)));
                    } else if (state is SearchLoaded) {
                      final songs = state.songs;

                      if (songs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No se encontraron canciones',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index]; // es un SongEntity / SongModel
                          final String songId = song.id;
                          final String title = song.title;
                          final String artist = song.album.isNotEmpty ? song.album : 'Artista desconocido';
                          final String coverUrl = song.coverUrl;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 4),
                            leading: Container(
                              width: 50,
                              height: 50,
                              color: const Color(0xFF6A2C50),
                              child: coverUrl.isNotEmpty
                                  ? FadeInImage.assetNetwork(
                                      placeholder: 'assets/images/logo.png',
                                      image: coverUrl,
                                      fit: BoxFit.cover,
                                      imageErrorBuilder: (e, s, t) => const Icon(Icons.music_note, color: Colors.white),
                                    )
                                  : const Icon(Icons.music_note, color: Colors.white),
                            ),
                            title: Text(
                              title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              artist, 
                              style: const TextStyle(color: Colors.white70),
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 28),
                              onPressed: () {
                                if (songId.isNotEmpty) {
                                  context.read<LibraryActionBloc>().add(
                                    AddSongEvent(
                                      playlistId: widget.playlistId, 
                                      songId: songId,
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      );
                    }
                    
                    // Estado Initial
                    return const Center(
                      child: Text(
                        'Busca tu canción favorita y añadela.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
