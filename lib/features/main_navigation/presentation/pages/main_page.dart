import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/presentation/pages/home.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../../../create/presentation/pages/create_page.dart';
import '../../../library/presentation/pages/library_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../cubit/main_navigation_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/player/presentation/widgets/mini_player.dart';
import '../../../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../../../features/favorites/presentation/bloc/favorites_event.dart';


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
        // Cargar favoritos globalmente al iniciar la navegación principal
        context.read<FavoritesBloc>().add(LoadFavoritesEvent());
        
        // Las cargas individuales se manejan en los initState de cada página 
        // para evitar disparar todo al mismo tiempo al entrar al MainPage.
    }

    @override
    Widget build(BuildContext context) {
        return BlocBuilder<MainNavigationCubit, MainNavigationState>(
        builder: (context, state) {
            return Scaffold(
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
              );
        },
        );
    }
}
