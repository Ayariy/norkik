import 'package:flutter/cupertino.dart';
import 'package:norkik_app/models/qrscan_model.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:url_launcher/url_launcher.dart';

launchURL(BuildContext context, QrScan qrScan) async {
  final url = qrScan.valor;
  if (qrScan.tipo == 'http') {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      getAlert(
          context, 'Alerta URL', 'Lo sentimos, no se pudo abrir el enlace');
    }
  } else {
    Navigator.pushNamed(context, 'ocrMap', arguments: qrScan);
  }
}
