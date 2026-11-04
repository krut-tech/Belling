import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../l10n/app_localizations.dart';

class BarcodeScannerDialog extends StatefulWidget {
  const BarcodeScannerDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const BarcodeScannerDialog(),
    );
  }

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog> {
  late bool _useManualInput;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _useManualInput = kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitCode(String code) {
    final trimmed = code.trim();
    if (trimmed.isNotEmpty) {
      Navigator.of(context).pop(trimmed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.scanTitle),
          IconButton(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: Icon(_useManualInput ? Icons.camera_alt : Icons.keyboard),
            tooltip: _useManualInput ? 'Use Camera' : 'Use Keyboard',
            onPressed: () {
              setState(() {
                _useManualInput = !_useManualInput;
              });
            },
          ),
        ],
      ),
      content: SizedBox(
        width: 320,
        height: 320,
        child: _useManualInput ? _buildManualInput(l10n) : _buildCameraScanner(l10n),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(64, 48),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }

  Widget _buildManualInput(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.qr_code_scanner, size: 64, color: Theme.of(context).primaryColor),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.barcode,
            hintText: l10n.typeOrScanBarcode,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: _submitCode,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: () => _submitCode(_controller.text),
          child: Text(l10n.save),
        ),
      ],
    );
  }

  Widget _buildCameraScanner(AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: MobileScanner(
        onDetect: (capture) {
          final barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final code = barcodes.first.rawValue;
            if (code != null && code.trim().isNotEmpty) {
              _submitCode(code);
            }
          }
        },
        errorBuilder: (context, error, child) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam_off, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    l10n.cameraNotAvailable,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      setState(() {
                        _useManualInput = true;
                      });
                    },
                    child: Text(l10n.typeOrScanBarcode),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
