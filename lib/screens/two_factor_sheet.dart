import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/common/widgets/ui_primitives.dart';
import '../core/localization/translations.dart';
import '../cubits/locale_cubit.dart';
import '../features/auth/domain/entities/mfa_entities.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/bloc/auth_state.dart';

enum _Step { loading, disabled, enrolling, verifying, enabled }

class TwoFactorSheet extends StatefulWidget {
  final dynamic colors;
  final AppLang lang;
  final bool isRtl;
  const TwoFactorSheet({super.key, required this.colors, required this.lang, required this.isRtl});

  @override
  State<TwoFactorSheet> createState() => _TwoFactorSheetState();
}

class _TwoFactorSheetState extends State<TwoFactorSheet> {
  _Step step = _Step.loading;
  MfaEnrollResult? enrollment;
  MfaFactorInfo? activeFactor;
  String? error;
  final codeCtrl = TextEditingController();
  StreamSubscription<AuthState>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = context.read<AuthBloc>().stream.listen(_onAuthState);
    context.read<AuthBloc>().add(AuthMfaListFactorsRequested());
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onAuthState(AuthState state) {
    if (!mounted) return;
    if (state is AuthMfaFactorsLoaded) {
      final verified = state.factors.where((f) => f.status == 'verified').toList();
      setState(() {
        activeFactor = verified.isNotEmpty ? verified.first : null;
        step = activeFactor != null ? _Step.enabled : _Step.disabled;
        error = null;
      });
    } else if (state is AuthMfaEnrolled) {
      setState(() {
        enrollment = state.result;
        step = _Step.verifying;
        error = null;
      });
    } else if (state is AuthMfaVerified) {
      context.read<AuthBloc>().add(AuthMfaListFactorsRequested());
    } else if (state is AuthMfaUnenrolled) {
      context.read<AuthBloc>().add(AuthMfaListFactorsRequested());
    } else if (state is AuthError) {
      setState(() => error = state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final isRtl = widget.isRtl;
    final lang = widget.lang;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final loading = state is AuthLoading;

          Widget content;
          switch (step) {
            case _Step.loading:
              content = const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator()));
              break;

            case _Step.disabled:
              content = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.shield_outlined, size: 40, color: colors.mutedFg),
                  const SizedBox(height: 12),
                  Text(
                    isRtl
                        ? 'با فعال کردن این گزینه، هنگام ورود علاوه بر رمز عبور، یک کد شش‌رقمی از اپ Authenticator هم لازم است.'
                        : 'When enabled, logging in will require a 6-digit code from an authenticator app in addition to your password.',
                    style: TextStyle(color: colors.mutedFg, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  GradientActionButton.buy(
                    label: isRtl ? 'شروع فعال‌سازی' : 'Enable 2FA',
                    loading: loading,
                    onTap: loading ? null : () => context.read<AuthBloc>().add(AuthMfaEnrollRequested()),
                  ),
                ],
              );
              break;

            case _Step.verifying:
              content = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isRtl ? 'کد QR را با اپ Authenticator اسکن کنید' : 'Scan this QR code with your authenticator app',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.fg, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  if (enrollment != null)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: SizedBox(width: 160, height: 160, child: _QrFromDataUri(dataUri: enrollment!.qrCodeSvg)),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    isRtl ? 'یا کد زیر را دستی وارد کنید:' : 'Or enter this code manually:',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.mutedFg, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    enrollment?.secret ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.chrome, fontSize: 12, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: isRtl ? 'کد شش‌رقمی' : '6-digit code',
                    placeholder: '••••••',
                    controller: codeCtrl,
                    colors: colors,
                    keyboardType: TextInputType.number,
                    direction: TextDirection.ltr,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(error!, style: TextStyle(color: colors.loss, fontSize: 12)),
                  ],
                  const SizedBox(height: 16),
                  GradientActionButton.buy(
                    label: isRtl ? 'تأیید و فعال‌سازی' : 'Verify & Enable',
                    loading: loading,
                    onTap: loading || enrollment == null
                        ? null
                        : () => context.read<AuthBloc>().add(
                              AuthMfaVerifyEnrollmentRequested(factorId: enrollment!.factorId, code: codeCtrl.text.trim()),
                            ),
                  ),
                ],
              );
              break;

            case _Step.enabled:
              content = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.verified_user_rounded, size: 40, color: colors.gain),
                  const SizedBox(height: 12),
                  Text(
                    isRtl ? 'احراز هویت دو مرحله‌ای فعال است' : 'Two-factor authentication is enabled',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  GradientActionButton.sell(
                    label: isRtl ? 'غیرفعال‌سازی' : 'Disable',
                    loading: loading,
                    onTap: loading || activeFactor == null
                        ? null
                        : () => context.read<AuthBloc>().add(AuthMfaUnenrollRequested(activeFactor!.id)),
                  ),
                ],
              );
              break;
          }

          return content;
        },
      ),
    );
  }
}

/// Supabase returns the TOTP QR code as an SVG data URI
/// (either utf8-encoded or base64-encoded). This decodes either form.
class _QrFromDataUri extends StatelessWidget {
  final String dataUri;
  const _QrFromDataUri({required this.dataUri});

  @override
  Widget build(BuildContext context) {
    try {
      final commaIndex = dataUri.indexOf(',');
      if (commaIndex == -1) return const SizedBox.shrink();
      final meta = dataUri.substring(0, commaIndex);
      final payload = dataUri.substring(commaIndex + 1);
      final String svgString;
      if (meta.contains(';base64')) {
        svgString = utf8.decode(base64.decode(payload));
      } else {
        svgString = Uri.decodeComponent(payload);
      }
      return SvgPicture.string(svgString, width: 140, height: 140);
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}
