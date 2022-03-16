import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:norkik_app/models/clases_model.dart';

class ClasesProvider {
  CollectionReference clasesRef =
      FirebaseFirestore.instance.collection(ClasesModel.collectionId);

  Future<DocumentReference> createClase(
      ClasesModel clase,
      DocumentReference<Map<String, dynamic>> docRefAsignatura,
      DocumentReference<Map<String, dynamic>> docRefHorario) async {
    return await clasesRef.add(clase.toMap(docRefAsignatura, docRefHorario));
  }

  deleteClase(String idClase) async {
    await clasesRef.doc(idClase).delete();
  }

  addClassMap(String idClass, Map<String, DateTime> mapTime) async {
    await clasesRef.doc(idClass).update({
      'FechaInicioFin': FieldValue.arrayUnion([mapTime])
    });
  }

  removeClase(String idClass, Map<String, DateTime> mapTime) async {
    await clasesRef.doc(idClass).update({
      'FechaInicioFin': FieldValue.arrayRemove([mapTime])
    });
  }

  Future<bool> existClass(String idClass) async {
    return (await clasesRef.doc(idClass).get()).exists;
  }

  Future<List<Future<ClasesModel>>> getClasesByHorario(
      DocumentReference<Map<String, dynamic>> docRefHorario) async {
    QuerySnapshot querySnapshot;
    querySnapshot =
        await clasesRef.where('Horario', isEqualTo: docRefHorario).get();

    return querySnapshot.docs.map((elementClases) async {
      Map<String, dynamic> clasesMap =
          elementClases.data() as Map<String, dynamic>;
      clasesMap.addAll({'idClase': elementClases.id});

      DocumentReference docRefAsignatura = clasesMap['Asignatura'];
      DocumentSnapshot docAsignatura = await docRefAsignatura.get();
      DocumentReference docRefHorario = clasesMap['Horario'];
      DocumentSnapshot docHorario = await docRefHorario.get();

      Map<String, dynamic> mapAsignatura =
          docAsignatura.data() as Map<String, dynamic>;
      mapAsignatura.addAll({'idAsignatura': docAsignatura.id});
      Map<String, dynamic> mapHorario =
          docHorario.data() as Map<String, dynamic>;
      mapHorario.addAll({'idHorario': docHorario.id});

      clasesMap['Asignatura'] = mapAsignatura;
      clasesMap['Horario'] = mapHorario;

      DocumentReference docRefDocente = mapAsignatura['Docente'];
      DocumentSnapshot docDocente = await docRefDocente.get();
      Map<String, dynamic> mapDocente =
          docDocente.data() as Map<String, dynamic>;
      mapDocente.addAll({'idDocente': docRefDocente.id});
      mapAsignatura['Docente'] = mapDocente;

      DocumentReference docRefUser = mapHorario['Usuario'];
      DocumentSnapshot docUser = await docRefUser.get();
      Map<String, dynamic> mapUser = docUser.data() as Map<String, dynamic>;
      mapUser.addAll({'UID': docRefUser.id});
      mapHorario['Usuario'] = mapUser;

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

      return ClasesModel.fromFireStore(clasesMap);
    }).toList();
  }

  Future<List<Future<ClasesModel>>> getClasesByHorarioAndAsignatura(
      DocumentReference<Map<String, dynamic>> docRefHorario,
      DocumentReference<Map<String, dynamic>> docRefAsignatura) async {
    QuerySnapshot querySnapshot;
    querySnapshot = await clasesRef
        .where('Horario', isEqualTo: docRefHorario)
        .where('Asignatura', isEqualTo: docRefAsignatura)
        .get();

    return querySnapshot.docs.map((elementClases) async {
      Map<String, dynamic> clasesMap =
          elementClases.data() as Map<String, dynamic>;
      clasesMap.addAll({'idClase': elementClases.id});

      DocumentReference docRefAsignatura = clasesMap['Asignatura'];
      DocumentSnapshot docAsignatura = await docRefAsignatura.get();
      DocumentReference docRefHorario = clasesMap['Horario'];
      DocumentSnapshot docHorario = await docRefHorario.get();

      Map<String, dynamic> mapAsignatura =
          docAsignatura.data() as Map<String, dynamic>;
      mapAsignatura.addAll({'idAsignatura': docAsignatura.id});
      Map<String, dynamic> mapHorario =
          docHorario.data() as Map<String, dynamic>;
      mapHorario.addAll({'idHorario': docHorario.id});

      clasesMap['Asignatura'] = mapAsignatura;
      clasesMap['Horario'] = mapHorario;

      DocumentReference docRefDocente = mapAsignatura['Docente'];
      DocumentSnapshot docDocente = await docRefDocente.get();
      Map<String, dynamic> mapDocente =
          docDocente.data() as Map<String, dynamic>;
      mapDocente.addAll({'idDocente': docRefDocente.id});
      mapAsignatura['Docente'] = mapDocente;

      DocumentReference docRefUser = mapHorario['Usuario'];
      DocumentSnapshot docUser = await docRefUser.get();
      Map<String, dynamic> mapUser = docUser.data() as Map<String, dynamic>;
      mapUser.addAll({'UID': docRefUser.id});
      mapHorario['Usuario'] = mapUser;

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

      return ClasesModel.fromFireStore(clasesMap);
    }).toList();
  }
}
