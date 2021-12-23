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
}
