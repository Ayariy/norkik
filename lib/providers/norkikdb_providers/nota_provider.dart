import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:norkik_app/models/nota_model.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class NotaProvider {
  CollectionReference notaRef =
      FirebaseFirestore.instance.collection(NotaModel.collectionId);

  Future<DocumentReference> createNota(
      NotaModel nota,
      DocumentReference<Map<String, dynamic>> docRefAsignatura,
      DocumentReference<Map<String, dynamic>> docRefUser) async {
    return await notaRef.add(nota.toMap(docRefAsignatura, docRefUser));
  }

  Future<String> uploadFile(
      String userId, String nameFile, File file, String nameDirectory) async {
    firebase_storage.Reference postFileRef = firebase_storage
        .FirebaseStorage.instance
        .ref('Usuarios')
        .child(nameDirectory)
        .child(userId);

    final firebase_storage.UploadTask task =
        postFileRef.child(nameFile).putFile(file);

    String fileUrl = '';
    fileUrl = await (await task).ref.getDownloadURL();

    task.snapshotEvents.listen((event) async {
      if (event.state == firebase_storage.TaskState.error) {
        await task.cancel();
      }
    });
    return fileUrl;
  }

  Future<void> updateNotaTexto(
      NotaModel nota,
      DocumentReference<Map<String, dynamic>> userRef,
      DocumentReference<Map<String, dynamic>> asignaturaRef) async {
    DocumentSnapshot docRef = await notaRef.doc(nota.idNota).get();
    if (docRef.exists) {
      await notaRef.doc(nota.idNota).update(nota.toMap(asignaturaRef, userRef));
    }
  }

  deleteFilePost(String urlFile) async {
    firebase_storage.Reference reference =
        firebase_storage.FirebaseStorage.instance.refFromURL(urlFile);
    await reference.delete();
  }

  Future<void> deleteNotaTextoById(
    String notaId,
  ) async {
    await notaRef.doc(notaId).delete();
  }

  Future<bool> existNota(
    String notaId,
  ) async {
    return (await notaRef.doc(notaId).get()).exists;
  }

  Future<List<Future<NotaModel>>> getNotasByTitle(
      String title,
      String categoria,
      DocumentReference<Map<String, dynamic>> docRefAsignatura,
      DocumentReference<Map<String, dynamic>> docRefUser) async {
    QuerySnapshot querySnapshot = await notaRef
        .where('Categoria', isEqualTo: categoria)
        .where('Usuario', isEqualTo: docRefUser)
        .where('Asignatura', isEqualTo: docRefAsignatura)
        .where('Titulo', isGreaterThanOrEqualTo: title)
        .where('Titulo', isLessThanOrEqualTo: title + "\uf8ff")
        .get();

    return querySnapshot.docs.map((elementNota) async {
      Map<String, dynamic> notaMap = elementNota.data() as Map<String, dynamic>;
      notaMap.addAll({'idNota': elementNota.id});

      DocumentReference docRefUser = notaMap['Usuario'];
      DocumentSnapshot docUser = await docRefUser.get();

      DocumentReference docRefAsignatura = notaMap['Asignatura'];
      DocumentSnapshot docAsignatura = await docRefAsignatura.get();

      Map<String, dynamic> mapAsignatura =
          docAsignatura.data() as Map<String, dynamic>;
      mapAsignatura.addAll({'idAsignatura': docAsignatura.id});

      Map<String, dynamic> mapUser = docUser.data() as Map<String, dynamic>;
      mapUser.addAll({'UID': docUser.id});

      notaMap['Usuario'] = mapUser;
      notaMap['Asignatura'] = mapAsignatura;

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

      return NotaModel.fromFireStore(notaMap);
    }).toList();
  }

  Future<List<Future<NotaModel>>> getNotas(
      DateTime? from,
      String categoria,
      DocumentReference<Map<String, dynamic>> docRefAsignatura,
      DocumentReference<Map<String, dynamic>> docRefUser) async {
    QuerySnapshot querySnapshot;
    if (from != null) {
      querySnapshot = await notaRef
          .where('Categoria', isEqualTo: categoria)
          .where('Usuario', isEqualTo: docRefUser)
          .where('Asignatura', isEqualTo: docRefAsignatura)
          .orderBy('Fecha', descending: true)
          .startAfter([from])
          .limit(10)
          .get();
    } else {
      querySnapshot = await notaRef
          .where('Categoria', isEqualTo: categoria)
          .where('Usuario', isEqualTo: docRefUser)
          .where('Asignatura', isEqualTo: docRefAsignatura)
          .orderBy('Fecha', descending: true)
          .limit(5)
          .get();
    }

    return querySnapshot.docs.map((elementNota) async {
      Map<String, dynamic> notaMap = elementNota.data() as Map<String, dynamic>;
      notaMap.addAll({'idNota': elementNota.id});

      DocumentReference docRefUser = notaMap['Usuario'];
      DocumentSnapshot docUser = await docRefUser.get();

      DocumentReference docRefAsignatura = notaMap['Asignatura'];
      DocumentSnapshot docAsignatura = await docRefAsignatura.get();

      Map<String, dynamic> mapAsignatura =
          docAsignatura.data() as Map<String, dynamic>;
      mapAsignatura.addAll({'idAsignatura': docAsignatura.id});

      Map<String, dynamic> mapUser = docUser.data() as Map<String, dynamic>;
      mapUser.addAll({'UID': docUser.id});

      notaMap['Usuario'] = mapUser;
      notaMap['Asignatura'] = mapAsignatura;

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

      return NotaModel.fromFireStore(notaMap);
    }).toList();
  }
}
