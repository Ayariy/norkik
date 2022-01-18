import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:norkik_app/models/user_model.dart';

class PostModel {
  String idPost;
  String titulo;
  String descripcion;
  String imagen;
  DateTime fecha;
  UserModel usuario;
  static const String collectionId = 'Publicacion';

  PostModel(
      {required this.idPost,
      required this.titulo,
      required this.descripcion,
      required this.imagen,
      required this.fecha,
      required this.usuario});

  factory PostModel.fromFireStore(
      Map<String, dynamic> post, UserModel currentUser) {
    return PostModel(
        idPost: post['idPost'],
        titulo: post['Titulo'],
        descripcion: post['Descripcion'],
        imagen: post['File'],
        fecha: post['Fecha'].toDate(),
        usuario: currentUser);
  }

  Map<String, dynamic> toMap(
          DocumentReference<Map<String, dynamic>> usuarioRef) =>
      {
        'Titulo': this.titulo,
        'Descripcion': this.descripcion,
        'File': this.imagen,
        'Fecha': this.fecha,
        'Usuario': usuarioRef
      };

  factory PostModel.postNoData() {
    DateTime now = DateTime.now();
    return PostModel(
        idPost: 'no-id',
        titulo: 'no-titulo',
        descripcion: 'no-descripcion',
        imagen: 'no-img',
        fecha: now,
        usuario: UserModel.userModelNoData());
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'Noticia{idNoticia: $idPost, titulo: $titulo, descripcion: $descripcion, imagen: $imagen, fecha: $fecha, userRef: ${usuario.idUsuario} }';
  }
}
