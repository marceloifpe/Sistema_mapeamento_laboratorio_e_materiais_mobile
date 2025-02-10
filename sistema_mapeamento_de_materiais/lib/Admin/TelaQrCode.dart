import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TelaQrCode extends StatelessWidget {
  final String qrData;

  TelaQrCode({required this.qrData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR Code")),
      body: Center(
        child: QrImageView(
          data: qrData,
          version: QrVersions.auto,
          size: 300.0, // Tamanho maior
        ),
      ),
    );
  }
}
