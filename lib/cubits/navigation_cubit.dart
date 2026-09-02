import 'package:flutter_bloc/flutter_bloc.dart';

enum AppScreen { splash, auth, home, coinDetail, portfolio, deposit, orderHistory, settings }

class NavState {
  final AppScreen screen;
  final AppScreen? prevScreen;
  final String? param;
  const NavState(this.screen, this.prevScreen, this.param);
}

class NavigationCubit extends Cubit<NavState> {
  NavigationCubit() : super(const NavState(AppScreen.splash, null, null));

  void navigate(AppScreen screen, {String? param}) {
    emit(NavState(screen, state.screen, param));
  }

  void goBack() {
    if (state.prevScreen != null) {
      emit(NavState(state.prevScreen!, null, null));
    }
  }
}
