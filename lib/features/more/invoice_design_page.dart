import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:printing/printing.dart' show PdfPreview;

import '../../core/invoice_pdf.dart';
import '../../core/invoice_style.dart';
import '../../data/database.dart';
import '../../data/providers.dart';

/// Lets each business shape how its bills look when printed or shared:
/// paper size, layout, colours, logo and its own stationary / letterhead.
class InvoiceDesignPage extends ConsumerStatefulWidget {
  const InvoiceDesignPage({super.key});

  @override
  ConsumerState<InvoiceDesignPage> createState() => _InvoiceDesignPageState();
}

class _InvoiceDesignPageState extends ConsumerState<InvoiceDesignPage> {
  InvoiceStyle _style = InvoiceStyle.classicDefault;
  InvoiceAssets _assets = const InvoiceAssets();
  bool _loaded = false;
  int _version = 0; // bumps to rebuild the preview

  static const _paperNames = {
    InvoicePaper.auto: 'Auto (use the paper chosen while printing)',
    InvoicePaper.a4: 'A4 (210 × 297 mm)',
    InvoicePaper.a5: 'A5 (148 × 210 mm)',
    InvoicePaper.letter: 'Letter (8.5 × 11 in)',
    InvoicePaper.thermal80: 'Thermal roll 80 mm',
    InvoicePaper.thermal58: 'Thermal roll 58 mm',
    InvoicePaper.custom: 'Custom size',
  };

  static const _layoutNames = {
    InvoiceLayout.auto: 'Auto (fits the paper)',
    InvoiceLayout.classic: 'Classic (full tax invoice)',
    InvoiceLayout.compact: 'Compact (small paper)',
    InvoiceLayout.receipt: 'Receipt (narrow roll)',
  };

  static const _accents = <int>[
    0x2F5BEA, // blue
    0x0F766E, // teal
    0x15803D, // green
    0xB45309, // amber
    0xB91C1C, // red
    0x7C3AED, // violet
    0x111827, // black
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final style = await InvoiceStyleStore.load(db);
    final assets = await InvoiceStyleStore.loadAssets(style);
    if (!mounted) return;
    setState(() {
      _style = style;
      _assets = assets;
      _loaded = true;
      _version++;
    });
  }

  Future<void> _apply(InvoiceStyle next, {bool reloadAssets = false}) async {
    final db = ref.read(databaseProvider);
    final assets = reloadAssets ? await InvoiceStyleStore.loadAssets(next) : _assets;
    if (!mounted) return;
    setState(() {
      _style = next;
      _assets = assets;
      _version++;
    });
    try {
      await InvoiceStyleStore.save(db, next);
    } catch (e) {
      _toast('Could not save: $e');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickImage({required bool logo}) async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: logo ? const ['png', 'jpg', 'jpeg'] : const ['png', 'jpg', 'jpeg', 'pdf'],
      );
      final path = res?.files.single.path;
      if (path == null) return;
      final saved = await InvoiceStyleStore.importImage(
        kind: logo ? 'logo' : 'background',
        sourcePath: path,
      );
      await _apply(
        logo ? _style.copyWith(logoPath: saved, showLogo: true) : _style.copyWith(backgroundPath: saved),
        reloadAssets: true,
      );
    } catch (e) {
      _toast(e.toString().replaceFirst('Bad state: ', ''));
    }
  }

  /// Sample document so the preview shows the real layout without needing a bill.
  Future<Uint8List> _buildSample(PdfPageFormat format) async {
    final business = ref.read(activeBusinessProvider).valueOrNull;
    final now = DateTime.now();
    DocumentLine line(String id, String name, int qty, int rate, int disc, int taxable, int cgst, int sgst, int total) {
      return DocumentLine(
        id: id,
        documentId: 'sample',
        businessId: business?.id ?? 'sample',
        productId: id,
        name: name,
        hsn: '1101',
        qtyMilli: qty,
        ratePaise: rate,
        discountPaise: disc,
        gstRateBp: 500,
        taxablePaise: taxable,
        cgstPaise: cgst,
        sgstPaise: sgst,
        igstPaise: 0,
        lineTotalPaise: total,
        createdAt: now,
      );
    }

    final lines = [
      line('s1', 'Wheat Flour 5 kg', 2000, 28500, 0, 57000, 1425, 1425, 59850),
      line('s2', 'Basmati Rice 1 kg', 1000, 12000, 1000, 11000, 275, 275, 11550),
    ];
    final snapshot = {
      'seller': {
        'id': business?.id ?? 'sample',
        'name': business?.name ?? 'Your Business Name',
        'gstin': business?.gstin ?? '24ABCDE1234F1Z5',
        'state_code': business?.stateCode ?? '24',
        'address': (business?.address.isNotEmpty ?? false) ? business!.address : 'Main Road, Your City',
        'upi_id': (business?.upiId?.isNotEmpty ?? false) ? business!.upiId : 'yourshop@upi',
        'invoice_terms': (business?.invoiceTerms?.isNotEmpty ?? false)
            ? business!.invoiceTerms
            : 'Goods once sold will not be taken back.',
      },
      'buyer': {'name': 'Sample Customer', 'phone': '9876543210', 'state_code': '24'},
      'tax_breakup': {
        'taxable_paise': 68000,
        'cgst_paise': 1700,
        'sgst_paise': 1700,
        'igst_paise': 0,
        'round_off_paise': 0,
        'total_paise': 71400,
      },
      'paid_paise': 50000,
      'balance_paise': 21400,
      'number': 'A-0001',
      'doc_type': 'invoice',
      'status': 'issued',
      'issued_at': now.toIso8601String(),
    };
    return generateInvoicePdf(
      snapshotJson: jsonEncode(snapshot),
      lines: lines,
      style: _style,
      assets: _assets,
      dialogFormat: format,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bill design & paper')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Preview (sample bill)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 420,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: PdfPreview(
                      key: ValueKey(_version),
                      build: _buildSample,
                      useActions: false,
                      canChangePageFormat: false,
                      canChangeOrientation: false,
                      canDebug: false,
                      allowPrinting: false,
                      allowSharing: false,
                      maxPageWidth: 380,
                      onError: (context, error) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('Preview failed: $error'),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Design only changes how the bill looks. Amounts, GST and bill numbers always come from the issued bill.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),
                _section('Paper'),
                DropdownButtonFormField<InvoicePaper>(
                  value: _style.paper,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Paper size', border: OutlineInputBorder()),
                  items: [
                    for (final e in _paperNames.entries) DropdownMenuItem(value: e.key, child: Text(e.value)),
                  ],
                  onChanged: (v) {
                    if (v != null) _apply(_style.copyWith(paper: v));
                  },
                ),
                if (_style.paper == InvoicePaper.custom) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _mmField('Width (mm)', _style.customWidthMm, (v) => _apply(_style.copyWith(customWidthMm: v))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _mmField('Height (mm)', _style.customHeightMm, (v) => _apply(_style.copyWith(customHeightMm: v))),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<InvoiceLayout>(
                  value: _style.layout,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Layout', border: OutlineInputBorder()),
                  items: [
                    for (final e in _layoutNames.entries) DropdownMenuItem(value: e.key, child: Text(e.value)),
                  ],
                  onChanged: (v) {
                    if (v != null) _apply(_style.copyWith(layout: v));
                  },
                ),
                const SizedBox(height: 16),
                _section('Your own stationary / letterhead'),
                const Text(
                  'Upload your pre-printed design (PNG, JPG or PDF). The bill is printed on top of it. '
                  'Use the margins below to keep the text inside the empty area.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => _pickImage(logo: false),
                      icon: const Icon(Icons.wallpaper),
                      label: Text(_style.backgroundPath == null ? 'Upload stationary' : 'Change stationary'),
                    ),
                    if (_style.backgroundPath != null)
                      OutlinedButton.icon(
                        onPressed: () => _apply(_style.copyWith(clearBackground: true), reloadAssets: true),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Remove'),
                      ),
                  ],
                ),
                if (_style.backgroundPath != null) ...[
                  const SizedBox(height: 8),
                  SegmentedButton<BackgroundFit>(
                    segments: const [
                      ButtonSegment(value: BackgroundFit.full, label: Text('Stretch to page')),
                      ButtonSegment(value: BackgroundFit.contain, label: Text('Keep shape')),
                    ],
                    selected: {_style.backgroundFit},
                    onSelectionChanged: (s) => _apply(_style.copyWith(backgroundFit: s.first)),
                  ),
                ],
                const SizedBox(height: 16),
                _section('Margins (mm)'),
                _slider('Top', _style.marginTopMm, 0, 60, (v) => _style.copyWith(marginTopMm: v)),
                _slider('Bottom', _style.marginBottomMm, 0, 60, (v) => _style.copyWith(marginBottomMm: v)),
                _slider('Left', _style.marginLeftMm, 0, 40, (v) => _style.copyWith(marginLeftMm: v)),
                _slider('Right', _style.marginRightMm, 0, 40, (v) => _style.copyWith(marginRightMm: v)),
                const SizedBox(height: 8),
                _section('Look'),
                Wrap(
                  spacing: 10,
                  children: [
                    for (final c in _accents)
                      GestureDetector(
                        onTap: () => _apply(_style.copyWith(accentColor: c)),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Color(0xFF000000 | c),
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: _style.accentColor == c ? 3 : 1,
                              color: _style.accentColor == c ? Colors.black87 : Colors.black26,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _slider('Text size', _style.fontScale, 0.7, 1.5, (v) => _style.copyWith(fontScale: v), suffix: '×'),
                const SizedBox(height: 8),
                _section('Logo'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => _pickImage(logo: true),
                      icon: const Icon(Icons.image_outlined),
                      label: Text(_style.logoPath == null ? 'Upload logo' : 'Change logo'),
                    ),
                    if (_style.logoPath != null)
                      OutlinedButton.icon(
                        onPressed: () => _apply(_style.copyWith(clearLogo: true), reloadAssets: true),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Remove'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _section('Show on bill'),
                _toggle('Logo', _style.showLogo, (v) => _apply(_style.copyWith(showLogo: v), reloadAssets: true)),
                _toggle('HSN column', _style.showHsn, (v) => _apply(_style.copyWith(showHsn: v))),
                _toggle('UPI QR code', _style.showQr, (v) => _apply(_style.copyWith(showQr: v))),
                _toggle('Terms & conditions', _style.showTerms, (v) => _apply(_style.copyWith(showTerms: v))),
                _toggle('Signature box', _style.showSignature, (v) => _apply(_style.copyWith(showSignature: v))),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _apply(InvoiceStyle.classicDefault.copyWith(), reloadAssets: true),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset to default look'),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      );

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        value: value,
        onChanged: onChanged,
      );

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    InvoiceStyle Function(double) update, {
    String suffix = ' mm',
  }) {
    final shown = value.clamp(min, max).toDouble();
    return Row(
      children: [
        SizedBox(width: 72, child: Text(label)),
        Expanded(
          child: Slider(
            value: shown,
            min: min,
            max: max,
            onChanged: (v) => setState(() => _style = update(v)),
            onChangeEnd: (v) => _apply(update(v)),
          ),
        ),
        SizedBox(width: 56, child: Text('${shown.toStringAsFixed(1)}$suffix', textAlign: TextAlign.end)),
      ],
    );
  }

  Widget _mmField(String label, double value, ValueChanged<double> onValid) {
    return TextFormField(
      initialValue: value.toStringAsFixed(0),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
      onChanged: (t) {
        final v = double.tryParse(t);
        if (v != null && v >= 40 && v <= 600) onValid(v);
      },
    );
  }
}
