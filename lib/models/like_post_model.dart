import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:norkik_app/models/post_model.dart';

class LikePostModel {
  String idLikePost;
  PostModel post;
  List<dynamic> userList;
  DateTime fecha;

  static const String collectionId = 'LikePost';

  LikePostModel(
      {required this.post,
      required this.userList,
      required this.fecha,
      required this.idLikePost});

  factory LikePostModel.fromFireStore(
    Map<String, dynamic> post,
  ) {
    return LikePostModel(
        idLikePost: post['idLikePost'],
        post: post['Post'],
        userList: post['UserList'],
        fecha: post['Fecha'].toDate());
  }

  factory LikePostModel.likePostNoData() {
    return LikePostModel(
        post: PostModel.postNoData(),
        userList: [],
        fecha: DateTime.now(),
        idLikePost: 'no-id');
  }

  Map<String, dynamic> toMap(DocumentReference<Map<String, dynamic>> postRef) =>
      {'Post': postRef, 'UserList': userList, 'Fecha': fecha};

  @override
  String toString() {
    return 'LikePostModel{Id: $idLikePost Post: $post, UserList:$userList, Fecha:$fecha}';
  }
}
