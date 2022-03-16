import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:norkik_app/models/like_post_model.dart';
import 'package:norkik_app/models/post_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/post_provider.dart';

class LikePostProvider {
  CollectionReference likePostRef =
      FirebaseFirestore.instance.collection(LikePostModel.collectionId);

  Future<void> createLikePost(LikePostModel postModel,
      DocumentReference<Map<String, dynamic>> postRef) async {
    await likePostRef.add(postModel.toMap(postRef));
  }

  Future<void> updateLikePost(LikePostModel postModel,
      DocumentReference<Map<String, dynamic>> postRef) async {
    DocumentSnapshot docRef = await likePostRef.doc(postModel.idLikePost).get();
    if (docRef.exists) {
      await likePostRef
          .doc(postModel.idLikePost)
          .update(postModel.toMap(postRef));
    }
  }

  // Future<List<LikePostModel>>
  Future<List<Future<LikePostModel>>> getLikePost(DateTime? from) async {
    PostProvider postProvider = PostProvider();
    QuerySnapshot querySnapshot;
    if (from != null) {
      querySnapshot = await likePostRef
          .orderBy('Fecha', descending: true)
          .startAfter([from])
          .limit(10)
          .get();
    } else {
      querySnapshot =
          await likePostRef.orderBy('Fecha', descending: true).limit(3).get();
    }

    return querySnapshot.docs.map((elementLikePost) async {
      Map<String, dynamic> likePostMap =
          elementLikePost.data() as Map<String, dynamic>;
      likePostMap.addAll({'idLikePost': elementLikePost.id});
      DocumentReference postRef = likePostMap['Post'];
      PostModel post = await postProvider.getPostById(postRef.id);
      likePostMap['Post'] = post;
      return LikePostModel.fromFireStore(likePostMap);
    }).toList();
  }

  Future<List<LikePostModel>> getLikePostByTitle(String title) async {
    PostProvider postProvider = PostProvider();
    List<Future<PostModel>> listPostFuture =
        await postProvider.getPostByTitle(title);
    List<LikePostModel> listLikePost = [];
    for (var post in listPostFuture) {
      PostModel postModel = await post;
      QuerySnapshot query = await likePostRef
          .where('Post',
              isEqualTo:
                  await postProvider.getPostReferenceById(postModel.idPost))
          .get();
      DocumentSnapshot documentSnapshot = query.docs.first;
      if (documentSnapshot.exists) {
        Map<String, dynamic> likePostMap =
            documentSnapshot.data() as Map<String, dynamic>;
        likePostMap.addAll({'idLikePost': documentSnapshot.id});
        likePostMap['Post'] = postModel;
        listLikePost.add(LikePostModel.fromFireStore(likePostMap));
      }
    }

    return listLikePost;
  }

  Future<LikePostModel> getLikePostById(String uidLikePost) async {
    PostProvider postProvider = PostProvider();
    DocumentSnapshot docRefLikePost = await likePostRef.doc(uidLikePost).get();
    Map<String, dynamic> likePostMap =
        docRefLikePost.data() as Map<String, dynamic>;
    likePostMap.addAll({'idLikePost': docRefLikePost.id});
    DocumentReference postRef = likePostMap['Post'];
    PostModel post = await postProvider.getPostById(postRef.id);
    likePostMap['Post'] = post;

    return LikePostModel.fromFireStore(likePostMap);
  }

  Future<LikePostModel> getLikePostByPostId(PostModel postModel) async {
    LikePostModel likePostModelReturn = LikePostModel.likePostNoData();
    PostProvider postProvider = PostProvider();
    QuerySnapshot querySnapshot = await likePostRef
        .where('Post',
            isEqualTo:
                (await postProvider.getPostReferenceById(postModel.idPost)))
        .get();

    DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
    if (documentSnapshot.exists) {
      Map<String, dynamic> likePostMap =
          documentSnapshot.data() as Map<String, dynamic>;

      likePostMap.addAll({'idLikePost': documentSnapshot.id});
      likePostMap['Post'] = postModel;
      likePostModelReturn = LikePostModel.fromFireStore(likePostMap);
      return likePostModelReturn;
    }

    return likePostModelReturn;
  }

  Future<void> deleteLikePostById(String idLikePost, String idPost) async {
    await likePostRef.doc(idLikePost).delete().then((value) {
      PostProvider postProvider = PostProvider();
      postProvider.deletePost(idPost);
    });
  }

  Future<void> deleteLikePostWithImgById(
      String idLikePost, String idPost, String urlImg) async {
    await likePostRef.doc(idLikePost).delete().then((value) {
      PostProvider postProvider = PostProvider();
      postProvider.deletePost(idPost);
      postProvider.deleteImgPost(urlImg);
    });
  }

  addFavoritePost(String uidLikePost, String idUser) async {
    await likePostRef.doc(uidLikePost).update({
      'UserList': FieldValue.arrayUnion([idUser])
    });
  }

  removeFavoritePost(String uidLikePost, String idUser) async {
    await likePostRef.doc(uidLikePost).update({
      'UserList': FieldValue.arrayRemove([idUser])
    });
  }

  Future<bool> existLikePost(String uidLikePost) async {
    return (await likePostRef.doc(uidLikePost).get()).exists;
  }

  Future<bool> isFavoritePost(String uidLikePost, String idUser) async {
    DocumentSnapshot documentSnapshotPost =
        await likePostRef.doc(uidLikePost).get();
    Map<String, dynamic> mapPost =
        documentSnapshotPost.data() as Map<String, dynamic>;
    List<String> listUserFavorite = List.from(mapPost['UserList']);

    bool isFavorite = listUserFavorite.contains(idUser);

    return isFavorite;
  }
}
