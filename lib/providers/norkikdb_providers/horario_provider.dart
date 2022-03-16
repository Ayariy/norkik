import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:norkik_app/models/clases_model.dart';
import 'package:norkik_app/models/horario_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/clases_provider.dart';

class HorarioProvider {
  CollectionReference horarioRef =
      FirebaseFirestore.instance.collection(HorarioModel.collectionId);

  Future<DocumentReference> createHorario(
    HorarioModel horario,
    DocumentReference<Map<String, dynamic>> docRefUser,
  ) async {
    return await horarioRef.add(horario.toMap(docRefUser));
  }

  Future<bool> existHorario(String idHorario) async {
    return (await horarioRef.doc(idHorario).get()).exists;
  }

  updateHorario(HorarioModel horario,
      DocumentReference<Map<String, dynamic>> userRef) async {
    DocumentSnapshot docRef = await horarioRef.doc(horario.idHorario).get();
    if (docRef.exists) {
      await horarioRef.doc(horario.idHorario).update(horario.toMap(userRef));
    }
  }

  Future deleteHorario(String idHorario,
      DocumentReference<Map<String, dynamic>> docRefHorario) async {
    var collection =
        FirebaseFirestore.instance.collection(ClasesModel.collectionId);
    var snapshot =
        await collection.where('Horario', isEqualTo: docRefHorario).get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    await horarioRef.doc(idHorario).delete();
  }

  Future<HorarioModel> getHorarioByActivo(
      bool activo, DocumentReference<Map<String, dynamic>> userRef) async {
    HorarioModel horario = HorarioModel.horarioModelNoData();
    QuerySnapshot query = await horarioRef
        .where('Usuario', isEqualTo: userRef)
        .where('activo', isEqualTo: activo)
        .get();

    DocumentSnapshot documentSnapshot = query.docs.first;
    if (documentSnapshot.exists) {
      Map<String, dynamic> horarioMap =
          documentSnapshot.data() as Map<String, dynamic>;
      horarioMap.addAll({'idHorario': documentSnapshot.id});

      DocumentReference docRefUser = horarioMap['Usuario'];
      DocumentSnapshot docUser = await docRefUser.get();

      Map<String, dynamic> mapUser = docUser.data() as Map<String, dynamic>;
      mapUser.addAll({'UID': docUser.id});
      horarioMap['Usuario'] = mapUser;

      DocumentReference docRefPrivacidad = mapUser['Privacidad'];
      DocumentSnapshot docPrivacidad = await docRefPrivacidad.get();
      Map<String, dynamic> mapPrivacidad =
          docPrivacidad.data() as Map<String, dynamic>;
      mapPrivacidad.addAll({'idPrivacidad': docRefPrivacidad.id});
      mapUser['Privacidad'] = mapPrivacidad;

      DocumentReference docRefApariencia = mapUser['Apariencia'];
      DocumentSnapshot docApariencia = await docRefApariencia.get();
      Map<String, dynamic> mapApariencia =
          docApariencia.data() as Map<String, dynamic>;
      mapApariencia.addAll({'idApariencia': docRefApariencia.id});
      mapUser['Apariencia'] = mapApariencia;

      horario = HorarioModel.fromFireStore(horarioMap);
    }
    return horario;
  }

  Future<HorarioModel> getHorarioById(String idHorario) async {
    HorarioModel horario = HorarioModel.horarioModelNoData();
    DocumentSnapshot documentSnapshot = await horarioRef.doc(idHorario).get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> horarioMap =
          documentSnapshot.data() as Map<String, dynamic>;
      horarioMap.addAll({'idHorario': idHorario});

      DocumentReference docRefUser = horarioMap['Usuario'];
      DocumentSnapshot docUser = await docRefUser.get();

      Map<String, dynamic> mapUser = docUser.data() as Map<String, dynamic>;
      mapUser.addAll({'UID': docUser.id});
      horarioMap['Usuario'] = mapUser;

      DocumentReference docRefPrivacidad = mapUser['Privacidad'];
      DocumentSnapshot docPrivacidad = await docRefPrivacidad.get();
      Map<String, dynamic> mapPrivacidad =
          docPrivacidad.data() as Map<String, dynamic>;
      mapPrivacidad.addAll({'idPrivacidad': docRefPrivacidad.id});
      mapUser['Privacidad'] = mapPrivacidad;

      DocumentReference docRefApariencia = mapUser['Apariencia'];
      DocumentSnapshot docApariencia = await docRefApariencia.get();
      Map<String, dynamic> mapApariencia =
          docApariencia.data() as Map<String, dynamic>;
      mapApariencia.addAll({'idApariencia': docRefApariencia.id});
      mapUser['Apariencia'] = mapApariencia;

      horario = HorarioModel.fromFireStore(horarioMap);
    }
    return horario;
  }

  Future<DocumentReference<Map<String, dynamic>>?> getHorarioReferenceById(
      String idHorario) async {
    DocumentReference<Map<String, dynamic>>? docRef;

    DocumentSnapshot documentSnapshot = await horarioRef.doc(idHorario).get();
    if (documentSnapshot.exists) {
      docRef =
          documentSnapshot.reference as DocumentReference<Map<String, dynamic>>;
    }
    return docRef;
  }

  Future<List<Future<HorarioModel>>> getHorarios(
      DocumentReference<Map<String, dynamic>> userRef) async {
    QuerySnapshot querySnapshot;
    querySnapshot = await horarioRef.where('Usuario', isEqualTo: userRef).get();
    return querySnapshot.docs.map((elementHorario) async {
      Map<String, dynamic> horarioMap =
          elementHorario.data() as Map<String, dynamic>;
      horarioMap.addAll({'idHorario': elementHorario.id});

      DocumentReference docRefUser = horarioMap['Usuario'];
      DocumentSnapshot docUser = await docRefUser.get();

      Map<String, dynamic> mapUser = docUser.data() as Map<String, dynamic>;
      mapUser.addAll({'UID': docUser.id});
      horarioMap['Usuario'] = mapUser;

      DocumentReference docRefPrivacidad = mapUser['Privacidad'];
      DocumentSnapshot docPrivacidad = await docRefPrivacidad.get();
      Map<String, dynamic> mapPrivacidad =
          docPrivacidad.data() as Map<String, dynamic>;
      mapPrivacidad.addAll({'idPrivacidad': docRefPrivacidad.id});
      mapUser['Privacidad'] = mapPrivacidad;

      DocumentReference docRefApariencia = mapUser['Apariencia'];
      DocumentSnapshot docApariencia = await docRefApariencia.get();
      Map<String, dynamic> mapApariencia =
          docApariencia.data() as Map<String, dynamic>;
      mapApariencia.addAll({'idApariencia': docRefApariencia.id});
      mapUser['Apariencia'] = mapApariencia;

      return HorarioModel.fromFireStore(horarioMap);
    }).toList();
  }
}
