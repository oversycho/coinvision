import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/common/widgets/gothic_logo.dart';
import '../core/common/widgets/ui_primitives.dart';
import '../core/localization/translations.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/context_ext.dart';
import '../cubits/locale_cubit.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/bloc/auth_state.dart';

enum _Tab { login, signup, forgot }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  _Tab tab = _Tab.login;
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final confirmPw = TextEditingController();

  void _submit() {
    if (email.text.isEmpty) return;
    if (tab != _Tab.forgot && password.text.isEmpty) return;
    if (tab == _Tab.signup && password.text != confirmPw.text) return;

    final bloc = context.read<AuthBloc>();
    if (tab == _Tab.forgot) {
      bloc.add(AuthResetPasswordRequested(email.text));
    } else if (tab == _Tab.login) {
      bloc.add(AuthSignInRequested(email: email.text, password: password.text));
    } else {
      bloc.add(AuthSignUpRequested(email: email.text, password: password.text, fullName: name.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lang = context.lang;
    final isRtl = context.isRtl;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        color: colors.bg,
        child: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: colors.loss));
              }
            },
            builder: (context, authState) {
              final loading = authState is AuthLoading;
              final success = authState is AuthPasswordResetSent ? (isRtl ? 'لینک بازیابی ارسال شد' : 'Reset link sent to your email') : '';

              return Column(
                children: [
                  const SizedBox(height: 24),
                  const GothicLogo(size: 72),
                  const SizedBox(height: 12),
                  AppFonts.chromeText('COINVISION', size: 30, letterSpacing: 0.15),
                  const SizedBox(height: 28),
                  if (tab != _Tab.forgot)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SegmentedControl(
                        labels: [Tr.t('login', lang), Tr.t('signup', lang)],
                        selectedIndex: tab == _Tab.signup ? 1 : 0,
                        colors: colors,
                        onChanged: (i) => setState(() => tab = i == 0 ? _Tab.login : _Tab.signup),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: tab == _Tab.forgot
                          ? _ForgotForm(
                              email: email,
                              loading: loading,
                              success: success,
                              colors: colors,
                              lang: lang,
                              isRtl: isRtl,
                              onSubmit: _submit,
                              onBack: () => setState(() => tab = _Tab.login),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (tab == _Tab.signup) ...[
                                  AppTextField(label: Tr.t('fullName', lang), placeholder: Tr.t('fullName', lang), controller: name, colors: colors, direction: isRtl ? TextDirection.rtl : TextDirection.ltr),
                                  const SizedBox(height: 16),
                                ],
                                AppTextField(label: Tr.t('email', lang), placeholder: 'you@example.com', controller: email, colors: colors, keyboardType: TextInputType.emailAddress),
                                const SizedBox(height: 16),
                                AppTextField(label: Tr.t('password', lang), placeholder: '••••••••', controller: password, colors: colors, obscure: true),
                                if (tab == _Tab.signup) ...[
                                  const SizedBox(height: 16),
                                  AppTextField(label: Tr.t('confirmPw', lang), placeholder: '••••••••', controller: confirmPw, colors: colors, obscure: true),
                                ],
                                if (tab == _Tab.login) ...[
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => setState(() => tab = _Tab.forgot),
                                      child: Text(Tr.t('forgotPw', lang), style: TextStyle(color: colors.buy, fontWeight: FontWeight.w600, fontSize: 12)),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                GradientActionButton.buy(
                                  label: loading
                                      ? (isRtl ? 'در حال ورود...' : 'Signing in…')
                                      : (tab == _Tab.login ? Tr.t('signInBtn', lang) : Tr.t('signUpBtn', lang)),
                                  loading: loading,
                                  onTap: _submit,
                                ),
                                const SizedBox(height: 20),
                                Text(Tr.t('demoNote', lang), textAlign: TextAlign.center, style: TextStyle(color: colors.mutedFg, fontSize: 11)),
                              ],
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ForgotForm extends StatelessWidget {
  final TextEditingController email;
  final bool loading;
  final String success;
  final dynamic colors;
  final AppLang lang;
  final bool isRtl;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const _ForgotForm({
    required this.email,
    required this.loading,
    required this.success,
    required this.colors,
    required this.lang,
    required this.isRtl,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton.icon(
          onPressed: onBack,
          icon: Icon(isRtl ? Icons.arrow_forward : Icons.arrow_back, size: 16, color: colors.buy),
          label: Text(isRtl ? 'بازگشت' : 'Back', style: TextStyle(color: colors.buy, fontSize: 13)),
        ),
        const SizedBox(height: 8),
        Text(Tr.t('forgotPw', lang), style: AppFonts.display(color: colors.fg, size: 24, weight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(
          isRtl ? 'ایمیل خود را وارد کنید تا لینک بازیابی ارسال شود.' : 'Enter your email to receive a reset link.',
          style: TextStyle(color: colors.mutedFg, fontSize: 13),
        ),
        const SizedBox(height: 20),
        if (success.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: colors.gain.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Text(success, textAlign: TextAlign.center, style: TextStyle(color: colors.gain, fontWeight: FontWeight.w600)),
          )
        else ...[
          AppTextField(placeholder: 'you@example.com', controller: email, colors: colors),
          const SizedBox(height: 16),
          GradientActionButton.buy(label: Tr.t('sendReset', lang), loading: loading, onTap: onSubmit),
        ],
      ],
    );
  }
}
