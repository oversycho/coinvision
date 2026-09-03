import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/common/widgets/app_bottom_sheet.dart';
import '../core/common/widgets/ui_primitives.dart';
import '../core/localization/translations.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/context_ext.dart';
import '../cubits/locale_cubit.dart';
import '../cubits/theme_cubit.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import 'change_password_sheet.dart';
import 'kyc_sheet.dart';
import 'two_factor_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifTrades = true;
  bool notifPrices = true;
  bool notifNews = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lang = context.lang;
    final isRtl = context.isRtl;
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticated ? (authState.user.fullName ?? authState.user.email ?? '') : '';
    final userEmail = authState is AuthAuthenticated ? (authState.user.email ?? '') : '';
    final themeMode = context.watch<ThemeCubit>().state;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        color: colors.bg,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(Tr.t('settings', lang), style: AppFonts.display(color: colors.fg, size: 24, weight: FontWeight.w900)),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    // Account card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: colors.border)),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [colors.buy, colors.chrome]),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              userName.isNotEmpty ? userName.characters.first.toUpperCase() : '?',
                              style: AppFonts.display(color: Colors.white, size: 20, weight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userName.isNotEmpty ? userName : (isRtl ? 'کاربر مهمان' : 'Guest User'),
                                    style: AppFonts.display(color: colors.fg, size: 15, weight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(userEmail.isNotEmpty ? userEmail : 'guest@coinvision.ir', style: TextStyle(color: colors.mutedFg, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel(Tr.t('appearance', lang), colors),
                    _SettingsGroup(colors: colors, children: [
                      _ToggleRow(
                        icon: Icons.dark_mode_outlined,
                        label: Tr.t('darkMode', lang),
                        value: themeMode == AppThemeMode.dark,
                        onChanged: (_) => context.read<ThemeCubit>().toggle(),
                        colors: colors,
                      ),
                      _Divider(colors),
                      _NavRow(
                        icon: Icons.language,
                        label: Tr.t('language', lang),
                        trailingText: isRtl ? 'فارسی' : 'English',
                        colors: colors,
                        onTap: () => context.read<LocaleCubit>().toggle(),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _SectionLabel(Tr.t('account', lang), colors),
                    _SettingsGroup(colors: colors, children: [
                      _NavRow(
                        icon: Icons.verified_user_outlined,
                        label: Tr.t('kyc', lang),
                        colors: colors,
                        onTap: () => showAppBottomSheet(
                          context: context,
                          colors: colors,
                          title: Tr.t('kyc', lang),
                          child: KycSheet(colors: colors, lang: lang, isRtl: isRtl),
                        ),
                      ),
                      _Divider(colors),
                      _NavRow(
                        icon: Icons.lock_outline,
                        label: Tr.t('changePassword', lang),
                        colors: colors,
                        onTap: () => showAppBottomSheet(
                          context: context,
                          colors: colors,
                          title: Tr.t('changePassword', lang),
                          child: ChangePasswordSheet(colors: colors, lang: lang, isRtl: isRtl),
                        ),
                      ),
                      _Divider(colors),
                      _NavRow(
                        icon: Icons.security_outlined,
                        label: Tr.t('twoFactor', lang),
                        colors: colors,
                        onTap: () => showAppBottomSheet(
                          context: context,
                          colors: colors,
                          title: Tr.t('twoFactor', lang),
                          child: TwoFactorSheet(colors: colors, lang: lang, isRtl: isRtl),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _SectionLabel(Tr.t('notifications', lang), colors),
                    _SettingsGroup(colors: colors, children: [
                      _ToggleRow(icon: Icons.swap_horiz, label: Tr.t('notifTrades', lang), value: notifTrades, onChanged: (v) => setState(() => notifTrades = v), colors: colors),
                      _Divider(colors),
                      _ToggleRow(icon: Icons.show_chart, label: Tr.t('notifPrices', lang), value: notifPrices, onChanged: (v) => setState(() => notifPrices = v), colors: colors),
                      _Divider(colors),
                      _ToggleRow(icon: Icons.campaign_outlined, label: Tr.t('notifNews', lang), value: notifNews, onChanged: (v) => setState(() => notifNews = v), colors: colors),
                    ]),
                    const SizedBox(height: 20),
                    _SectionLabel(Tr.t('support', lang), colors),
                    _SettingsGroup(colors: colors, children: [
                      _NavRow(icon: Icons.info_outline, label: Tr.t('about', lang), colors: colors, onTap: () {}),
                      _Divider(colors),
                      _NavRow(icon: Icons.help_outline, label: Tr.t('support', lang), colors: colors, onTap: () {}),
                    ]),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => context.read<AuthBloc>().add(AuthSignOutRequested()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(color: colors.loss.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.loss.withOpacity(0.2))),
                        alignment: Alignment.center,
                        child: Text(Tr.t('logout', lang), style: AppFonts.display(color: colors.loss, size: 14, weight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(child: Text(Tr.t('version', lang), style: TextStyle(color: colors.mutedFg, fontSize: 11))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final dynamic colors;
  const _SectionLabel(this.text, this.colors);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4, left: 4),
        child: Text(text.toUpperCase(), style: AppFonts.display(color: colors.mutedFg, size: 11, weight: FontWeight.w700, letterSpacing: 0.15)),
      );
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  final dynamic colors;
  const _SettingsGroup({required this.children, required this.colors});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: colors.border)),
        child: Column(children: children),
      );
}

class _Divider extends StatelessWidget {
  final dynamic colors;
  const _Divider(this.colors);
  @override
  Widget build(BuildContext context) => Divider(height: 1, color: colors.border, indent: 50);
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final dynamic colors;
  const _ToggleRow({required this.icon, required this.label, required this.value, required this.onChanged, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 19, color: colors.chrome),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(color: colors.fg, fontSize: 13, fontWeight: FontWeight.w600))),
          AppToggle(value: value, onChanged: onChanged, colors: colors),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final VoidCallback onTap;
  final dynamic colors;
  const _NavRow({required this.icon, required this.label, this.trailingText, required this.onTap, required this.colors});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 19, color: colors.chrome),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(color: colors.fg, fontSize: 13, fontWeight: FontWeight.w600))),
            if (trailingText != null) Text(trailingText!, style: TextStyle(color: colors.mutedFg, fontSize: 12)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: colors.mutedFg),
          ],
        ),
      ),
    );
  }
}
