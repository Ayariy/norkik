import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:norkik_app/models/tarea_model.dart';

class TareaProvider {
  CollectionReference tareaRef =
      FirebaseFirestore.instance.collection(TareaModel.collectionId);

  Future<DocumentReference> createTarea(
      TareaModel tarea,
      DocumentReference<Map<String, dynamic>> docRefAsignatura,
      DocumentReference<Map<String, dynamic>> docRefUser) async {
    return await tareaRef.add(tarea.toMap(docRefAsignatura, docRefUser));
  }

  Future<void> updateTarea(
      TareaModel tarea,
      DocumentReference<Map<String, dynamic>> userRef,
      DocumentReference<Map<String, dynamic>> asignaturaRef) async {
    DocumentSnapshot docRef = await tareaRef.doc(tarea.idTarea).get();
    if (docRef.exists) {
      await tareaRef
          .doc(tarea.idTarea)
          .update(tarea.toMap(asignaturaRef, userRef));
    }
  }

  Future<void> deleteTareaById(
    String tareaId,
  ) async {
    await tareaRef.doc(tareaId).delete();
  }

  Future<bool> existTarea(
    String tareaId,
  ) async {
    return (await tareaRef.doc(tareaId).get()).exists;
  }

  Future<List<Future<TareaModel>>> getTareas(
      DateTime? from,
      DocumentReference<Map<String, dynamic>> docRefAsignatura,
      DocumentReference<Map<String, dynamic>> docRefUser) async {
    QuerySnapshot querySnapshot;

    querySnapshot = await tareaRef
        .where('Usuario', isEqualTo: docRefUser)
        .where('Asignatura', isEqualTo: docRefAsignatura)
        .orderBy('Fecha', descending: true)
        .get();

    return querySnapshot.docs.map((elementTarea) async {
      Map<String, dynamic> tareaMap =
          elementTarea.data() as Map<String, dynamic>;
      tareaMap.addAll({'idTarea': elementTarea.id});

      DocumentReference docRefUser = tareaMap['Usuario'];
      DocumentSnapshot docUser = await docRefUser.get();

      DocumentReference docRefAsignatura = tareaMap['Asignatura'];
      DocumentSnapshot docAsignatura = await docRefAsignatura.get();

      Map<String, dynamic> mapAsignatura =
          docAsignatura.data() as Map<String, dynamic>;
      mapAsignatura.addAll({'idAsignatura': docAsignatura.id});

      Map<String, dynamic> mapUser = docUser.data() as Map<String, dynamic>;
      mapUser.addAll({'UID': docUser.id});

      tareaMap['Usuario'] = mapUser;
      tareaMap['Asignatura'] = mapAsignatura;

      DocumentReference docRefDocente = mapAsignatura['Docente'];
      DocumentSnapshot docDocente = await docRefDocente.get();
      Map<String, dynamic> mapDocente =
          docDocente.data() as Map<String, dynamic>;
      mapDocente.addAll({'idDocente': docRefDocente.id});
      mapAsignatura['Docente'] = mapDocente;

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

      return TareaModel.fromFireStore(tareaMap);
    }).toList();
  }

  Future<List<Future<TareaModel>>> getAllTareasByUser(
      DocumentReference<Map<String, dynamic>> docRefUser) async {
    QuerySnapshot querySnapshot;

    querySnapshot = await tareaRef
        .where('Usuario', isEqualTo: docRefUser)
        .orderBy('Fecha', descending: true)
        .get();

    return querySnapshot.docs.map((elementTarea) async {
      Map<String, dynamic> tareaMap =
          elementTarea.data() as Map<String, dynamic>;
      tareaMap.addAll({'idTarea': elementTarea.id});

      DocumentReference docRefUser = tareaMap['Usuario'];
      DocumentSnapshot docUser = await docRefUser.get();

      DocumentReference docRefAsignatura = tareaMap['Asignatura'];
      DocumentSnapshot docAsignatura = await docRefAsignatura.get();

      Map<String, dynamic> mapAsignatura =
          docAsignatura.data() as Map<String, dynamic>;
      mapAsignatura.addAll({'idAsignatura': docAsignatura.id});

      Map<String, dynamic> mapUser = docUser.data() as Map<String, dynamic>;
      mapUser.addAll({'UID': docUser.id});

      tareaMap['Usuario'] = mapUser;
      tareaMap['Asignatura'] = mapAsignatura;

      DocumentReference docRefDocente = mapAsignatura['Docente'];
      DocumentSnapshot docDocente = await docRefDocente.get();
      Map<String, dynamic> mapDocente =
          docDocente.data() as Map<String, dynamic>;
      mapDocente.addAll({'idDocente': docRefDocente.id});
      mapAsignatura['Docente'] = mapDocente;

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

      return TareaModel.fromFireStore(tareaMap);
    }).toList();
  }

  Future<List<Future<TareaModel>>> getTareasByTitle(
      String title,
      DocumentReference<Map<String, dynamic>> docRefAsignatura,
      DocumentReference<Map<String, dynamic>> docRefUser) async {
    QuerySnapshot querySnapshot = await tareaRef
        .where('Usuario', isEqualTo: docRefUser)
        .where('Asignatura', isEqualTo: docRefAsignatura)
        .where('Titulo', isGreaterThanOrEqualTo: title)
        .where('Titulo', isLessThanOrEqualTo: title + "\uf8ff")
        .get();

    return querySnapshot.docs.map((elementTarea) async {
      Map<String, dynamic> tareaMap =
          elementTarea.data() as Map<String, dynamic>;
      tareaMap.addAll({'idTarea': elementTarea.id});

      DocumentReference docRefUser = tareaMap['Usuario'];
      DocumentSnapshot docUser = await docRefUser.get();

      DocumentReference docRefAsignatura = tareaMap['Asignatura'];
      DocumentSnapshot docAsignatura = await docRefAsignatura.get();

      Map<String, dynamic> mapAsignatura =
          docAsignatura.data() as Map<String, dynamic>;
      mapAsignatura.addAll({'idAsignatura': docAsignatura.id});

      Map<String, dynamic> mapUser = docUser.data() as Map<String, dynamic>;
      mapUser.addAll({'UID': docUser.id});

      tareaMap['Usuario'] = mapUser;
      tareaMap['Asignatura'] = mapAsignatura;

      DocumentReference docRefDocente = mapAsignatura['Docente'];
      DocumentSnapshot docDocente = await docRefDocente.get();
      Map<String, dynamic> mapDocente =
          docDocente.data() as Map<String, dynamic>;
      mapDocente.addAll({'idDocente': docRefDocente.id});
      mapAsignatura['Docente'] = mapDocente;

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

      return TareaModel.fromFireStore(tareaMap);
    }).toList();
  }
}
