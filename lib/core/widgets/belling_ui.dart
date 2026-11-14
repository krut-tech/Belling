import 'package:flutter/material.dart' hide Text;
import '../theme/app_colors.dart';
import '../tr_text.dart';
import 'motion.dart';

/// Shared building blocks for the Belling 2.0 look
/// (cream background, indigo hero cards, saffron gradient actions).

/// Dark indigo hero card with a soft saffron glow.
class HeroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const HeroCard({super.key, required this.child, this.padding = const EdgeInsets.all(20)});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.accent.withValues(alpha: 0.5),
                  AppColors.accent.withValues(alpha: 0),
                ]),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// White rounded card with a soft shadow.
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  const SoftCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final box = Container(
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x0A14152B), blurRadius: 24, offset: Offset(0, 8)),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(padding: padding, child: child),
      ),
    );
    if (onTap == null) return box;
    return PressScale(
      child: Material(
        color: Colors.transparent,
        child: InkWell(borderRadius: BorderRadius.circular(22), onTap: onTap, child: box),
      ),
    );
  }
}

/// Rounded square tile holding an icon.
class IconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final double size;
  const IconTile({super.key, required this.icon, required this.color, required this.background, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(size * 0.32)),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// Small pill label (Paid, Baaki, Stock 48 ...).
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color background;
  const StatusBadge(this.text, {super.key, required this.color, required this.background});

  factory StatusBadge.good(String text) =>
      StatusBadge(text, color: AppColors.lightSuccess, background: AppColors.goodBg);
  factory StatusBadge.due(String text) =>
      StatusBadge(text, color: AppColors.lightDanger, background: AppColors.dueBg);
  factory StatusBadge.warn(String text) =>
      StatusBadge(text, color: AppColors.lightWarning, background: AppColors.warnBg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}

/// Coloured square with 1-2 letters (category / party initial).
class MonoTile extends StatelessWidget {
  final String label;
  final Color color;
  final double size;
  const MonoTile(this.label, {super.key, required this.color, this.size = 42});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(size * 0.32)),
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * 0.36),
      ),
    );
  }
}

const List<Color> kTileColors = [
  AppColors.accent,
  AppColors.blue,
  Color(0xFF0F9D8A),
  AppColors.violet,
  Color(0xFFE0488B),
  Color(0xFFB45309),
];

/// Stable colour for a name (same name -> same colour).
Color tileColorFor(String name) {
  var h = 0;
  for (final c in name.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return kTileColors[h % kTileColors.length];
}

String initialsOf(String name, {int max = 1}) {
  final t = name.trim();
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'\s+'));
  if (max == 1 || parts.length == 1) return t.substring(0, 1).toUpperCase();
  return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
}

/// Saffron gradient pill button.
class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;
  final bool expand;
  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.height = 54,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final btn = Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Color(0x59FF6A1F), blurRadius: 24, offset: Offset(0, 10))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 8)],
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
    final tappable = Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: BorderRadius.circular(18), onTap: onPressed, child: btn),
    );
    return expand ? SizedBox(width: double.infinity, child: tappable) : tappable;
  }
}

/// Page title block used instead of a plain AppBar title:
/// big title, optional subtitle, optional trailing actions.
class BellingHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showBack;
  const BellingHeader({super.key, required this.title, this.subtitle, this.actions = const [], this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
      child: Row(
        children: [
          if (showBack) ...[
            SoftIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.of(context).maybePop()),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.lightMuted)),
              ],
            ),
          ),
          ...actions.expand((w) => [const SizedBox(width: 10), w]),
        ],
      ),
    );
  }
}

/// White rounded-square icon button (header actions).
class SoftIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool dot;
  final String? tooltip;
  const SoftIconButton({super.key, required this.icon, this.onTap, this.dot = false, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final w = Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.lightText),
              if (dot)
                Positioned(
                  top: 9,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    return tooltip == null ? w : Tooltip(message: tooltip!, child: w);
  }
}

/// Floating pill navigation bar (Belling 2.0).
class PillNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelected;
  final List<PillNavItem> items;
  const PillNavBar({super.key, required this.index, required this.onSelected, required this.items});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.lightBorder),
            boxShadow: const [BoxShadow(color: Color(0x2914152B), blurRadius: 34, offset: Offset(0, 14))],
          ),
          child: LayoutBuilder(builder: (context, c) {
            final slot = (c.maxWidth - 8) / items.length;
            return Stack(
              children: [
                // Magnetic indicator: slides to the chosen tab with a soft overshoot.
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutBack,
                  left: 4 + slot * index,
                  top: 6,
                  width: slot,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [BoxShadow(color: Color(0x66FF6A1F), blurRadius: 18, offset: Offset(0, 8))],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      for (var i = 0; i < items.length; i++)
                        Expanded(
                          child: _PillItem(item: items[i], selected: i == index, onTap: () => onSelected(i)),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class PillNavItem {
  final IconData icon;
  final String label;
  const PillNavItem(this.icon, this.label);
}

class _PillItem extends StatefulWidget {
  final PillNavItem item;
  final bool selected;
  final VoidCallback onTap;
  const _PillItem({required this.item, required this.selected, required this.onTap});

  @override
  State<_PillItem> createState() => _PillItemState();
}

class _PillItemState extends State<_PillItem> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    return Semantics(
      button: true,
      selected: selected,
      label: widget.item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.88 : (selected ? 1.06 : 1),
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: SizedBox(
            height: 68,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.item.icon, size: 22, color: selected ? Colors.white : AppColors.lightMuted),
                if (selected)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      widget.item.label,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
