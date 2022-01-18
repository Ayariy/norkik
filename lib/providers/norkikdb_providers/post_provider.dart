import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:norkik_app/models/post_model.dart';
import 'package:norkik_app/models/user_model.dart';

class PostProvider {
  CollectionReference postRef =
      FirebaseFirestore.instance.collection(PostModel.collectionId);
  String imgUrl = '';

  Future<DocumentReference<Map<String, dynamic>>> createPost(PostModel post,
      DocumentReference<Map<String, dynamic>> usuarioRef) async {
    return await postRef.add(post.toMap(usuarioRef))
        as DocumentReference<Map<String, dynamic>>;
  }

  Future updatePost(PostModel post,
      DocumentReference<Map<String, dynamic>> usuarioRef) async {
    DocumentSnapshot docRef = await postRef.doc(post.idPost).get();
    if (docRef.exists) {
      await postRef.doc(post.idPost).update(post.toMap(usuarioRef));
    }
  }

  Future<String> uploadImg(String userId, DateTime dateKey, File file) async {
    firebase_storage.Reference postImgRef = firebase_storage
        .FirebaseStorage.instance
        .ref('Usuarios')
        .child('Posts')
        .child(userId);

    final firebase_storage.UploadTask task =
        postImgRef.child(dateKey.toString() + '.jpg').putFile(file);

    imgUrl = await (await task).ref.getDownloadURL();

    task.snapshotEvents.listen((event) async {
      if (event.state == firebase_storage.TaskState.error) {
        await task.cancel();
      }
    });
    return imgUrl;
  }

  deleteImgPost(String urlImg) async {
    firebase_storage.Reference reference =
        firebase_storage.FirebaseStorage.instance.refFromURL(urlImg);
    await reference.delete();
  }

  Future<List<Future<PostModel>>> getPostByTitle(String title) async {
    QuerySnapshot querySnapshot = await postRef
        .where('Titulo', isGreaterThanOrEqualTo: title)
        .where('Titulo', isLessThanOrEqualTo: title + "\uf8ff")
        .get();

    return querySnapshot.docs.map((elementPost) async {
      Map<String, dynamic> postMap = elementPost.data() as Map<String, dynamic>;
      postMap.addAll({'idPost': elementPost.id});

      DocumentReference userRef = postMap['Usuario'];
      DocumentSnapshot userDoc = await userRef.get();
      Map<String, dynamic> mapUser = userDoc.data() as Map<String, dynamic>;

      DocumentReference privacidadRef = mapUser['Privacidad'];
      DocumentReference aparienciaRef = mapUser['Apariencia'];

      DocumentSnapshot privacidadDoc = await privacidadRef.get();
      DocumentSnapshot aparienciaDoc = await aparienciaRef.get();

      Map<String, dynamic> mapPrivacidad =
          privacidadDoc.data() as Map<String, dynamic>;
      Map<String, dynamic> mapApariencia =
          aparienciaDoc.data() as Map<String, dynamic>;

      mapPrivacidad.addAll({'idPrivacidad': privacidadDoc.id});
      mapApariencia.addAll({'idApariencia': aparienciaDoc.id});

      mapUser['Privacidad'] = mapPrivacidad;
      mapUser['Apariencia'] = mapApariencia;

      return PostModel.fromFireStore(postMap, UserModel.fromFireStore(mapUser));
    }).toList();
  }

  Future<PostModel> getPostById(String postId) async {
    PostModel post = PostModel.postNoData();
    DocumentSnapshot documentSnapshot = await postRef.doc(postId).get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> postMap =
          documentSnapshot.data() as Map<String, dynamic>;
      postMap.addAll({'idPost': postId});

      DocumentReference userRef = postMap['Usuario'];
      DocumentSnapshot userDoc = await userRef.get();
      Map<String, dynamic> mapUser = userDoc.data() as Map<String, dynamic>;

      DocumentReference privacidadRef = mapUser['Privacidad'];
      DocumentReference aparienciaRef = mapUser['Apariencia'];

      DocumentSnapshot privacidadDoc = await privacidadRef.get();
      DocumentSnapshot aparienciaDoc = await aparienciaRef.get();

      Map<String, dynamic> mapPrivacidad =
          privacidadDoc.data() as Map<String, dynamic>;
      Map<String, dynamic> mapApariencia =
          aparienciaDoc.data() as Map<String, dynamic>;

      mapPrivacidad.addAll({'idPrivacidad': privacidadDoc.id});
      mapApariencia.addAll({'idApariencia': aparienciaDoc.id});

      mapUser['Privacidad'] = mapPrivacidad;
      mapUser['Apariencia'] = mapApariencia;

      post = PostModel.fromFireStore(postMap, UserModel.fromFireStore(mapUser));
    }
    return post;
  }

  deletePost(String idPost) async {
    await postRef.doc(idPost).delete();
  }

  Future<DocumentReference<Map<String, dynamic>>?> getPostReferenceById(
      String postId) async {
    DocumentReference<Map<String, dynamic>>? docRef;
    DocumentSnapshot documentSnapshot = await postRef.doc(postId).get();
    if (documentSnapshot.exists) {
      docRef =
          documentSnapshot.reference as DocumentReference<Map<String, dynamic>>;
    }
    return docRef;
  }
}
