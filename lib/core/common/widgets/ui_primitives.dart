import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

/// .seg-control / .seg-item — pill segmented control
class SegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final AppColors colors;

  const SegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: active ? colors.card : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: active ? [const BoxShadow(color: Colors.black26, blurRadius: 4)] : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: GoogleFonts.vazirmatn(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? colors.fg : colors.mutedFg,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// .chrome-surface — metallic gradient card surface
class ChromeSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final bool isDark;

  const ChromeSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colors = isDark
        ? const [Color(0xFF181826), Color(0xFF1F1F30), Color(0xFF16161F)]
        : const [Color(0xFFF8F8FF), Color(0xFFFFFFFF), Color(0xFFF4F4F8)];
    final borderColor = isDark ? const Color(0x1FC8CDDC) : const Color(0x1F282840);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors, stops: const [0, 0.4, 1]),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

/// .frosted — blurred translucent nav bar
class FrostedBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  final AppColors colors;
  final EdgeInsets padding;

  const FrostedBar({super.key, required this.child, required this.colors, this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 12)});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: padding.add(EdgeInsets.only(top: MediaQuery.of(context).padding.top)),
          decoration: BoxDecoration(
            color: colors.bg.withOpacity(0.72),
            border: Border(bottom: BorderSide(color: colors.fg.withOpacity(0.06))),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

/// iOS-style toggle switch matching Toggle in SettingsScreen.tsx
class AppToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final AppColors colors;
  const AppToggle({super.key, required this.value, required this.onChanged, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? colors.buy : colors.border,
          borderRadius: BorderRadius.circular(14),
          boxShadow: value ? [BoxShadow(color: colors.buy.withOpacity(0.4), blurRadius: 12)] : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
          ),
        ),
      ),
    );
  }
}

/// .btn-buy / .btn-sell / .btn-chrome gradient buttons
class GradientActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final _ButtonKind kind;
  final bool loading;

  const GradientActionButton.buy({super.key, required this.label, this.onTap, this.loading = false}) : kind = _ButtonKind.buy;
  const GradientActionButton.sell({super.key, required this.label, this.onTap, this.loading = false}) : kind = _ButtonKind.sell;

  @override
  Widget build(BuildContext context) {
    final isBuy = kind == _ButtonKind.buy;
    final gradient = isBuy
        ? const LinearGradient(colors: [Color(0xFF0099DD), Color(0xFF0066AA)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
        : const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFB45309)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    final glow = isBuy ? const Color(0xFF00CCFF) : const Color(0xFFF5A623);

    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: glow.withOpacity(0.35), blurRadius: 24)],
          border: Border.all(color: glow.withOpacity(0.4)),
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(
                label,
                style: GoogleFonts.barlowCondensed(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.6),
              ),
      ),
    );
  }
}

enum _ButtonKind { buy, sell }

class ChromeButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AppColors colors;
  const ChromeButton({super.key, required this.label, required this.colors, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF242436), Color(0xFF181826)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.chrome.withOpacity(0.18)),
        ),
        alignment: Alignment.center,
        child: Text(label, style: GoogleFonts.jetBrainsMono(color: colors.chrome, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    );
  }
}

/// Themed text input matching .input-field
class AppTextField extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final AppColors colors;
  final TextDirection direction;

  const AppTextField({
    super.key,
    this.label,
    this.placeholder,
    required this.controller,
    required this.colors,
    this.obscure = false,
    this.keyboardType,
    this.direction = TextDirection.ltr,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!.toUpperCase(),
              style: GoogleFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w600, color: colors.mutedFg, letterSpacing: 1)),
          const SizedBox(height: 6),
        ],
        Directionality(
          textDirection: direction,
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: GoogleFonts.vazirmatn(color: colors.fg, fontSize: 14),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: GoogleFonts.vazirmatn(color: colors.mutedFg),
              filled: true,
              fillColor: colors.muted,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.buy.withOpacity(0.5), width: 1.5)),
            ),
          ),
        ),
      ],
    );
  }
}
