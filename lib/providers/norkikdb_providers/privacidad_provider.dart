import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:norkik_app/models/privacidad_model.dart';

class PrivacidadProvider {
  CollectionReference privacidadRef =
      FirebaseFirestore.instance.collection(PrivacidadModel.collectionId);

  Future<DocumentReference> createPrivacidad(
    PrivacidadModel privacidad,
  ) async {
    return await privacidadRef.add(privacidad.toMap());
  }
}
