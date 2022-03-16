import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:norkik_app/models/user_model.dart';

import 'asignatura_model.dart';

class TareaModel {
  String idTarea;
  String nombre;
  String descripcion;
  DateTime fecha;
  bool realizado;
  int idLocalNotification;
  AsignaturaModel asignatura;
  UserModel usuario;

  static const String collectionId = 'Tareas';
  TareaModel(
      {required this.idTarea,
      required this.nombre,
      required this.descripcion,
      required this.fecha,
      required this.realizado,
      required this.idLocalNotification,
      required this.asignatura,
      required this.usuario});

  factory TareaModel.fromFireStore(Map<String, dynamic> mapTarea) {
    return TareaModel(
        idTarea: mapTarea['idTarea'],
        nombre: mapTarea['Nombre'],
        descripcion: mapTarea['Descripcion'],
        fecha: mapTarea['Fecha'].toDate(),
        realizado: mapTarea['Realizado'],
        idLocalNotification: mapTarea['IdLocalNotification'],
        asignatura: AsignaturaModel.fromFireStore(mapTarea['Asignatura']),
        usuario: UserModel.fromFireStore(mapTarea['Usuario']));
  }

  Map<String, dynamic> toMap(
          DocumentReference<Map<String, dynamic>> documentReferenceAsignatura,
          DocumentReference<Map<String, dynamic>> documentReferenceUsuario) =>
      {
        'Nombre': nombre,
        'Descripcion': descripcion,
        'Fecha': fecha,
        'Realizado': realizado,
        'IdLocalNotification': idLocalNotification,
        'Asignatura': documentReferenceAsignatura,
        'Usuario': documentReferenceUsuario
      };

  factory TareaModel.tareaModelNoData() {
    return TareaModel(
        idTarea: 'no-id',
        nombre: 'no-name',
        descripcion: 'no-description',
        fecha: DateTime.now(),
        realizado: false,
        idLocalNotification: 0,
        asignatura: AsignaturaModel.asignaturaModelNoData(),
        usuario: UserModel.userModelNoData());
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'TareaModel{id: $idTarea, nombre: $nombre, descripcion: $descripcion, fecha: $fecha, realizado: $realizado, IDLN: $idLocalNotification, asignatura: $asignatura, usuario: ${usuario.idUsuario} }';
  }
}
