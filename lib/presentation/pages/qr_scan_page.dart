
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanPage extends StatefulWidget {
  final Function(String) onScan;

  const QrScanPage({Key? key, required this.onScan}) : super(key: key);

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear código QR')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_isScanned) return; 

          final barcode = capture.barcodes.first;
          final code = barcode.rawValue;

          if (code != null) {
            _isScanned = true; 
            widget.onScan(code);

            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                Navigator.pop(context);
              }
            });
          }
        },
      ),
    );
  }
}

