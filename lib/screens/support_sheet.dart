import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_text_styles.dart';
import '../cubits/locale_cubit.dart';

/// TODO: replace with your real support channels.
const _supportTelegramUrl = 'https://t.me/coinvision_support';
const _supportEmail = 'support@coinvision.ir';

class SupportSheet extends StatelessWidget {
  final dynamic colors;
  final AppLang lang;
  final bool isRtl;
  const SupportSheet(
      {super.key,
      required this.colors,
      required this.lang,
      required this.isRtl});

  List<(String, String)> get _faqs => isRtl
      ? const [
          (
            'آیا پول واقعی درگیر اپ می‌شود؟',
            'نه. کوین ویژن یک صرافی کاملاً شبیه‌سازی‌شده است. قیمت‌ها واقعی و لحظه‌ای هستند، اما خرید/فروش و موجودی‌ها صرفاً برای تمرین‌اند و هیچ تراکنش مالی واقعی رخ نمی‌دهد.',
          ),
          (
            'واریز چطور کار می‌کند؟',
            'بعد از انتخاب ارز و شبکه، یک آدرس شبیه‌سازی‌شده دریافت می‌کنید. واریز به‌صورت خودکار مراحل «در انتظار → در حال تأیید → تکمیل‌شده» را طی می‌کند تا فرآیند واقعی بلاکچین را تمرین کنید.',
          ),
          (
            'احراز هویت (KYC) چه زمانی تأیید می‌شود؟',
            'درخواست شما پس از ارسال، به‌صورت خودکار و طی چند ثانیه برای اهداف آزمایشی تأیید می‌شود.',
          ),
          (
            'چطور احراز هویت دو مرحله‌ای را فعال کنم؟',
            'از تنظیمات → حساب کاربری → احراز هویت دو مرحله‌ای، کد QR را با اپ Authenticator اسکن کرده و کد ۶ رقمی را وارد کنید.',
          ),
          (
            'رمز عبورم را فراموش کرده‌ام، چه کنم؟',
            'در صفحه ورود روی «فراموشی رمز» بزنید تا لینک بازیابی به ایمیل شما ارسال شود.',
          ),
        ]
      : const [
          (
            'Is real money involved?',
            'No. CoinVision is a fully simulated exchange. Prices are real and live, but every trade and balance is for practice only — no real financial transactions occur.',
          ),
          (
            'How does deposit work?',
            'After picking a coin and network you get a simulated address. The deposit automatically moves through pending → confirming → completed so you can practice the real blockchain flow.',
          ),
          (
            'When does identity verification (KYC) get approved?',
            'Your submission is automatically approved within seconds, for demo purposes.',
          ),
          (
            'How do I enable two-factor authentication?',
            'Go to Settings → Account → Two-Factor Auth, scan the QR code with an authenticator app, then enter the 6-digit code.',
          ),
          (
            'I forgot my password, what do I do?',
            'On the login screen, tap "Forgot Password" to receive a reset link by email.',
          ),
        ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.92,
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
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colors.border ?? Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colors.muted?.withOpacity(0.9) ??
                            Colors.grey.withOpacity(0.15),
                        Colors.transparent
                      ],
                    ),
                  ),
                  child: Icon(Icons.support_agent_rounded,
                      size: 36, color: colors.buy),
                ),
                const SizedBox(height: 16),
                Text(
                  isRtl ? 'پشتیبانی' : 'Support',
                  style: AppFonts.display(
                      color: colors.fg, size: 20, weight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  isRtl
                      ? 'سوالات پرتکرار و راه‌های تماس'
                      : 'Frequently asked questions and contact options',
                  style: TextStyle(color: colors.mutedFg, fontSize: 12),
                ),
                const SizedBox(height: 24),
                ..._faqs.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _FaqItem(
                          question: f.$1,
                          answer: f.$2,
                          colors: colors,
                          isRtl: isRtl),
                    )),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Divider(
                            color: (colors.border ?? Colors.grey)
                                .withOpacity(0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        (isRtl ? 'تماس مستقیم' : 'Contact us').toUpperCase(),
                        style: AppFonts.display(
                            color: colors.mutedFg,
                            size: 11,
                            letterSpacing: 0.2),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                            color: (colors.border ?? Colors.grey)
                                .withOpacity(0.3))),
                  ],
                ),
                const SizedBox(height: 16),
                _ContactRow(
                  icon: FontAwesomeIcons.telegram,
                  color: const Color(0xFF29A9EB),
                  label: isRtl ? 'گفتگو در تلگرام' : 'Chat on Telegram',
                  onTap: () => _open(_supportTelegramUrl),
                  colors: colors,
                ),
                const SizedBox(height: 10),
                _ContactRow(
                  icon: FontAwesomeIcons.envelope,
                  color: colors.buy,
                  label: _supportEmail,
                  onTap: () => _open('mailto:$_supportEmail'),
                  colors: colors,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _open(String urlOrMailto) async {
    final uri = Uri.parse(urlOrMailto);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // canLaunchUrl-style pre-check skipped intentionally: on Android,
      // mailto: links can false-negative without a <queries> manifest entry
      // even when a mail app is installed. launchUrl itself is the reliable check.
    }
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  final dynamic colors;
  final bool isRtl;
  const _FaqItem(
      {required this.question,
      required this.answer,
      required this.colors,
      required this.isRtl});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.muted?.withOpacity(0.4) ?? Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: (colors.border ?? Colors.grey).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => open = !open),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      textAlign:
                          widget.isRtl ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                          color: colors.fg,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: colors.mutedFg, size: 20),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(
                widget.answer,
                textAlign: widget.isRtl ? TextAlign.right : TextAlign.left,
                style: TextStyle(
                    color: colors.mutedFg, fontSize: 12.5, height: 1.7),
              ),
            ),
            crossFadeState:
                open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatefulWidget {
  final FaIconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final dynamic colors;
  const _ContactRow(
      {required this.icon,
      required this.color,
      required this.label,
      required this.onTap,
      required this.colors});

  @override
  State<_ContactRow> createState() => _ContactRowState();
}

class _ContactRowState extends State<_ContactRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colors.muted ?? Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: (colors.border ?? Colors.grey).withOpacity(0.25)),
          ),
          child: Row(
            children: [
              FaIcon(widget.icon, size: 18, color: widget.color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(widget.label,
                    style: TextStyle(
                        color: colors.fg,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: colors.mutedFg, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
