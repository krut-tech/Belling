import 'package:flutter/material.dart';

/// Fade + slide-up entrance, staggered by [index] (only the first few items
/// get a delay so long lists stay snappy).
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 16,
  });

  final Widget child;
  final int index;
  final double offset;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) return child;
    final delayMs = (index.clamp(0, 8)) * 40;
    final total = 320 + delayMs;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delayMs / total, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * offset), child: child),
      ),
      child: child,
    );
  }
}

/// Re-plays a short fade/slide whenever [index] changes (tab switches) without
/// recreating the child, so tab state is preserved.
class TabFadeIn extends StatefulWidget {
  const TabFadeIn({super.key, required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<TabFadeIn> createState() => _TabFadeInState();
}

class _TabFadeInState extends State<TabFadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 260))..value = 1;
  late final Animation<double> _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void didUpdateWidget(TabFadeIn old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index && !(MediaQuery.maybeOf(context)?.disableAnimations ?? false)) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (context, child) => Opacity(
        opacity: 0.4 + 0.6 * _a.value,
        child: Transform.translate(offset: Offset(0, (1 - _a.value) * 10), child: child),
      ),
      child: widget.child,
    );
  }
}

/// Pops in with a springy scale (used for success checks, empty states).
class PopIn extends StatelessWidget {
  const PopIn({super.key, required this.child, this.delay = Duration.zero});
  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600) + delay,
      curve: Interval(delay.inMilliseconds / (600 + delay.inMilliseconds), 1, curve: Curves.elasticOut),
      builder: (context, t, child) => Transform.scale(scale: t, child: Opacity(opacity: t.clamp(0, 1), child: child)),
      child: child,
    );
  }
}

/// Slide + fade page transition used for every route.
class SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const SmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero).animate(curved),
        child: child,
      ),
    );
  }
}

const kSmoothPageTransitions = PageTransitionsTheme(builders: {
  TargetPlatform.android: SmoothPageTransitionsBuilder(),
  TargetPlatform.iOS: SmoothPageTransitionsBuilder(),
  TargetPlatform.windows: SmoothPageTransitionsBuilder(),
  TargetPlatform.linux: SmoothPageTransitionsBuilder(),
  TargetPlatform.macOS: SmoothPageTransitionsBuilder(),
});

/// Wraps each child in a staggered [FadeSlideIn].
List<Widget> staggered(List<Widget> children, {double offset = 18}) => [
      for (var i = 0; i < children.length; i++) FadeSlideIn(index: i, offset: offset, child: children[i]),
    ];

/// Slight press-down scale for tappable cards/tiles.
class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child});
  final Widget child;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _down = true),
      onPointerUp: (_) => setState(() => _down = false),
      onPointerCancel: (_) => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
