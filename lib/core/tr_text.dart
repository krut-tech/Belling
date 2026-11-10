import 'package:flutter/material.dart' as m;
import 'package:flutter/widgets.dart';

import 'tr.dart';

/// Drop-in replacement for Flutter's `Text` that shows the English version of
/// Hinglish strings when the app language is English. Use with
/// `import 'package:flutter/material.dart' hide Text;`.
class Text extends StatelessWidget {
  const Text(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.semanticsLabel,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return m.Text(
      tr(context, data),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      semanticsLabel: semanticsLabel,
    );
  }
}
