import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:norkik_app/pages/autenticacion_pages/autenticacion_page.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  return runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _initApp = Firebase.initializeApp();
    return FutureBuilder(
        future: _initApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorWidget();
          } else if (snapshot.hasData) {
            return AutenticacionPage();
          } else
            return _CargandoWidget();
        });
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              FadeInImage(
                  width: 300,
                  fit: BoxFit.cover,
                  placeholder: AssetImage('assets/loadingUno.gif'),
                  image: AssetImage('assets/Norkik.png')),
              SizedBox(
                height: 20,
              ),
              Text(
                  'Lo sentimos, ocurrió un error inesperado, vuelve a intentarlo más tarde')
            ],
          ),
        ),
      ),
    );
  }
}

class _CargandoWidget extends StatelessWidget {
  const _CargandoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              FadeInImage(
                  fit: BoxFit.cover,
                  width: 300,
                  placeholder: AssetImage('assets/loadingUno.gif'),
                  image: AssetImage('assets/Norkik.png')),
              SizedBox(
                height: 20,
              ),
              CircularProgressIndicator(),
              SizedBox(
                height: 20,
              ),
              Text('Cargando...')
            ],
          ),
        ),
      ),
    );
  }
}
