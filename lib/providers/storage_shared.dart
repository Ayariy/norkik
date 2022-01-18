import 'dart:convert';

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

  ///// RECORDATORIOS---------------
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
}
