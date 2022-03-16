import 'package:flutter/material.dart';
import 'package:norkik_app/models/nota_model.dart';
import 'package:intl/intl.dart';

class VerTextoPage extends StatefulWidget {
  NotaModel notaView;
  VerTextoPage({Key? key, required this.notaView}) : super(key: key);

  @override
  State<VerTextoPage> createState() => _VerTextoPageState();
}

class _VerTextoPageState extends State<VerTextoPage> {
  // NotaModel? notaModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      // notaModel = ModalRoute.of(context)!.settings.arguments as NotaModel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                horizontalTitleGap: 5,
                minLeadingWidth: 5,
                minVerticalPadding: 18,
                leading: Icon(Icons.title),
                title: Text(widget.notaView.titulo),
                subtitle:
                    Text(DateFormat.yMMMEd('es').format(widget.notaView.fecha)),
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
                title: Text(widget.notaView.descripcion),
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
                leading: Icon(Icons.label),
                title: Text('Categoría'),
                subtitle: Text(widget.notaView.categoria),
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
                title: Text(widget.notaView.asignatura.nombre),
                subtitle: Text('Msc.' +
                    widget.notaView.asignatura.docente.nombre +
                    " " +
                    widget.notaView.asignatura.docente.apellido),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
