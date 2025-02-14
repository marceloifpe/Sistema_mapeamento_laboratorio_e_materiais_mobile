import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  final Function(String) onScan;

  QRScannerScreen({required this.onScan});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String qrCodeResult = "";
  bool isScanning = true;

  void _onDetect(BarcodeCapture barcodeCapture) {
    if (!isScanning) return;

    final String? code = barcodeCapture.barcodes.isNotEmpty ? barcodeCapture.barcodes.first.rawValue : null;

    if (code != null) {
      setState(() {
        qrCodeResult = code;
        isScanning = false;
      });

      // Retorna o resultado do QR Code
      widget.onScan(qrCodeResult);

      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
        setState(() {
          isScanning = true;
        });
      });
    } else {
      print("Nenhum QR code detectado");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Escanear QR Code"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  onDetect: _onDetect,
                ),
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent, width: 3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                qrCodeResult.isEmpty
                    ? Text('Aponte a câmera para um QR Code', style: TextStyle(fontSize: 16))
                    : Text('Resultado: $qrCodeResult', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("Cancelar"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
