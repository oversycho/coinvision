import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/common/widgets/gothic_logo.dart';
import '../core/theme/app_text_styles.dart';
import '../cubits/navigation_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _logoOpacity = CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.easeOut));
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showText = true);
    });
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) context.read<NavigationCubit>().navigate(AppScreen.auth);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF04040A),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // radial glow
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(colors: [Color(0x2E006080), Colors.transparent], radius: 0.7),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(scale: _logoScale.value, child: child),
                ),
                child: const GothicLogo(size: 120, glowing: true),
              ),
              const SizedBox(height: 32),
              AnimatedOpacity(
                opacity: _showText ? 1 : 0,
                duration: const Duration(milliseconds: 600),
                child: AnimatedSlide(
                  offset: _showText ? Offset.zero : const Offset(0, 0.05),
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      AppFonts.chromeText('COINVISION', size: 44, letterSpacing: 0.2),
                      const SizedBox(height: 8),
                      Text('کوین ویژن',
                          style: AppFonts.body(color: const Color(0xFF70718A), size: 22, weight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Text('PAPER TRADING EXCHANGE',
                          style: AppFonts.display(color: const Color(0xFF70718A), size: 11, letterSpacing: 0.3)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 64,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                  3,
                  (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _PulseDot(delay: i * 200),
                      )),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final int delay;
  const _PulseDot({required this.delay});
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_c),
      child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF00CCFF), shape: BoxShape.circle)),
    );
  }
}
