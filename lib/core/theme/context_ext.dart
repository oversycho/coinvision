import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/theme_cubit.dart';
import '../../cubits/locale_cubit.dart';
import 'app_colors.dart';

extension AppContextX on BuildContext {
  AppColors get colors => watch<ThemeCubit>().colors;
  AppLang get lang => watch<LocaleCubit>().state;
  bool get isRtl => watch<LocaleCubit>().isRtl;
}
