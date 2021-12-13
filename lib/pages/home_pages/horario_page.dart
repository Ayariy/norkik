import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HorarioPage extends StatelessWidget {
  HorarioPage({Key? key}) : super(key: key);

  // final CollectionReference data =
  //     FirebaseFirestore.instance.collection('Administrador');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Horario page'),
        ),
        body: Text('Mi página de horario')
        //  _getData(),
        );
  }

  _imprimir() {
    // print(
    //     'Probando------------------------------------------------------------');
    // print(data.get().then((value) => value.docs.forEach((element) {
    //       print('-----------------------------------------------');
    //       print(element['email']);
    //     })));
  }

  FutureBuilder<DocumentSnapshot> _getData() {
    return FutureBuilder<DocumentSnapshot>(
      // future: data.doc().get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Text(data.toString());
        }

        return Text("loading");
      },
    );
  }
}
