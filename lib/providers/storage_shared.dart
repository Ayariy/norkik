import 'dart:convert';

import 'package:norkik_app/models/pdf_model.dart';
import 'package:norkik_app/models/qrscan_model.dart';
import 'package:norkik_app/models/recordatorio_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageShared {
  agregarFavoritosStorageList(List<String> listNoticias) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('listFavoritosNoticias', listNoticias);
  }

  Future<List<String>> obtenerFavoritosStorageList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('listFavoritosNoticias') ?? [];
  }

  eliminarNoticasFavoritos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('listFavoritosNoticias');
  }

  ///// RECORDATORIOS--------------------
  agregarRecordatoriosStorageList(
      List<RecordatorioModel> listRecordatorioModel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> listRecordatorioString = [];
    for (var recordModel in listRecordatorioModel) {
      Map<String, dynamic> mapRecordatorio = recordModel.toMap();
      String mapString = jsonEncode(mapRecordatorio);
      listRecordatorioString.add(mapString);
    }
    await prefs.setStringList('listRecordatorios', listRecordatorioString);
  }

  Future<List<RecordatorioModel>> obtenerRecordatoriosStorageList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listString = prefs.getStringList('listRecordatorios') ?? [];

    List<RecordatorioModel> listRecordatorio = [];
    for (var itemString in listString) {
      Map<String, dynamic> mapRecordatorio = jsonDecode(itemString);
      mapRecordatorio['fecha'] = DateTime.parse(mapRecordatorio['fecha']);
      listRecordatorio.add(RecordatorioModel.fromStorage(mapRecordatorio));
    }
    return listRecordatorio;
  }

  eliminarRecordatorios() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('listRecordatorios');
  }

  ///COLORES ASIGNATURAS.----------------------------------
  ///
  agregarColoresAsignaturaList(Map<String, dynamic> listColor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String mapColor = jsonEncode(listColor);
    await prefs.setString('mapColor', mapColor);
  }

  Future<Map<String, dynamic>> obtenerColoresAsignaturaList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String mapColorString = prefs.getString('mapColor') ?? '';
    if (mapColorString != '') {
      Map<String, dynamic> mapColor = jsonDecode(mapColorString);
      return mapColor;
    } else {
      return {};
    }
  }

  eliminarColoresAsignaturaList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('mapColor');
  }

  ///CONFIGURACION---------------------------------------
  //GENERAL INDEX PAGE
  agregarIndexPageNavigator(int indexPage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('indexPageMenu', indexPage);
  }

  Future<int> obtenerIndexPageNavigator() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('indexPageMenu') ?? 0;
  }

  eliminarIndexPageNavigator() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('indexPageMenu');
  }

  //QR STORAGE

  agregarQrScanStorageList(List<QrScan> listQrScan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> listQrScanString = [];
    for (var qrScan in listQrScan) {
      Map<String, dynamic> mapQrScan = qrScan.toMap();
      String mapString = jsonEncode(mapQrScan);
      listQrScanString.add(mapString);
    }
    await prefs.setStringList('listQrScan', listQrScanString);
  }

  Future<List<QrScan>> obtenerQrScanStorageList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listString = prefs.getStringList('listQrScan') ?? [];

    List<QrScan> listQrScan = [];
    for (var itemString in listString) {
      Map<String, dynamic> mapQrScan = jsonDecode(itemString);
      listQrScan.add(QrScan.fromStorage(mapQrScan));
    }
    return listQrScan;
  }

  eliminarQrScanStorageList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('listQrScan');
  }

  //PDF DOCS STORAGE

  Future agregarPdfStorageList(List<PDFModel> listPdfModel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> listPdfString = [];
    for (var pdfModel in listPdfModel) {
      Map<String, dynamic> mapPdf = pdfModel.toMap();
      String mapString = jsonEncode(mapPdf);
      listPdfString.add(mapString);
    }
    await prefs.setStringList('listPdf', listPdfString);
  }

  Future<List<PDFModel>> obtenerPdfStorageList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> listString = prefs.getStringList('listPdf') ?? [];

    List<PDFModel> listPdf = [];
    for (var itemString in listString) {
      Map<String, dynamic> mapPdf = jsonDecode(itemString);
      mapPdf['date'] = DateTime.parse(mapPdf['date']);
      listPdf.add(PDFModel.fromStorage(mapPdf));
    }
    return listPdf;
  }

  eliminarPdf() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('listPdf');
  }
}
