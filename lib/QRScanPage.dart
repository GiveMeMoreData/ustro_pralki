
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';

class QRSCanPage extends StatefulWidget {

  static const routeName = "/home/scan";


  @override
  _QRSCanPageState createState() => _QRSCanPageState();


}

class QRScanPageArguments{

  final Function callback;
  QRScanPageArguments(this.callback);
}


class _QRSCanPageState extends State<QRSCanPage> {

  final MobileScannerController controller = MobileScannerController(
      facing: CameraFacing.back,
      formats: [BarcodeFormat.qrCode],
      torchEnabled: false);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as QRScanPageArguments;
    return Stack(
      children: [
        MobileScanner(
            allowDuplicates: false,
            controller: controller,
            onDetect: (barcode, _) {
              if (barcode.rawValue == null) {
                debugPrint('Failed to scan Barcode');
              } else {
                final String code = barcode.rawValue!;
                debugPrint('Barcode found! $code');
                controller.dispose();
                Navigator.of(context).pop();
                args.callback(code);
              }
            }),
      ],
    );
  }
}