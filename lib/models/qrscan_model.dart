import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

class QrScan {
  String idScan;
  String tipo;
  String valor;

  QrScan({required this.idScan, required this.tipo, required this.valor}) {
    if (valor.contains('http')) {
      tipo = 'http';
    } else {
      tipo = 'geo';
    }
  }

  factory QrScan.fromStorage(Map<String, dynamic> mapQrScan) {
    return QrScan(
        idScan: mapQrScan['idScan'],
        tipo: mapQrScan['tipo'],
        valor: mapQrScan['valor']);
  }

  Map<String, dynamic> toMap() => {
        'idScan': idScan,
        'tipo': tipo,
        'valor': valor,
      };

  LatLng getLatLng() {
    final latLng = this.valor.substring(4).split(',');
    final lat = double.parse(latLng[0]);
    final lng = double.parse(latLng[2]);

    return LatLng(lat, lng);
  }
}
