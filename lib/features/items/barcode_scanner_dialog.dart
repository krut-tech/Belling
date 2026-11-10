import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../l10n/app_localizations.dart';
import '../../core/tr_text.dart';

/// EAN-13 / EAN-8 / UPC-A carry a check digit. A camera frame that is blurry or
/// at an angle can decode to a wrong number with the wrong check digit; such a
/// read must be ignored (and scanning continue) rather than reported as a
/// product that "does not exist".
bool isPlausibleBarcode(String raw) {
  final code = raw.trim();
  final isDigits = RegExp(r'^\d+$').hasMatch(code);
  if (!isDigits) return code.isNotEmpty; // Code128/39/QR etc. have no simple check digit
  if (code.length != 8 && code.length != 12 && code.length != 13) return true;
  var sum = 0;
  for (var i = 0; i < code.length - 1; i++) {
    final digit = int.parse(code[code.length - 2 - i]);
    sum += digit * (i.isEven ? 3 : 1);
  }
  final check = (10 - sum % 10) % 10;
  return check == int.parse(code[code.length - 1]);
}

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
  late final MobileScannerController _scanner = MobileScannerController(
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.qrCode,
    ],
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    autoStart: true,
  );
  bool _handled = false;
  bool _torchOn = false;

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
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _retryCamera() async {
    try {
      await _scanner.stop();
    } catch (_) {}
    try {
      await _scanner.start();
    } catch (_) {}
  }

  void _submitCode(String code) {
    // onDetect fires many times per second; pop exactly once, otherwise the
    // extra pops close the page underneath the dialog.
    if (_handled) return;
    final trimmed = code.trim();
    if (trimmed.isNotEmpty) {
      _handled = true;
      HapticFeedback.mediumImpact();
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
          if (!_useManualInput)
            IconButton(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
              tooltip: 'Torch',
              onPressed: () async {
                await _scanner.toggleTorch();
                if (mounted) setState(() => _torchOn = !_torchOn);
              },
            ),
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
        width: 340,
        height: 420,
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
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scanner,
            fit: BoxFit.cover,
            onDetect: (capture) {
              for (final b in capture.barcodes) {
                final code = b.rawValue;
                if (code != null && code.trim().isNotEmpty && isPlausibleBarcode(code)) {
                  _submitCode(code);
                  return;
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
                        error.errorCode == MobileScannerErrorCode.permissionDenied
                            ? 'Camera permission band hai. Phone Settings > Apps > belling > Permissions me Camera allow karo.'
                            : l10n.cameraNotAvailable,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '(${error.errorCode.name}${error.errorDetails?.message == null ? '' : ': ${error.errorDetails!.message}'})',
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: _retryCamera,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Camera dobara try karo'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () => setState(() => _useManualInput = true),
                        child: Text(l10n.typeOrScanBarcode),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Aiming frame
          IgnorePointer(
            child: Center(
              child: Container(
                width: 260,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: IgnorePointer(
              child: Text(
                'Barcode ko frame ke andar rakho',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 6)]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
