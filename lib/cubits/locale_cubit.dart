import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AppLang { en, fa }

class LocaleCubit extends Cubit<AppLang> {
  LocaleCubit() : super(AppLang.fa);

  void setEnglish() => emit(AppLang.en);
  void setPersian() => emit(AppLang.fa);
  void toggle() => emit(state == AppLang.fa ? AppLang.en : AppLang.fa);

  bool get isRtl => state == AppLang.fa;
  TextDirection get textDirection => isRtl ? TextDirection.rtl : TextDirection.ltr;
}
