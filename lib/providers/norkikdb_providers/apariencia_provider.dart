import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:norkik_app/models/apariencia_model.dart';

class AparienciaProvider {
  CollectionReference aparienciaRef =
      FirebaseFirestore.instance.collection(AparienciaModel.collectionId);

  Future<DocumentReference> createApariencia(
    AparienciaModel apariencia,
  ) async {
    return await aparienciaRef.add(apariencia.toMap());
  }

  Future<void> updateAparienciaById(
    AparienciaModel aparienciaModel,
  ) async {
    DocumentSnapshot docRef =
        await aparienciaRef.doc(aparienciaModel.idApariencia).get();
    if (docRef.exists) {
      await aparienciaRef
          .doc(aparienciaModel.idApariencia)
          .update(aparienciaModel.toMap());
    }
  }

  Future<DocumentReference<Map<String, dynamic>>?> getReferenceAparienciaById(
      String idApariencia) async {
    DocumentReference<Map<String, dynamic>>? docRef;
    DocumentSnapshot documentSnapshot =
        await aparienciaRef.doc(idApariencia).get();

    if (documentSnapshot.exists) {
      docRef =
          documentSnapshot.reference as DocumentReference<Map<String, dynamic>>;
    }

    return docRef;
  }
}
