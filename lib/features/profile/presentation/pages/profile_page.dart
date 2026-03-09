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
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white24,
                  backgroundImage: (state.user.profileImageUrl != null && state.user.profileImageUrl!.isNotEmpty)
                      ? NetworkImage(state.user.profileImageUrl!)
                      : null,
                  child: (state.user.profileImageUrl == null || state.user.profileImageUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 100, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  state.user.username,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Editar Perfil
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfilePage(user: state.user),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 16, color: Colors.white70),
                  label: const Text('Editar Perfil', style: TextStyle(color: Colors.white70)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Info Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Email:', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      Text(state.user.email, style: const TextStyle(color: Colors.white, fontSize: 16)),
                      const Divider(color: Colors.white24, height: 24),
                      const Text('Contraseña:', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('********', style: TextStyle(color: Colors.white, fontSize: 16)),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => EditProfilePage(user: state.user)),
                              );
                            },
                            child: const Text('Editar', style: TextStyle(color: Colors.greenAccent)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),
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
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
          return const Center(child: Text('Cargando perfil...', style: TextStyle(color: Colors.white)));
        },
      ),
    );
  }
}
