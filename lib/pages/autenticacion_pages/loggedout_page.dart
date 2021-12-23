import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:norkik_app/pages/autenticacion_pages/loggin_page.dart';
import 'package:norkik_app/pages/autenticacion_pages/register_page.dart';

import 'package:norkik_app/widget/elevated_button.dart';
import 'package:norkik_app/widget/outlined_button.dart';

class LoggedoutPage extends StatefulWidget {
  const LoggedoutPage({Key? key}) : super(key: key);

  @override
  State<LoggedoutPage> createState() => _LoggedoutPageState();
}

class _LoggedoutPageState extends State<LoggedoutPage> {
  Future probando() async {
    // UserProvider userProvider = Provider.of<UserProvider>(context);
    // UserModel user =
    //     await userProvider.getUserById('HZhvqu0i84XY8Ykb2qMilKUdTCL2');
    // print(user.apariencia.tema);
    // final CollectionReference data =
    //     FirebaseFirestore.instance.collection('Usuario');
    // QuerySnapshot querySnapshot = await data.get();

    // print(querySnapshot.docs.map((e) async {
    //   // Map<String, dynamic> listMapUser = e.data() as Map<String, dynamic>;
    //   // listMapUser.addAll({"idUsuario": e.id});
    //   // DocumentReference docref = listMapUser['Privacidad'];
    //   // DocumentSnapshot doc = await docref.get();
    //   // Map<String, dynamic> mapPrivacidad = doc.data() as Map<String, dynamic>;
    //   // mapPrivacidad.addAll({"idPrivacidad": doc.id});

    //   // listMapUser['Privacidad'] = mapPrivacidad;

    //   // UserModel user = UserModel.fromFireStore(listMapUser);
    //   // print(e.data().toString() + "----------------------------");

    //   return e.data();
    // }));
  }

  @override
  Widget build(BuildContext context) {
    probando();
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: Stack(
      children: [
        FittedBox(
          child: FadeInImage(
            fit: BoxFit.cover,
            width: size.width,
            height: size.height,
            placeholder: AssetImage('assets/loadingDos.gif'),
            image: AssetImage('assets/UPEC.jpg'),
          ),
        ),
        Container(
            height: size.height,
            alignment: Alignment.topCenter,
            // margin: EdgeInsets.only(top: size.height * 0.10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.white.withAlpha(0),
                  Colors.black12,
                  Colors.black26,
                  // Colors.black38,
                  // Colors.black45,
                  Colors.black54,
                  Colors.black87
                ],
              ),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, 'home');
              },
              child: FadeInImage(
                  width: size.height * 0.37,
                  height: size.height * 0.37,
                  fit: BoxFit.contain,
                  placeholder: AssetImage('assets/loadingUno.gif'),
                  image: AssetImage('assets/Norkik.png')),
            )),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              color: Theme.of(context).cardColor,
              height: size.height * 0.15,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButtonNorkik(
                    textButton: 'INICIAR SESIÓN',
                    functionButton: () {
                      _showModalWidget(LogginPage());
                      // Navigator.pushNamed(context, 'loggin');
                    },
                  ),
                  ElevatedButtonNorkik(
                      textButton: 'REGISTRARSE',
                      functionButton: () {
                        _showModalWidget(RegisterPage());
                        // Navigator.pushNamed(context, 'loggin');
                      })
                ],
              ),
            ),
          ],
        ),
      ],
    ));
  }

  void _showModalWidget(Widget widgetShow) {
    showModalBottomSheet(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return widgetShow;
        });
  }
}
