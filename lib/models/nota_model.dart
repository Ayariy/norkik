import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:norkik_app/models/asignatura_model.dart';
import 'package:norkik_app/models/user_model.dart';

class NotaModel {
  String idNota;
  String titulo;
  String descripcion;
  String file;
  DateTime fecha;
  String categoria;
  AsignaturaModel asignatura;
  UserModel usuario;

  static const String collectionId = 'Notas';

  NotaModel(
      {required this.idNota,
      required this.titulo,
      required this.descripcion,
      required this.file,
      required this.fecha,
      required this.categoria,
      required this.asignatura,
      required this.usuario});

  factory NotaModel.fromFireStore(Map<String, dynamic> mapNota) {
    return NotaModel(
        idNota: mapNota['idNota'],
        titulo: mapNota['Titulo'],
        descripcion: mapNota['Descripcion'],
        file: mapNota['File'],
        fecha: mapNota['Fecha'].toDate(),
        categoria: mapNota['Categoria'],
        asignatura: AsignaturaModel.fromFireStore(mapNota['Asignatura']),
        usuario: UserModel.fromFireStore(mapNota['Usuario']));
  }

  Map<String, dynamic> toMap(
          DocumentReference<Map<String, dynamic>> documentReferenceAsignatura,
          DocumentReference<Map<String, dynamic>> documentReferenceUsuario) =>
      {
        'Titulo': titulo,
        'Descripcion': descripcion,
        'File': file,
        'Fecha': fecha,
        'Categoria': categoria,
        'Asignatura': documentReferenceAsignatura,
        'Usuario': documentReferenceUsuario
      };

  factory NotaModel.notaModelNoData() {
    return NotaModel(
        idNota: 'no-id',
        titulo: 'no-titulo',
        descripcion: 'no-descripcion',
        file: '',
        fecha: DateTime.now(),
        categoria: 'no-category',
        asignatura: AsignaturaModel.asignaturaModelNoData(),
        usuario: UserModel.userModelNoData());
  }

  @override
  String toString() {
    return 'NotaModel{id: $idNota, titulo: $titulo, descripción: $descripcion, file: $file, fecha: $fecha, categoria: $categoria, asignatura: $asignatura, usuario: ${usuario.idUsuario} }';
  }
}
