import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/presentation/pages/home.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../../../create/presentation/pages/create_page.dart';
import '../../../library/presentation/pages/library_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../cubit/main_navigation_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../../features/player/presentation/widgets/mini_player.dart';
import '../../../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../../../features/favorites/presentation/bloc/favorites_event.dart';
import '../../../../core/widgets/offline_banner.dart';

class MainPage extends StatefulWidget {
    const MainPage({super.key});

    @override
    State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
    final List<Widget> _pages = const [
        HomePage(),
        SearchPage(),
        LibraryPage(),
        CreatePage(),
        ProfilePage(),
    ];

    @override
    void initState() {
        super.initState();
        // Dispara carga de perfil Y favoritos ya que aquí el usuario ya está autenticado
        context.read<ProfileBloc>().add(LoadProfileEvent());
        context.read<FavoritesBloc>().add(LoadFavoritesEvent());
    }

    @override
    Widget build(BuildContext context) {
        return BlocBuilder<MainNavigationCubit, MainNavigationState>(
        builder: (context, state) {
            return OfflineBanner(
              child: Scaffold(
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: IndexedStack(
                    key: ValueKey<int>(state.tabIndex),
                    index: state.tabIndex,
                    children: _pages,
                ),
              ),
              bottomNavigationBar: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MiniPlayer(),
                  Container(
                      decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                          Colors.black,
                          Colors.black.withValues(alpha: 0.3),
                          ],
                      ),
                      ),
                      child: BottomNavigationBar(
                      currentIndex: state.tabIndex,
                      onTap: (index) {
                          context.read<MainNavigationCubit>().changeTab(index);
                      },
                      backgroundColor: Colors.transparent,
                      type: BottomNavigationBarType.fixed,
                      elevation: 0,
                      selectedItemColor: AppColors.primary,
                      unselectedItemColor: Colors.grey,
                      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                      items: const [
                          BottomNavigationBarItem(
                          icon: Icon(Icons.home_outlined),
                          activeIcon: Icon(Icons.home),
                          label: 'Inicio',
                          ),
                          BottomNavigationBarItem(
                          icon: Icon(Icons.search),
                          activeIcon: Icon(Icons.search, size: 28),
                          label: 'Buscar',
                          ),
                          BottomNavigationBarItem(
                          icon: Icon(Icons.library_music_outlined),
                          activeIcon: Icon(Icons.library_music),
                          label: 'Biblioteca',
                          ),
                          BottomNavigationBarItem(
                          icon: Icon(Icons.add_box_outlined),
                          activeIcon: Icon(Icons.add_box),
                          label: 'Crear',
                          ),
                          BottomNavigationBarItem(
                          icon: Icon(Icons.person_outline),
                          activeIcon: Icon(Icons.person),
                          label: 'Usuario',
                          ),
                      ],
                      ),
                  ),
                ],
              ),
              ),
            );
        },
        );
    }
}
