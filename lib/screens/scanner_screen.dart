import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

enum _ScanState { checking, denied, permanentlyDenied, ready, error }

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController? _controller;
  _ScanState _state = _ScanState.checking;
  String? _errorMessage;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _checkAndStart();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _checkAndStart() async {
    setState(() {
      _state = _ScanState.checking;
      _errorMessage = null;
    });

    if (kIsWeb) {
      _startController();
      return;
    }

    final status = await Permission.camera.request();
    if (!mounted) return;

    if (status.isGranted) {
      _startController();
      return;
    }
    if (status.isPermanentlyDenied) {
      setState(() => _state = _ScanState.permanentlyDenied);
      return;
    }
    setState(() => _state = _ScanState.denied);
  }

  void _startController() {
    if (kIsWeb) {
      MobileScannerPlatform.instance
          .setWebBarcodeReader(WebBarcodeReader.zxingWasm);
    }

    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.front,
      formats: const [
        // QR codes
        BarcodeFormat.qrCode,
        // 1D barcodes
        BarcodeFormat.code128,
        BarcodeFormat.code39,
        BarcodeFormat.code93,
        BarcodeFormat.codabar,
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.itf,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
        // 2D codes
        BarcodeFormat.dataMatrix,
        BarcodeFormat.pdf417,
        BarcodeFormat.aztec,
      ],
      torchEnabled: false,
    );
    setState(() => _state = _ScanState.ready);
  }

  /// Extract roll number from barcode/QR raw value.
  ///
  /// Handles:
  ///   1. JSON:       {"roll":"25EC190"}
  ///   2. Prefixed:   ROLL:25EC190, id=25EC190
  ///   3. ⭐ YOUR FORMAT: 25EC190 (YY + BRANCH + NUMBER)
  ///   4. Other common formats: 23ECE001, ECE23001
  ///   5. Fallback:   first token of the raw string
  String? _extractRollNumber(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    // 1. JSON format
    if (trimmed.startsWith('{')) {
      final match = RegExp(
        r'"(?:roll|rollNumber|roll_no|rollno|id)"\s*:\s*"([^"]+)"',
        caseSensitive: false,
      ).firstMatch(trimmed);
      if (match != null) {
        final v = match.group(1)!.trim();
        if (v.isNotEmpty) return v;
      }
    }

    // 2. Prefixed format: "ROLL:25EC190", "Roll - 25EC190", "id=25EC190"
    final prefixed = RegExp(
      r'(?:roll|rollno|roll_no|id)\s*[:\-=]\s*([A-Za-z0-9]+)',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (prefixed != null) {
      final v = prefixed.group(1)!.trim();
      if (v.isNotEmpty) return v;
    }

    // 3. ⭐ YOUR FORMAT: 2 digits + 2 letters + 3-4 digits
    //    Example: 25EC190, 24CS045, 23ME001
    final yourFormat = RegExp(r'(\d{2}[A-Z]{2,3}\d{3,4})');
    final yourMatch = yourFormat.firstMatch(trimmed.toUpperCase());
    if (yourMatch != null) return yourMatch.group(1);

    // 4. Other common roll formats:
    //    - Letters first: ECE23001, CS23001
    //    - 23ECE001 style: 2 digits + 3 letters + 3 digits
    final altPattern = RegExp(
      r'([A-Z]{2,4}\d{3,6}|\d{2}[A-Z]{2,4}\d{3,6})',
    );
    final altMatch = altPattern.firstMatch(trimmed.toUpperCase());
    if (altMatch != null) return altMatch.group(1);

    // 5. Fallback: first token
    final token = trimmed.split(RegExp(r'[\s,;|]+')).first;
    return token.isEmpty ? null : token;
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    final raw = barcode.rawValue;

    debugPrint('=== DETECTED format=${barcode.format.name} raw=$raw ===');

    if (raw == null || raw.isEmpty) return;

    final roll = _extractRollNumber(raw);
    debugPrint('=== EXTRACTED ROLL: $roll ===');
    if (roll == null) return;

    _handled = true;
    Navigator.of(context).pop(roll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Student ID'),
        actions: _state == _ScanState.ready
            ? [
                IconButton(
                  tooltip: 'Toggle torch',
                  icon: const Icon(Icons.flash_on),
                  onPressed: () => _controller?.toggleTorch(),
                ),
                IconButton(
                  tooltip: 'Switch camera',
                  icon: const Icon(Icons.cameraswitch),
                  onPressed: () => _controller?.switchCamera(),
                ),
              ]
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _ScanState.checking:
        return const Center(child: CircularProgressIndicator());

      case _ScanState.denied:
        return _buildPermissionView(
          icon: Icons.no_photography_outlined,
          title: 'Camera permission denied',
          message: kIsWeb
              ? 'Browser-la camera block aagirukku. Address bar-la padlock icon click panni, Camera-a Allow panni, page-a reload pannunga.'
              : 'StudentPay-ku camera access venum.',
          actionLabel: 'Try Again',
          onAction: _checkAndStart,
        );

      case _ScanState.permanentlyDenied:
        return _buildPermissionView(
          icon: Icons.lock_outline,
          title: 'Camera permission blocked',
          message: kIsWeb
              ? 'Browser-la camera permanently block aagirukku. Padlock icon → Camera → Allow → page reload pannunga.'
              : 'Camera access permanently denied.',
          actionLabel: kIsWeb ? 'Reload Page' : 'Open Settings',
          onAction: () async {
            if (kIsWeb) {
              await _restartScanner();
            } else {
              await openAppSettings();
            }
          },
        );

      case _ScanState.error:
        return _buildPermissionView(
          icon: Icons.error_outline,
          title: 'Scanner error',
          message: _errorMessage ?? 'Something went wrong.',
          actionLabel: 'Retry',
          onAction: _checkAndStart,
        );

      case _ScanState.ready:
        return _buildScanner();
    }
  }

  Future<void> _restartScanner() async {
    await _controller?.dispose();
    _controller = null;
    _handled = false;
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    await _checkAndStart();
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller!,
          onDetect: _onDetect,
          errorBuilder: (context, error) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _state = _ScanState.error;
                  _errorMessage = 'Camera error: ${error.errorCode.name}';
                });
              }
            });
            return const SizedBox.shrink();
          },
        ),
        IgnorePointer(
          child: Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.black54,
            child: const Text(
              'Hold the student ID card in front of the camera',
              style: TextStyle(color: Colors.white, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionView({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: Colors.redAccent),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}