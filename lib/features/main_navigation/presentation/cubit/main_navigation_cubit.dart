import 'package:flutter_bloc/flutter_bloc.dart';

part 'main_navigation_state.dart';

class MainNavigationCubit extends Cubit<MainNavigationState> {
  MainNavigationCubit() : super(const MainNavigationInitial(0));

  void changeTab(int index) {
    emit(MainNavigationTabChanged(index));
  }
}
