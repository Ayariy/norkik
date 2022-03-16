import 'package:flutter/material.dart';
import 'package:norkik_app/models/tarea_model.dart';
import 'package:intl/intl.dart';

class VerTareaPage extends StatelessWidget {
  TareaModel tareaModel;
  VerTareaPage({Key? key, required this.tareaModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarea (${tareaModel.nombre})'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                horizontalTitleGap: 5,
                minLeadingWidth: 5,
                minVerticalPadding: 18,
                leading: Icon(Icons.title),
                title: Text('Nombre de la tarea'),
                subtitle: Text(tareaModel.nombre),
                // Text(DateFormat.yMMMEd('es').format(widget.notaView.fecha)),
              ),
              Container(
                margin: const EdgeInsets.all(0),
                width: double.infinity,
                height: 0.5,
                color: Theme.of(context).textTheme.bodyText1!.color,
              ),
              ListTile(
                horizontalTitleGap: 5,
                minLeadingWidth: 5,
                minVerticalPadding: 18,
                leading: Icon(Icons.description),
                title: Text('Descripción'),
                subtitle: Text(tareaModel.descripcion),
                // subtitle: Text(widget.notaView.titulo),
              ),
              Container(
                margin: const EdgeInsets.all(0),
                width: double.infinity,
                height: 0.5,
                color: Theme.of(context).textTheme.bodyText1!.color,
              ),
              ListTile(
                horizontalTitleGap: 5,
                minLeadingWidth: 5,
                minVerticalPadding: 18,
                leading: Icon(Icons.date_range),
                title: Text('Fecha de la tarea'),
                subtitle:
                    Text(DateFormat.yMMMEd('es').format(tareaModel.fecha)),
              ),
              Container(
                margin: const EdgeInsets.all(0),
                width: double.infinity,
                height: 0.5,
                color: Theme.of(context).textTheme.bodyText1!.color,
              ),
              ListTile(
                horizontalTitleGap: 5,
                minLeadingWidth: 5,
                minVerticalPadding: 18,
                leading: Icon(Icons.class_),
                title: Text('La tarea corresponde a'),
                subtitle: Text(tareaModel.asignatura.nombre),
              ),
              Container(
                margin: const EdgeInsets.all(0),
                width: double.infinity,
                height: 0.5,
                color: Theme.of(context).textTheme.bodyText1!.color,
              ),
              ListTile(
                horizontalTitleGap: 5,
                minLeadingWidth: 5,
                minVerticalPadding: 18,
                leading: tareaModel.realizado
                    ? Icon(
                        Icons.verified,
                        color: Colors.green,
                      )
                    : DateTime.now().compareTo(tareaModel.fecha) >= 1
                        ? Icon(Icons.dangerous, color: Colors.red)
                        : Icon(Icons.dangerous, color: Colors.orange),
                title: Text('Estado de la tarea'),
                subtitle: Text(
                    '${tareaModel.realizado ? 'Realizado' : DateTime.now().compareTo(tareaModel.fecha) >= 1 ? 'Fuera de fecha límite, sin realizar' : 'Dentro de la fecha límite, sin realizar'}'),
              ),
              Container(
                margin: const EdgeInsets.all(0),
                width: double.infinity,
                height: 0.5,
                color: Theme.of(context).textTheme.bodyText1!.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
