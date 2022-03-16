import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:norkik_app/models/docente_model.dart';

class DocenteProvider {
  CollectionReference docenteRef =
      FirebaseFirestore.instance.collection(DocenteModel.collectionId);

  Future<DocumentReference> createDocente(
    DocenteModel docente,
  ) async {
    return await docenteRef.add(docente.toMap());
  }

  Future<DocumentReference<Map<String, dynamic>>?> getReferenceDocenteById(
      String idDocente) async {
    DocumentReference<Map<String, dynamic>>? docRef;
    DocumentSnapshot documentSnapshot = await docenteRef.doc(idDocente).get();

    if (documentSnapshot.exists) {
      docRef =
          documentSnapshot.reference as DocumentReference<Map<String, dynamic>>;
    }

    return docRef;
  }

  Future<DocenteModel> getDocenteById(String idDocente) async {
    DocenteModel docente = DocenteModel.docenteModelNoData();
    DocumentSnapshot documentSnapshot = await docenteRef.doc(idDocente).get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> docenteMap =
          documentSnapshot.data() as Map<String, dynamic>;
      docenteMap.addAll({'idDocente': idDocente});
      docente = DocenteModel.fromFireStore(docenteMap);
    }
    return docente;
  }

  Future<List<DocenteModel>> getDocentes() async {
    QuerySnapshot querySnapshot;
    querySnapshot = await docenteRef.orderBy('Nombre', descending: true).get();
    return querySnapshot.docs.map((elementDocente) {
      Map<String, dynamic> docenteMap =
          elementDocente.data() as Map<String, dynamic>;
      docenteMap.addAll({'idDocente': elementDocente.id});
      return DocenteModel.fromFireStore(docenteMap);
    }).toList();
  }

  Future<void> updateDocente(DocenteModel docenteModel) async {
    DocumentSnapshot docRef =
        await docenteRef.doc(docenteModel.idDocente).get();
    if (docRef.exists) {
      await docenteRef.doc(docenteModel.idDocente).update(docenteModel.toMap());
    }
  }

  Future<void> deleteDocenteById(String idDocente) async {
    await docenteRef.doc(idDocente).delete();
  }
}
