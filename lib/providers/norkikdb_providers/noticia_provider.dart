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

  Future<List<NoticiaModel>> getNoticias() async {
    QuerySnapshot querySnapshot =
        await noticiaRef.orderBy('Fecha', descending: true).get();
    return querySnapshot.docs.map((elementNoticia) {
      Map<String, dynamic> noticiaMap =
          elementNoticia.data() as Map<String, dynamic>;
      noticiaMap.addAll({'idNoticia': elementNoticia.id});
      return NoticiaModel.fromFireStore(noticiaMap);
    }).toList();
  }
}
