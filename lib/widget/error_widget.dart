import 'package:flutter/material.dart';

class ErrorWidgetNorkik extends StatelessWidget {
  const ErrorWidgetNorkik({Key? key}) : super(key: key);

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
