import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/presentation/pages/home.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../../../create/presentation/pages/create_page.dart';
import '../../../library/presentation/pages/library_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../cubit/main_navigation_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';

class MainPage extends StatefulWidget {
    const MainPage({super.key});

    @override
    State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
    final List<Widget> _pages = const [
        ProfilePage(),
        HomePage(),
        SearchPage(),
        LibraryPage(),
        CreatePage(),
    ];

    @override
    void initState() {
        super.initState();
        // Disparamos la carga del perfil aquí, una vez que el usuario ya ha aterrizado
        // en una pantalla que requiere estar autenticado.
        context.read<ProfileBloc>().add(LoadProfileEvent());
    }

    @override
    Widget build(BuildContext context) {
        return BlocBuilder<MainNavigationCubit, MainNavigationState>(
        builder: (context, state) {
            return Scaffold(
            body: IndexedStack(
                index: state.tabIndex,
                children: _pages,
            ),
            bottomNavigationBar: Container(
                decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                    Colors.black,
                    Colors.black.withOpacity(0.8),
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
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Usuario',
                    ),
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
                ],
                ),
            ),
            );
        },
        );
    }
}
