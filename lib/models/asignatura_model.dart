import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:norkik_app/models/docente_model.dart';

class AsignaturaModel {
  String idAsignatura;
  String nombre;
  String descripcion;
  String salon;

  DocenteModel docente;

  static const String collectionId = 'Asignaturas';

  AsignaturaModel(
      {required this.idAsignatura,
      required this.nombre,
      required this.descripcion,
      required this.salon,
      required this.docente});

  factory AsignaturaModel.fromFireStore(Map<String, dynamic> mapAsignatura) {
    return AsignaturaModel(
        idAsignatura: mapAsignatura['idAsignatura'],
        nombre: mapAsignatura['Nombre'],
        descripcion: mapAsignatura['Descripcion'],
        salon: mapAsignatura['Salon'],
        docente: DocenteModel.fromFireStore(mapAsignatura['Docente']));
  }

  Map<String, dynamic> toMap(
          DocumentReference<Map<String, dynamic>> documentReferenceDocente) =>
      {
        'Nombre': nombre,
        'Descripcion': descripcion,
        'Salon': salon,
        'Docente': documentReferenceDocente
      };

  factory AsignaturaModel.asignaturaModelNoData() {
    return AsignaturaModel(
        idAsignatura: 'no-id',
        nombre: 'no-name',
        descripcion: 'no-descripcion',
        salon: 'no-salon',
        docente: DocenteModel.docenteModelNoData());
  }

  @override
  String toString() {
    return 'AsignaturaMode{idAsignatura: $idAsignatura, nomnbre: $nombre, descripcion: $descripcion, salon: $salon, docente: $docente }';
  }
}
