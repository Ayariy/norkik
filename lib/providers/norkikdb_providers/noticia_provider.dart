import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:norkik_app/models/noticia_model.dart';

class NoticiaProvider {
  CollectionReference noticiaRef =
      FirebaseFirestore.instance.collection(NoticiaModel.collectionId);

  Future<NoticiaModel> getNoticiaById(String uid) async {
    NoticiaModel noticia = NoticiaModel.noticiaNoData();
    DocumentSnapshot documentSnapshot = await noticiaRef.doc(uid).get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> noticiaMap =
          documentSnapshot.data() as Map<String, dynamic>;
      noticiaMap.addAll({'idNoticia': uid});
      noticia = NoticiaModel.fromFireStore(noticiaMap);
    }
    return noticia;
  }

  Future<List<NoticiaModel>> getNoticias(DateTime? from) async {
    QuerySnapshot querySnapshot;
    if (from != null) {
      querySnapshot = await noticiaRef
          .orderBy('Fecha', descending: true)
          .startAfter([from])
          .limit(10)
          .get();
    } else {
      querySnapshot =
          await noticiaRef.orderBy('Fecha', descending: true).limit(3).get();
    }

    return querySnapshot.docs.map((elementNoticia) {
      Map<String, dynamic> noticiaMap =
          elementNoticia.data() as Map<String, dynamic>;
      noticiaMap.addAll({'idNoticia': elementNoticia.id});
      return NoticiaModel.fromFireStore(noticiaMap);
    }).toList();
  }

  Future<List<NoticiaModel>> getNoticiasByTitle(String title) async {
    QuerySnapshot querySnapshot = await noticiaRef
        .where('Titulo', isGreaterThanOrEqualTo: title)
        .where('Titulo', isLessThanOrEqualTo: title + "\uf8ff")
        .get();

    return querySnapshot.docs.map((elementNoticia) {
      Map<String, dynamic> noticiaMap =
          elementNoticia.data() as Map<String, dynamic>;
      noticiaMap.addAll({'idNoticia': elementNoticia.id});
      return NoticiaModel.fromFireStore(noticiaMap);
    }).toList();
  }
}
