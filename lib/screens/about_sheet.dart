import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/common/widgets/gothic_logo.dart';
import '../core/theme/app_text_styles.dart';
import '../cubits/locale_cubit.dart';

/// TODO: replace with your real social links.
const _telegramUrl = 'https://t.me/coinvision';
const _instagramUrl = 'https://instagram.com/coinvision';
const _youtubeUrl = 'https://youtube.com/@coinvision';

class AboutSheet extends StatelessWidget {
  final dynamic colors;
  final AppLang lang;
  final bool isRtl;
  const AboutSheet(
      {super.key,
      required this.colors,
      required this.lang,
      required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.bg ?? Colors.transparent,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colors.border ?? Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                // Logo with soft glow container
                Container(
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colors.muted?.withOpacity(0.9) ??
                            Colors.grey.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const GothicLogo(size: 64),
                ),
                const SizedBox(height: 16),

                AppFonts.chromeText('COINVISION',
                    size: 26, letterSpacing: 0.15),
                const SizedBox(height: 6),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.muted ?? Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isRtl ? 'نسخه ۱.۰.۰ (دمو)' : 'Version 1.0.0 (Demo)',
                    style: TextStyle(
                      color: colors.mutedFg,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Description card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.muted?.withOpacity(0.4) ??
                        Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: (colors.border ?? Colors.grey).withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    isRtl
                        ? 'کوین ویژن یک صرافی شبیه‌سازی‌شده‌ی ارز دیجیتال است. قیمت‌های نمایش‌داده‌شده واقعی و لحظه‌ای هستند، اما خرید و فروش‌ها به‌صورت کاملاً آزمایشی و بدون هیچ تراکنش مالی واقعی انجام می‌شود — فضایی امن برای یادگیری و تمرین ترید، بدون ریسک از دست دادن سرمایه‌ی واقعی.'
                        : 'CoinVision is a simulated cryptocurrency exchange. Prices shown are real and live, but every buy and sell is entirely paper trading with no real money involved — a safe space to learn and practice trading without any real financial risk.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.fg,
                      fontSize: 13.5,
                      height: 1.8,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                          color:
                              (colors.border ?? Colors.grey).withOpacity(0.3)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        (isRtl ? 'ما را دنبال کنید' : 'Follow us')
                            .toUpperCase(),
                        style: AppFonts.display(
                          color: colors.mutedFg,
                          size: 11,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                          color:
                              (colors.border ?? Colors.grey).withOpacity(0.3)),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialButton(
                      icon: FontAwesomeIcons.telegram,
                      color: const Color(0xFF29A9EB),
                      url: _telegramUrl,
                      colors: colors,
                    ),
                    const SizedBox(width: 18),
                    _SocialButton(
                      icon: FontAwesomeIcons.instagram,
                      color: const Color(0xFFE1306C),
                      url: _instagramUrl,
                      colors: colors,
                    ),
                    const SizedBox(width: 18),
                    _SocialButton(
                      icon: FontAwesomeIcons.youtube,
                      color: const Color(0xFFFF0000),
                      url: _youtubeUrl,
                      colors: colors,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SocialButton extends StatefulWidget {
  final FaIconData icon;
  final Color color;
  final String url;
  final dynamic colors;
  const _SocialButton(
      {required this.icon,
      required this.color,
      required this.url,
      required this.colors});

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _pressed = false;

  Future<void> _open() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: _open,
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.colors.muted ?? Colors.grey.withOpacity(0.1),
            border: Border.all(
              color: (widget.colors.border ?? Colors.grey).withOpacity(0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.18),
                blurRadius: 14,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: FaIcon(widget.icon, size: 22, color: widget.color),
        ),
      ),
    );
  }
}
