import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:norkik_app/models/privacidad_model.dart';

import 'apariencia_model.dart';

class UserModel {
  String idUsuario;
  String nombre;
  String apellido;
  String apodo;
  String whatsapp;
  String email;
  String password;
  String imgUrl;

  PrivacidadModel privacidad;
  AparienciaModel apariencia;

  static const String collectionId = 'Usuario';
  UserModel(
      {required this.idUsuario,
      required this.nombre,
      required this.apellido,
      required this.apodo,
      required this.whatsapp,
      required this.email,
      required this.password,
      required this.imgUrl,
      required this.apariencia,
      required this.privacidad});

  factory UserModel.fromFireStore(Map<String, dynamic> usuario) {
    return UserModel(
        idUsuario: usuario['UID'],
        nombre: usuario['Nombre'],
        apellido: usuario['Apellido'],
        apodo: usuario['Apodo'],
        whatsapp: usuario['WhatsApp'],
        email: usuario['Email'],
        password: usuario['Password'],
        imgUrl: usuario['Imagen'],
        apariencia: AparienciaModel.fromFireStore(usuario['Apariencia']),
        privacidad: PrivacidadModel.fromFireStore(usuario['Privacidad']));
  }

  Map<String, dynamic> toMap(
          DocumentReference<Map<String, dynamic>> privacidadRef,
          DocumentReference<Map<String, dynamic>> aparienciaRef) =>
      {
        'UID': idUsuario,
        'Nombre': nombre,
        'Apellido': apellido,
        'Apodo': apodo,
        'WhatsApp': whatsapp,
        'Email': email,
        'Password': password,
        'Imagen': imgUrl,
        'Privacidad': privacidadRef,
        'Apariencia': aparienciaRef,
      };

  factory UserModel.userModelNoData() {
    return UserModel(
        idUsuario: 'no-user',
        nombre: 'no-nombre',
        apellido: 'no-apellido',
        apodo: 'no-apodo',
        whatsapp: 'no-whatsapp',
        email: 'no-email',
        password: 'no-password',
        imgUrl: 'no-img',
        apariencia: AparienciaModel.aparienciaNoData(),
        privacidad: PrivacidadModel.privacidadNoData());
  }
}
