import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:norkik_app/models/apariencia_model.dart';
import 'package:norkik_app/models/privacidad_model.dart';
import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/apariencia_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/privacidad_provider.dart';

class UserProvider with ChangeNotifier {
  CollectionReference usuariosRef =
      FirebaseFirestore.instance.collection(UserModel.collectionId);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  void setLoading(bool lodaing) {
    _isLoading = lodaing;
    notifyListeners();
  }

  UserModel _userGlobal;
  UserModel get userGlobal => _userGlobal;
  UserProvider(this._userGlobal);
  void setUserGlobal(UserModel user) {
    _userGlobal = user;
    notifyListeners();
  }

  void setUserGlobalWithoutNotify(UserModel user) {
    _userGlobal = user;
  }

  Future<void> createUser(UserModel usuario) async {
    setLoading(true);
    PrivacidadProvider privacidadProvider = PrivacidadProvider();
    AparienciaProvider aparienciaProvider = AparienciaProvider();

    DocumentReference<Map<String, dynamic>> privacidadRef =
        await privacidadProvider.createPrivacidad(usuario.privacidad)
            as DocumentReference<Map<String, dynamic>>;
    DocumentReference<Map<String, dynamic>> aparienciaRef =
        await aparienciaProvider.createApariencia(usuario.apariencia)
            as DocumentReference<Map<String, dynamic>>;

    await usuariosRef.add(usuario.toMap(privacidadRef, aparienciaRef));
    setLoading(false);
  }

  Future<UserModel> getUserById(String uid) async {
    setLoading(true);
    UserModel usuarioReturn = UserModel.userModelNoData();
    QuerySnapshot querySnapshot =
        await usuariosRef.where('UID', isEqualTo: uid).get();
    if (querySnapshot.size > 0) {
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

      if (documentSnapshot.exists) {
        Map<String, dynamic> mapUser =
            documentSnapshot.data() as Map<String, dynamic>;
        DocumentReference privacidadRef = mapUser['Privacidad'];
        DocumentReference aparienciaRef = mapUser['Apariencia'];

        DocumentSnapshot privacidadDoc = await privacidadRef.get();
        DocumentSnapshot aparienciaDoc = await aparienciaRef.get();

        Map<String, dynamic> mapPrivacidad =
            privacidadDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> mapApariencia =
            aparienciaDoc.data() as Map<String, dynamic>;

        mapPrivacidad.addAll({'idPrivacidad': privacidadDoc.id});
        mapApariencia.addAll({'idApariencia': aparienciaDoc.id});

        mapUser['Privacidad'] = mapPrivacidad;
        mapUser['Apariencia'] = mapApariencia;

        usuarioReturn = UserModel.fromFireStore(mapUser);
      }
    }
    setLoading(false);
    return usuarioReturn;
  }

  Future<UserModel> getUserByIdWithoutNotify(String uid) async {
    UserModel usuarioReturn = UserModel.userModelNoData();
    QuerySnapshot querySnapshot =
        await usuariosRef.where('UID', isEqualTo: uid).get();
    if (querySnapshot.size > 0) {
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

      if (documentSnapshot.exists) {
        Map<String, dynamic> mapUser =
            documentSnapshot.data() as Map<String, dynamic>;
        DocumentReference privacidadRef = mapUser['Privacidad'];
        DocumentReference aparienciaRef = mapUser['Apariencia'];

        DocumentSnapshot privacidadDoc = await privacidadRef.get();
        DocumentSnapshot aparienciaDoc = await aparienciaRef.get();

        Map<String, dynamic> mapPrivacidad =
            privacidadDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> mapApariencia =
            aparienciaDoc.data() as Map<String, dynamic>;

        mapPrivacidad.addAll({'idPrivacidad': privacidadDoc.id});
        mapApariencia.addAll({'idApariencia': aparienciaDoc.id});

        mapUser['Privacidad'] = mapPrivacidad;
        mapUser['Apariencia'] = mapApariencia;

        usuarioReturn = UserModel.fromFireStore(mapUser);
      }
    }
    return usuarioReturn;
  }
}
