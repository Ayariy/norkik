import 'package:flutter/material.dart';

class HorarioSettingPage extends StatefulWidget {
  HorarioSettingPage({Key? key}) : super(key: key);

  @override
  State<HorarioSettingPage> createState() => _HorarioSettingPageState();
}

class _HorarioSettingPageState extends State<HorarioSettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Horario'),
      ),
    );
  }
}
