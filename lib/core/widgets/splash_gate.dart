import 'dart:math' as math;

import 'package:flutter/material.dart' hide Text;
import '../tr_text.dart';

/// Deep bahi-khata red. Must match android/app/src/main/res/values/colors.xml (splash_bg)
/// so the native first screen and this splash look like one continuous screen.
const kSplashBg = Color(0xFF5A0F12);

const _gold = Color(0xFFF3D06E);
const _cream = Color(0xFFF7EFD8);
const _splashMs = 2400;

/// Shows an animated (pure Flutter, no video) splash while [ready] completes,
/// then cross-fades into [child]. The first frame is drawn immediately, so
/// there is no black screen while Supabase / the database start up.
class SplashGate extends StatefulWidget {
  const SplashGate({super.key, required this.ready, required this.child});

  final Future<void> ready;
  final Widget child;

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: _splashMs))..forward();
  bool _done = false;

  @override
  void initState() {
    super.initState();
    // Whatever happens during start-up, never get stuck on the splash.
    Future.wait<void>([
      widget.ready.catchError((Object _) {}),
      Future<void>.delayed(const Duration(milliseconds: _splashMs)),
    ]).timeout(const Duration(seconds: 8), onTimeout: () => const []).whenComplete(() {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOut,
      child: _done
          ? KeyedSubtree(key: const ValueKey('app'), child: widget.child)
          : _SplashView(key: const ValueKey('splash'), animation: _c),
    );
  }
}

/// Opens a red cloth bahi-khata, shows a rupee on the page, then
/// "शुभ लाभ / શુભ લાભ" and the app name.
class _SplashView extends StatelessWidget {
  const _SplashView({super.key, required this.animation});
  final Animation<double> animation;

  static double _seg(double t, double from, double to, [Curve curve = Curves.easeOutCubic]) =>
      curve.transform(((t - from) / (to - from)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Belling',
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.35),
            radius: 1.0,
            colors: [Color(0xFF8C1D1D), kSplashBg],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final t = animation.value;
              final appear = _seg(t, 0.0, 0.15);
              final open = _seg(t, 0.22, 0.55, Curves.easeInOutCubic);
              final rupee = _seg(t, 0.5, 0.68, Curves.elasticOut);
              final shubh = _seg(t, 0.55, 0.75);
              final gujarati = _seg(t, 0.63, 0.82);
              final name = _seg(t, 0.72, 0.9);
              final tag = _seg(t, 0.82, 1.0);

              Widget rise(double v, Widget child) => Opacity(
                    opacity: v,
                    child: Transform.translate(offset: Offset(0, (1 - v) * 14), child: child),
                  );

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: appear,
                    child: Transform.scale(
                      scale: 0.9 + 0.1 * appear,
                      child: _Ledger(open: open, rupee: rupee),
                    ),
                  ),
                  const SizedBox(height: 26),
                  rise(
                    shubh,
                    const Text(
                      'शुभ लाभ',
                      style: TextStyle(
                        fontFamily: 'Noto Sans Devanagari',
                        color: _gold,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  rise(
                    gujarati,
                    const Text(
                      'શુભ લાભ',
                      style: TextStyle(
                        fontFamily: 'Noto Sans Gujarati',
                        color: _gold,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  rise(
                    name,
                    const Text(
                      'Belling',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  rise(
                    tag,
                    const Text(
                      'आपका हिसाब, आपकी दुकान',
                      style: TextStyle(
                        fontFamily: 'Noto Sans Devanagari',
                        color: Color(0xFFECC7C0),
                        fontSize: 14,
                        decoration: TextDecoration.none,
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

/// The ledger: cream pages with a rupee, and a red cover that swings open.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.open, required this.rupee});
  final double open; // 0 closed .. 1 open
  final double rupee;

  @override
  Widget build(BuildContext context) {
    final angle = -open * math.pi * 0.86;
    // After the cover has swung past the viewer it would show its back; fade it out.
    final coverOpacity = (1 - ((open - 0.55) / 0.35)).clamp(0.0, 1.0);

    return SizedBox(
      width: 150,
      height: 190,
      child: Stack(
        children: [
          // Pages
          Positioned.fill(
            left: 6,
            top: 4,
            right: 2,
            bottom: 4,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: _cream,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(2), right: Radius.circular(8)),
                boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 10))],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: rupee,
                      child: const Text(
                        '₹',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFFA31F23),
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    for (var i = 0; i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(width: 80, height: 2, color: const Color(0xB3C9B27A)),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Cover
          Positioned.fill(
            child: Opacity(
              opacity: coverOpacity,
              child: Transform(
                alignment: Alignment.centerLeft,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0014)
                  ..rotateY(angle),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(6), right: Radius.circular(12)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFB32626), Color(0xFF8A1A1C), Color(0xFF7A1518)],
                    ),
                    boxShadow: [BoxShadow(color: Color(0x73000000), blurRadius: 24, offset: Offset(0, 14))],
                  ),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 10, 10, 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE8C25C), width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'श्री',
                      style: TextStyle(
                        fontFamily: 'Noto Sans Devanagari',
                        color: _gold,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
