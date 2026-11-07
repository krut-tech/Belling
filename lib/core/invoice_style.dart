import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../data/database.dart';

/// Paper the invoice is generated for.
enum InvoicePaper {
  /// Use whatever paper the person picks in the print dialog. When saving or
  /// sharing a PDF (no dialog) A4 is used.
  auto,
  a4,
  a5,
  letter,
  thermal80,
  thermal58,
  custom,
}

/// Page structure.
enum InvoiceLayout {
  /// Decided from the paper width: narrow paper -> receipt, A5 -> compact, else classic.
  auto,

  /// Full A4-style tax invoice with item table, tax summary and totals box.
  classic,

  /// Same content, smaller type and tighter spacing (A5 / half sheets).
  compact,

  /// Single-column roll/thermal receipt.
  receipt,
}

/// How a stationary / letterhead image is placed behind the invoice.
enum BackgroundFit {
  /// Stretch over the whole page.
  full,

  /// Keep its shape and fit inside the page.
  contain,
}

/// Per-business look of the printed / shared invoice.
///
/// Only presentation lives here. Totals, taxes and the legal fields always come
/// from the issued document, so a style can never change what an invoice says.
class InvoiceStyle {
  final InvoicePaper paper;
  final double customWidthMm;
  final double customHeightMm;
  final InvoiceLayout layout;
  final double marginTopMm;
  final double marginBottomMm;
  final double marginLeftMm;
  final double marginRightMm;
  final int accentColor; // 0xRRGGBB
  final double fontScale;
  final bool showLogo;
  final bool showQr;
  final bool showTerms;
  final bool showSignature;
  final bool showHsn;
  final String? logoPath;
  final String? backgroundPath;
  final BackgroundFit backgroundFit;

  const InvoiceStyle({
    this.paper = InvoicePaper.auto,
    this.customWidthMm = 210,
    this.customHeightMm = 297,
    this.layout = InvoiceLayout.auto,
    this.marginTopMm = 8.5,
    this.marginBottomMm = 8.5,
    this.marginLeftMm = 8.5,
    this.marginRightMm = 8.5,
    this.accentColor = 0x2F5BEA,
    this.fontScale = 1.0,
    this.showLogo = true,
    this.showQr = true,
    this.showTerms = true,
    this.showSignature = true,
    this.showHsn = true,
    this.logoPath,
    this.backgroundPath,
    this.backgroundFit = BackgroundFit.full,
  });

  /// The look the app had before styles existed (A4, 24pt margins).
  static const InvoiceStyle classicDefault = InvoiceStyle();

  static const double _minMm = 40;
  static const double _maxMm = 600;

  InvoiceStyle copyWith({
    InvoicePaper? paper,
    double? customWidthMm,
    double? customHeightMm,
    InvoiceLayout? layout,
    double? marginTopMm,
    double? marginBottomMm,
    double? marginLeftMm,
    double? marginRightMm,
    int? accentColor,
    double? fontScale,
    bool? showLogo,
    bool? showQr,
    bool? showTerms,
    bool? showSignature,
    bool? showHsn,
    String? logoPath,
    bool clearLogo = false,
    String? backgroundPath,
    bool clearBackground = false,
    BackgroundFit? backgroundFit,
  }) {
    return InvoiceStyle(
      paper: paper ?? this.paper,
      customWidthMm: customWidthMm ?? this.customWidthMm,
      customHeightMm: customHeightMm ?? this.customHeightMm,
      layout: layout ?? this.layout,
      marginTopMm: marginTopMm ?? this.marginTopMm,
      marginBottomMm: marginBottomMm ?? this.marginBottomMm,
      marginLeftMm: marginLeftMm ?? this.marginLeftMm,
      marginRightMm: marginRightMm ?? this.marginRightMm,
      accentColor: accentColor ?? this.accentColor,
      fontScale: fontScale ?? this.fontScale,
      showLogo: showLogo ?? this.showLogo,
      showQr: showQr ?? this.showQr,
      showTerms: showTerms ?? this.showTerms,
      showSignature: showSignature ?? this.showSignature,
      showHsn: showHsn ?? this.showHsn,
      logoPath: clearLogo ? null : (logoPath ?? this.logoPath),
      backgroundPath: clearBackground ? null : (backgroundPath ?? this.backgroundPath),
      backgroundFit: backgroundFit ?? this.backgroundFit,
    );
  }

  Map<String, dynamic> toMap() => {
        'paper': paper.name,
        'customWidthMm': customWidthMm,
        'customHeightMm': customHeightMm,
        'layout': layout.name,
        'marginTopMm': marginTopMm,
        'marginBottomMm': marginBottomMm,
        'marginLeftMm': marginLeftMm,
        'marginRightMm': marginRightMm,
        'accentColor': accentColor,
        'fontScale': fontScale,
        'showLogo': showLogo,
        'showQr': showQr,
        'showTerms': showTerms,
        'showSignature': showSignature,
        'showHsn': showHsn,
        'logoPath': logoPath,
        'backgroundPath': backgroundPath,
        'backgroundFit': backgroundFit.name,
      };

  /// Tolerant reader: unknown or missing values fall back to defaults so an
  /// old or damaged setting can never stop an invoice from printing.
  factory InvoiceStyle.fromMap(Map<String, dynamic> m) {
    T pick<T extends Enum>(List<T> values, Object? name, T fallback) {
      for (final v in values) {
        if (v.name == name) return v;
      }
      return fallback;
    }

    double dbl(Object? v, double fallback, double min, double max) {
      final d = (v is num) ? v.toDouble() : fallback;
      if (d.isNaN || d.isInfinite) return fallback;
      return d.clamp(min, max).toDouble();
    }

    bool b(Object? v, bool fallback) => v is bool ? v : fallback;

    const d = InvoiceStyle();
    return InvoiceStyle(
      paper: pick(InvoicePaper.values, m['paper'], d.paper),
      customWidthMm: dbl(m['customWidthMm'], d.customWidthMm, _minMm, _maxMm),
      customHeightMm: dbl(m['customHeightMm'], d.customHeightMm, _minMm, _maxMm),
      layout: pick(InvoiceLayout.values, m['layout'], d.layout),
      marginTopMm: dbl(m['marginTopMm'], d.marginTopMm, 0, 40),
      marginBottomMm: dbl(m['marginBottomMm'], d.marginBottomMm, 0, 40),
      marginLeftMm: dbl(m['marginLeftMm'], d.marginLeftMm, 0, 40),
      marginRightMm: dbl(m['marginRightMm'], d.marginRightMm, 0, 40),
      accentColor: (m['accentColor'] is int) ? (m['accentColor'] as int) & 0xFFFFFF : d.accentColor,
      fontScale: dbl(m['fontScale'], d.fontScale, 0.7, 1.5),
      showLogo: b(m['showLogo'], d.showLogo),
      showQr: b(m['showQr'], d.showQr),
      showTerms: b(m['showTerms'], d.showTerms),
      showSignature: b(m['showSignature'], d.showSignature),
      showHsn: b(m['showHsn'], d.showHsn),
      logoPath: m['logoPath'] as String?,
      backgroundPath: m['backgroundPath'] as String?,
      backgroundFit: pick(BackgroundFit.values, m['backgroundFit'], d.backgroundFit),
    );
  }

  /// Page size for this style. [dialogFormat] is the paper chosen in the print
  /// dialog, used only when [paper] is [InvoicePaper.auto].
  PdfPageFormat pageFormat({PdfPageFormat? dialogFormat}) {
    const mm = PdfPageFormat.mm;
    switch (paper) {
      case InvoicePaper.auto:
        return dialogFormat ?? PdfPageFormat.a4;
      case InvoicePaper.a4:
        return PdfPageFormat.a4;
      case InvoicePaper.a5:
        return PdfPageFormat.a5;
      case InvoicePaper.letter:
        return PdfPageFormat.letter;
      case InvoicePaper.thermal80:
        return const PdfPageFormat(80 * mm, double.infinity);
      case InvoicePaper.thermal58:
        return const PdfPageFormat(58 * mm, double.infinity);
      case InvoicePaper.custom:
        return PdfPageFormat(customWidthMm * mm, customHeightMm * mm);
    }
  }

  /// Layout actually used for a page of [format]: an explicit choice wins,
  /// otherwise narrow paper gets the receipt layout and small paper the compact one.
  InvoiceLayout effectiveLayout(PdfPageFormat format) {
    if (layout != InvoiceLayout.auto) return layout;
    final widthMm = format.width / PdfPageFormat.mm;
    if (widthMm <= 100) return InvoiceLayout.receipt;
    if (widthMm < 170) return InvoiceLayout.compact;
    return InvoiceLayout.classic;
  }

  /// Margins in PDF points. Thermal rolls get at most 3 mm so the narrow
  /// column is not eaten by A4-sized margins.
  InvoiceMargins margins(PdfPageFormat format) {
    const mm = PdfPageFormat.mm;
    final narrow = format.width / mm <= 100;
    double cap(double v) => narrow ? (v > 3 ? 3 : v) : v;
    return InvoiceMargins(
      left: cap(marginLeftMm) * mm,
      top: cap(marginTopMm) * mm,
      right: cap(marginRightMm) * mm,
      bottom: cap(marginBottomMm) * mm,
    );
  }
}

/// Page margins in PDF points.
class InvoiceMargins {
  final double left;
  final double top;
  final double right;
  final double bottom;
  const InvoiceMargins({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });
}

/// Images are read once per print and handed to the generator as bytes.
class InvoiceAssets {
  final Uint8List? logo;
  final Uint8List? background;
  const InvoiceAssets({this.logo, this.background});
}

/// Reads and writes the invoice style of the business (local only: it is a
/// device preference and is not synced to the server).
class InvoiceStyleStore {
  static const _key = 'invoice_style';

  static Future<InvoiceStyle> load(AppDatabase db) async {
    try {
      final row = await (db.select(db.appSettingsTable)..where((t) => t.key.equals(_key))).getSingleOrNull();
      if (row == null) return InvoiceStyle.classicDefault;
      final decoded = jsonDecode(row.value);
      if (decoded is Map<String, dynamic>) return InvoiceStyle.fromMap(decoded);
    } catch (_) {
      // Damaged setting: print with the default look instead of failing.
    }
    return InvoiceStyle.classicDefault;
  }

  static Future<void> save(AppDatabase db, InvoiceStyle style) async {
    await db.into(db.appSettingsTable).insertOnConflictUpdate(
          AppSettingsTableCompanion.insert(key: _key, value: jsonEncode(style.toMap())),
        );
  }

  static Future<InvoiceAssets> loadAssets(InvoiceStyle style) async {
    Future<Uint8List?> read(String? path) async {
      if (path == null) return null;
      try {
        final f = File(path);
        if (await f.exists()) return await f.readAsBytes();
      } catch (_) {}
      return null;
    }

    return InvoiceAssets(
      logo: style.showLogo ? await read(style.logoPath) : null,
      background: await read(style.backgroundPath),
    );
  }

  /// Copies a picked image into the app folder (the picker's temp file can
  /// disappear) and returns the permanent path.
  ///
  /// A PDF is accepted for the background: its first page is converted to an
  /// image so a ready-made letterhead PDF works too.
  static Future<String> importImage({
    required String kind, // 'logo' | 'background'
    required String sourcePath,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final assets = Directory('${dir.path}/invoice_assets');
    if (!await assets.exists()) await assets.create(recursive: true);

    final lower = sourcePath.toLowerCase();
    Uint8List bytes;
    String ext;
    if (lower.endsWith('.pdf')) {
      final pdfBytes = await File(sourcePath).readAsBytes();
      PdfRaster? first;
      await for (final page in Printing.raster(pdfBytes, pages: [0], dpi: 150)) {
        first = page;
        break;
      }
      if (first == null) throw StateError('Could not read the PDF');
      bytes = await first.toPng();
      ext = 'png';
    } else {
      bytes = await File(sourcePath).readAsBytes();
      ext = lower.endsWith('.png') ? 'png' : 'jpg';
    }
    if (bytes.length > 8 * 1024 * 1024) {
      throw StateError('Image is too large (max 8 MB)');
    }

    // Reject files that are not a readable image before saving them.
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      codec.dispose();
    } catch (_) {
      throw StateError('This file is not a readable PNG/JPG image');
    }

    // Unique name so a new image is never served from a cached old one.
    final target = File('${assets.path}/${kind}_${DateTime.now().millisecondsSinceEpoch}.$ext');
    await target.writeAsBytes(bytes, flush: true);

    // Remove older files of the same kind.
    try {
      await for (final f in assets.list()) {
        if (f is File && f.path != target.path && f.uri.pathSegments.last.startsWith('${kind}_')) {
          await f.delete();
        }
      }
    } catch (_) {}
    return target.path;
  }
}
