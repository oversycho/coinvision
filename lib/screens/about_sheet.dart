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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        children: [
          const GothicLogo(size: 72),
          const SizedBox(height: 12),
          AppFonts.chromeText('COINVISION', size: 26, letterSpacing: 0.15),
          const SizedBox(height: 4),
          Text(
            isRtl ? 'نسخه ۱.۰.۰ (دمو)' : 'Version 1.0.0 (Demo)',
            style: TextStyle(color: colors.mutedFg, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Text(
            isRtl
                ? 'کوین ویژن یک صرافی شبیه‌سازی‌شده‌ی ارز دیجیتال است. قیمت‌های نمایش‌داده‌شده واقعی و لحظه‌ای هستند، اما خرید و فروش‌ها به‌صورت کاملاً آزمایشی و بدون هیچ تراکنش مالی واقعی انجام می‌شود — فضایی امن برای یادگیری و تمرین ترید، بدون ریسک از دست دادن سرمایه‌ی واقعی.'
                : 'CoinVision is a simulated cryptocurrency exchange. Prices shown are real and live, but every buy and sell is entirely paper trading with no real money involved — a safe space to learn and practice trading without any real financial risk.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.fg, fontSize: 13, height: 1.7),
          ),
          const SizedBox(height: 28),
          Text(
            (isRtl ? 'ما را دنبال کنید' : 'Follow us').toUpperCase(),
            style: AppFonts.display(
                color: colors.mutedFg, size: 11, letterSpacing: 0.2),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialButton(
                icon: FontAwesomeIcons.telegram,
                color: const Color(0xFF29A9EB),
                url: _telegramUrl,
                colors: colors,
              ),
              const SizedBox(width: 16),
              _SocialButton(
                icon: FontAwesomeIcons.instagram,
                color: const Color(0xFFE1306C),
                url: _instagramUrl,
                colors: colors,
              ),
              const SizedBox(width: 16),
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
    );
  }
}

class _SocialButton extends StatelessWidget {
  final FaIconData icon;
  final Color color;
  final String url;
  final dynamic colors;
  const _SocialButton(
      {required this.icon,
      required this.color,
      required this.url,
      required this.colors});

  Future<void> _open() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _open,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.muted,
          border: Border.all(color: colors.border),
        ),
        alignment: Alignment.center,
        child: FaIcon(icon, size: 22, color: color),
      ),
    );
  }
}
