import 'dart:math' as math;

import 'package:flutter/material.dart';

const kSplashBg = Color(0xFF0B1B3F);

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
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();
  bool _done = false;

  @override
  void initState() {
    super.initState();
    // Whatever happens during start-up, never get stuck on the splash.
    Future.wait<void>([
      widget.ready.catchError((Object _) {}),
      Future<void>.delayed(const Duration(milliseconds: 1500)),
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

class _SplashView extends StatelessWidget {
  const _SplashView({super.key, required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: kSplashBg,
      child: Center(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final t = animation.value;
            final logo = Curves.elasticOut.transform((t / 0.55).clamp(0.0, 1.0));
            final text = Curves.easeOutCubic.transform(((t - 0.35) / 0.4).clamp(0.0, 1.0));
            final tag = Curves.easeOutCubic.transform(((t - 0.55) / 0.35).clamp(0.0, 1.0));
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 132,
                  height: 132,
                  child: CustomPaint(
                    painter: _RingPainter(progress: t),
                    child: Center(
                      child: Transform.scale(
                        scale: logo,
                        child: Transform.rotate(
                          angle: (1 - logo) * -math.pi / 4,
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF5B8CFF), Color(0xFF22D3EE)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF22D3EE).withValues(alpha: 0.35),
                                  blurRadius: 24,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 40),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Opacity(
                  opacity: text,
                  child: Transform.translate(
                    offset: Offset(0, (1 - text) * 14),
                    child: const Text(
                      'Universal Billing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Opacity(
                  opacity: tag,
                  child: const Text(
                    'GST billing · POS · Inventory',
                    style: TextStyle(
                      color: Color(0xFF9FB3D9),
                      fontSize: 13,
                      letterSpacing: 0.6,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 4;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withValues(alpha: 0.08);
    canvas.drawCircle(c, r, base);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3
      ..shader = const SweepGradient(colors: [Color(0xFF5B8CFF), Color(0xFF22D3EE), Color(0xFF5B8CFF)])
          .createShader(Rect.fromCircle(center: c, radius: r));
    final sweep = 2 * math.pi * Curves.easeInOut.transform(progress.clamp(0.0, 1.0));
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(progress * math.pi * 1.5 - math.pi / 2);
    canvas.translate(-c.dx, -c.dy);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), 0, sweep, false, arc);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
