import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/common/widgets/ui_primitives.dart';
import '../core/localization/translations.dart';
import '../cubits/locale_cubit.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/bloc/auth_state.dart';

class ChangePasswordSheet extends StatefulWidget {
  final dynamic colors;
  final AppLang lang;
  final bool isRtl;
  const ChangePasswordSheet({super.key, required this.colors, required this.lang, required this.isRtl});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final newPw = TextEditingController();
  final confirmPw = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final isRtl = widget.isRtl;
    final lang = widget.lang;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthPasswordChanged) {
            Navigator.of(context).maybePop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(isRtl ? 'رمز عبور با موفقیت تغییر کرد' : 'Password changed successfully')),
            );
          } else if (state is AuthError) {
            setState(() => error = state.message);
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(label: Tr.t('password', lang), placeholder: '••••••••', controller: newPw, colors: colors, obscure: true),
              const SizedBox(height: 16),
              AppTextField(label: Tr.t('confirmPw', lang), placeholder: '••••••••', controller: confirmPw, colors: colors, obscure: true),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, style: TextStyle(color: colors.loss, fontSize: 12)),
              ],
              const SizedBox(height: 20),
              GradientActionButton.buy(
                label: Tr.t('changePassword', lang),
                loading: loading,
                onTap: loading
                    ? null
                    : () {
                        if (newPw.text.length < 6) {
                          setState(() => error = isRtl ? 'رمز باید حداقل ۶ کاراکتر باشد' : 'Password must be at least 6 characters');
                          return;
                        }
                        if (newPw.text != confirmPw.text) {
                          setState(() => error = isRtl ? 'رمزها یکسان نیستند' : 'Passwords do not match');
                          return;
                        }
                        setState(() => error = null);
                        context.read<AuthBloc>().add(AuthChangePasswordRequested(newPw.text));
                      },
              ),
            ],
          );
        },
      ),
    );
  }
}
