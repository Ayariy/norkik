import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:norkik_app/models/user_model.dart';

class HorarioModel {
  String idHorario;
  String nombre;
  String descripcion;
  DateTime fecha;
  UserModel usuario;
  bool activo;

  static const String collectionId = 'Horarios';

  HorarioModel(
      {required this.idHorario,
      required this.nombre,
      required this.descripcion,
      required this.fecha,
      required this.usuario,
      required this.activo});

  factory HorarioModel.fromFireStore(Map<String, dynamic> mapHorario) {
    return HorarioModel(
      idHorario: mapHorario['idHorario'],
      nombre: mapHorario['Nombre'],
      descripcion: mapHorario['Descripcion'],
      fecha: mapHorario['Fecha'].toDate(),
      activo: mapHorario['activo'],
      usuario: UserModel.fromFireStore(mapHorario['Usuario']),
    );
  }

  Map<String, dynamic> toMap(
          DocumentReference<Map<String, dynamic>> documentReferenceUser) =>
      {
        'Nombre': nombre,
        'Descripcion': descripcion,
        'Fecha': fecha,
        'activo': activo,
        'Usuario': documentReferenceUser
      };

  factory HorarioModel.horarioModelNoData() {
    return HorarioModel(
        idHorario: 'no-id',
        nombre: 'no-name',
        descripcion: 'no-description',
        fecha: DateTime.now(),
        activo: false,
        usuario: UserModel.userModelNoData());
  }

  @override
  String toString() {
    return 'HorarioModel{id: $idHorario, nombre: $nombre, descripción: $descripcion, fecha: $fecha, activo: $activo usuarioId: ${usuario.idUsuario} }';
  }
}
