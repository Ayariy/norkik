import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:norkik_app/models/asignatura_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/docente_provider.dart';

class AsignaturaProvider {
  CollectionReference asignaturaRef =
      FirebaseFirestore.instance.collection(AsignaturaModel.collectionId);

  Future<DocumentReference> createAsignatura(AsignaturaModel asignatura,
      DocumentReference<Map<String, dynamic>> docRefDocente) async {
    return await asignaturaRef.add(asignatura.toMap(docRefDocente));
  }

  Future<AsignaturaModel> getAsignaturaById(String idAsignatura) async {
    AsignaturaModel asignatura = AsignaturaModel.asignaturaModelNoData();
    DocumentSnapshot documentSnapshot =
        await asignaturaRef.doc(idAsignatura).get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> asignaturaMap =
          documentSnapshot.data() as Map<String, dynamic>;
      asignaturaMap.addAll({'idAsignatura': idAsignatura});

      DocumentReference docRefDocente = asignaturaMap['Docente'];
      DocumentSnapshot docDocente = await docRefDocente.get();

      Map<String, dynamic> mapDocente =
          docDocente.data() as Map<String, dynamic>;
      mapDocente.addAll({'idDocente': docDocente.id});
      asignaturaMap['Docente'] = mapDocente;
      asignatura = AsignaturaModel.fromFireStore(asignaturaMap);
    }
    return asignatura;
  }

  Future<DocumentReference<Map<String, dynamic>>?> getAsignaturaReferenceById(
      String idAsignatura) async {
    DocumentReference<Map<String, dynamic>>? docRef;

    DocumentSnapshot documentSnapshot =
        await asignaturaRef.doc(idAsignatura).get();
    if (documentSnapshot.exists) {
      docRef =
          documentSnapshot.reference as DocumentReference<Map<String, dynamic>>;
    }
    return docRef;
  }

  Future<List<Future<AsignaturaModel>>> getAsignaturas() async {
    QuerySnapshot querySnapshot;
    querySnapshot =
        await asignaturaRef.orderBy('Nombre', descending: true).get();
    return querySnapshot.docs.map((elementAsignatura) async {
      Map<String, dynamic> asignaturaMap =
          elementAsignatura.data() as Map<String, dynamic>;
      asignaturaMap.addAll({'idAsignatura': elementAsignatura.id});

      DocumentReference docRefDocente = asignaturaMap['Docente'];
      DocumentSnapshot docDocente = await docRefDocente.get();

      Map<String, dynamic> mapDocente =
          docDocente.data() as Map<String, dynamic>;
      mapDocente.addAll({'idDocente': docDocente.id});
      asignaturaMap['Docente'] = mapDocente;
      return AsignaturaModel.fromFireStore(asignaturaMap);
    }).toList();
  }

  Future<void> updateAsignatura(AsignaturaModel asignaturaModel) async {
    DocumentSnapshot docRef =
        await asignaturaRef.doc(asignaturaModel.idAsignatura).get();
    if (docRef.exists) {
      DocenteProvider docenteProvider = DocenteProvider();
      DocumentReference<Map<String, dynamic>>? docRefDocente =
          await docenteProvider
              .getReferenceDocenteById(asignaturaModel.docente.idDocente);
      if (docRefDocente != null) {
        await asignaturaRef
            .doc(asignaturaModel.idAsignatura)
            .update(asignaturaModel.toMap(docRefDocente));
      }
    }
  }
}
