part of 'main_navigation_cubit.dart';

abstract class MainNavigationState {
  final int tabIndex;
  const MainNavigationState(this.tabIndex);
}

class MainNavigationInitial extends MainNavigationState {
  const MainNavigationInitial(super.tabIndex);
}

class MainNavigationTabChanged extends MainNavigationState {
  const MainNavigationTabChanged(super.tabIndex);
}
