import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../home/presentation/bloc/home_event.dart';
import '../../../library/presentation/bloc/library_bloc.dart';
import '../../../library/presentation/bloc/library_event.dart';
import '../../../../core/widgets/page_layout.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Perfil',
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (state is ProfileError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.redAccent, fontSize: 16)));
          } else if (state is ProfileLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.white10,
                        backgroundImage: (state.artist?.imageUrl != null)
                            ? NetworkImage(state.artist!.imageUrl)
                            : (state.user.profileImageUrl != null && state.user.profileImageUrl!.isNotEmpty)
                                ? NetworkImage(state.user.profileImageUrl!)
                                : null,
                        child: (state.artist?.imageUrl == null && (state.user.profileImageUrl == null || state.user.profileImageUrl!.isEmpty))
                            ? const Icon(Icons.person, size: 80, color: Colors.white24)
                            : null,
                      ),
                      if (state.artist != null)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                            child: const Icon(Icons.check, color: Colors.white, size: 20),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.artist?.stageName ?? state.user.username,
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  if (state.artist != null) ...[
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified, color: Colors.blue, size: 16),
                        SizedBox(width: 4),
                        Text('Artista Verificado', style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(user: state.user),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white30),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text('Editar Perfil', style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                  const SizedBox(height: 32),
                  
                  if (state.artist?.bio != null && state.artist!.bio.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('Sobre el artista', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        state.artist!.bio,
                        style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text('Información personal', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        _infoTile(Icons.alternate_email, 'Usuario', state.user.username),
                        const Divider(color: Colors.white10, height: 30),
                        _infoTile(Icons.email_outlined, 'Email', state.user.email),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      final prefs = di.sl<SharedPreferences>();
                      await prefs.remove('token');
                      if (context.mounted) {
                        di.sl<HomeBloc>().add(ResetHomeEvent());
                        di.sl<LibraryBloc>().add(ResetLibraryEvent());
                        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.initial, (route) => false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
          return const Center(child: Text('Cargando perfil...', style: TextStyle(color: Colors.white)));
        },
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}
