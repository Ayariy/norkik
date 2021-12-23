import 'package:flutter/material.dart';

class CargandoWidget extends StatelessWidget {
  const CargandoWidget({Key? key}) : super(key: key);

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
