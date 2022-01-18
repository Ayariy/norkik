import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:norkik_app/models/docente_model.dart';

class AsignaturaModel {
  String idAsignatura;
  String nombre;
  String descripcion;
  String salon;
  String color;
  DocenteModel docente;

  AsignaturaModel(
      {required this.idAsignatura,
      required this.nombre,
      required this.descripcion,
      required this.salon,
      required this.color,
      required this.docente});

  factory AsignaturaModel.fromFireStore(Map<String, dynamic> mapAsignatura) {
    return AsignaturaModel(
        idAsignatura: mapAsignatura['idAsignatura'],
        nombre: mapAsignatura['Nombre'],
        descripcion: mapAsignatura['Descripcion'],
        salon: mapAsignatura['Salon'],
        color: mapAsignatura['Color'],
        docente: mapAsignatura['Docente']);
  }

  Map<String, dynamic> toMap(
          DocumentReference<Map<String, dynamic>> documentReferenceDocente) =>
      {
        'Nombre': nombre,
        'Descripcion': descripcion,
        'Salon': salon,
        'Color': color,
        'Docente': documentReferenceDocente
      };

  factory AsignaturaModel.asignaturaModelNoData() {
    return AsignaturaModel(
        idAsignatura: 'no-id',
        nombre: 'no-name',
        descripcion: 'no-descripcion',
        salon: 'no-salon',
        color: 'no-color',
        docente: DocenteModel.docenteModelNoData());
  }

  @override
  String toString() {
    return 'AsignaturaMode{idAsignatura: $idAsignatura, nomnbre: $nombre, descripcion: $descripcion, salon: $salon, color: $color, docente: $docente }';
  }
}
