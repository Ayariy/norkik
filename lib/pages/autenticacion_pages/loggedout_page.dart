import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:norkik_app/widget/elevated_button.dart';
import 'package:norkik_app/widget/outlined_button.dart';

class LoggedoutPage extends StatelessWidget {
  const LoggedoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    ruta: 'loggin',
                  ),
                  ElevatedButtonNorkik(
                    textButton: 'REGISTRARSE',
                    ruta: 'register',
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    ));
  }
}
