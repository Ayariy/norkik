import 'package:flutter/material.dart';
import 'package:norkik_app/models/recordatorio_model.dart';
import 'package:intl/intl.dart';

class VerRecordatorio extends StatelessWidget {
  // final RecordatorioModel recordatorioModel;
  const VerRecordatorio({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RecordatorioModel recordatorioModel =
        ModalRoute.of(context)!.settings.arguments as RecordatorioModel;
    return Scaffold(
      appBar: AppBar(
        title: Text(recordatorioModel.nombre),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.title_rounded),
                title: Text(recordatorioModel.nombre),
              ),
              Container(
                width: double.infinity,
                height: 0.5,
                color: Theme.of(context).textTheme.bodyText1!.color,
              ),
              ListTile(
                leading: Icon(Icons.date_range),
                title: Text(DateFormat("yyyy-MM-dd HH:mm:ss", 'es')
                    .format(recordatorioModel.fecha)),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10),
                width: double.infinity,
                height: 0.5,
                color: Theme.of(context).textTheme.bodyText1!.color,
              ),
              ListTile(
                leading: Icon(Icons.description_rounded),
                title: Text(recordatorioModel.descripcion),
              )
            ],
          ),
        ),
      ),
    );
  }
}
