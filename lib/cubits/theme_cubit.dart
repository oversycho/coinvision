import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_colors.dart';

enum AppThemeMode { dark, light }

class ThemeCubit extends Cubit<AppThemeMode> {
  ThemeCubit() : super(AppThemeMode.dark);

  void toggle() => emit(state == AppThemeMode.dark ? AppThemeMode.light : AppThemeMode.dark);
  void setDark() => emit(AppThemeMode.dark);
  void setLight() => emit(AppThemeMode.light);

  AppColors get colors => state == AppThemeMode.dark ? AppColors.dark : AppColors.light;
}
