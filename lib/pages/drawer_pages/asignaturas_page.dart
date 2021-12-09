import 'package:flutter/material.dart';
import 'package:norkik_app/widget/charts_lineal.dart';

class AsignaturasPage extends StatelessWidget {
  const AsignaturasPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asignaturas page'),
      ),
      body: ChartsLineal(),
    );
  }
}
