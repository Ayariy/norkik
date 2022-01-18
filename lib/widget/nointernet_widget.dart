import 'package:flutter/material.dart';
import 'package:norkik_app/widget/elevated_button.dart';
import 'package:flutter_app_restart/flutter_app_restart.dart';

class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInImage(
                fit: BoxFit.cover,
                width: 300,
                placeholder: AssetImage('assets/loadingUno.gif'),
                image: AssetImage('assets/Norkik.png')),
            SizedBox(
              height: 20,
            ),
            ElevatedButtonNorkik(
              textButton: 'Reiniciar la app',
              functionButton: () async {
                final result = await FlutterRestart.restartApp();
                print(result);
              },
            ),
            SizedBox(
              height: 20,
            ),
            Text('Porfavor revise su conexión de red.')
          ],
        ),
      ),
    );
  }
}
