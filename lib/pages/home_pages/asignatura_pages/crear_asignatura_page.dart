import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:norkik_app/models/asignatura_model.dart';

import 'package:norkik_app/models/docente_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/asignatura_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/docente_provider.dart';
import 'package:norkik_app/providers/storage_shared.dart';
import 'package:norkik_app/utils/alert_temp.dart';

class CrearAsignatura extends StatefulWidget {
  CrearAsignatura({Key? key}) : super(key: key);

  @override
  _CrearAsignaturaState createState() => _CrearAsignaturaState();
}

class _CrearAsignaturaState extends State<CrearAsignatura> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _docenteController = TextEditingController();
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _descripcionController = TextEditingController();
  TextEditingController _salonController = TextEditingController();

  StorageShared storageShared = StorageShared();
  DocenteProvider docenteProvider = DocenteProvider();
  AsignaturaProvider asignaturaProvider = AsignaturaProvider();

  List<DocenteModel> docenteList = [];
  DocenteModel? docenteSelect;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Asignatura'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: _formAsignatura(),
        ),
      ),
    );
  }

  _formAsignatura() {
    return Form(
      onWillPop: () async {
        return isLoading ? false : true;
      },
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            readOnly: true,
            enableInteractiveSelection: false,
            controller: _docenteController,
            validator: (value) => value!.isNotEmpty
                ? null
                : 'Selecciona el docente de la materia',
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person),
              hintText: 'Selecciona un docente',
            ),
            onTap: () {
              _showSelectDocente();
            },
          ),
          TextFormField(
            controller: _nombreController,
            validator: (value) =>
                value!.isNotEmpty ? null : 'Ingresa el nombre de la asignatura',
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.class_),
              hintText: 'Nombre de la asignatura',
            ),
          ),
          TextFormField(
            controller: _descripcionController,
            maxLines: null,
            validator: (value) => value!.isNotEmpty
                ? null
                : 'Ingresa una descripción de la asignatura',
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.description),
              hintText: 'Descripción de la asignatura',
            ),
          ),
          TextFormField(
            controller: _salonController,
            validator: (value) => value!.isNotEmpty
                ? null
                : 'Ingresa el salón o aula de la asignatura',
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.location_on),
              hintText: 'Aula de clases',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            width: double.infinity,
            height: 0.5,
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
          MaterialButton(
            minWidth: double.infinity,
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: isLoading
                  ? [const CircularProgressIndicator()]
                  : [
                      Icon(Icons.class_),
                      SizedBox(
                        width: 15,
                      ),
                      Text('Crear Asignatura'),
                    ],
            ),
            textColor: Theme.of(context).appBarTheme.foregroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onPressed: isLoading
                ? null
                : () async {
                    if (_formKey.currentState!.validate() &&
                        docenteSelect != null) {
                      setState(() {
                        isLoading = true;
                      });
                      DocumentReference<Map<String, dynamic>>? docRefDocente =
                          await docenteProvider.getReferenceDocenteById(
                              docenteSelect!.idDocente);

                      if (docRefDocente != null) {
                        asignaturaProvider.createAsignatura(
                            AsignaturaModel(
                                idAsignatura: 'no-id',
                                nombre: _nombreController.text,
                                descripcion: _descripcionController.text,
                                salon: _salonController.text,
                                docente: DocenteModel.docenteModelNoData()),
                            docRefDocente);
                      } else {
                        getAlert(context, 'Error en la ejecución',
                            'No se pudo completar su petición, inténtalo más tarde');
                      }
                      setState(() {
                        Navigator.pop(context);
                        isLoading = false;
                      });
                    }
                  },
          )
        ],
      ),
    );
  }

  _showSelectDocente() async {
    await _getDocentes();
    List<Widget> docenteListWidgets = [];
    for (var item in docenteList) {
      docenteListWidgets.add(ListTile(
        title: Text(item.nombre + " " + item.apellido),
        leading: Icon(Icons.person),
        subtitle: Text(item.email),
        onTap: () {
          setState(() {
            _docenteController.text = item.nombre + " " + item.apellido;
          });
          docenteSelect = item;
          Navigator.pop(context);
        },
      ));
    }
    showDialog(
        useSafeArea: false,
        context: context,
        builder: (dialogContext) {
          return SimpleDialog(
            // contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text('Docente a selecionar'),
            children: [
              ListTile(
                leading: Icon(Icons.add),
                trailing: Icon(Icons.class_),
                title: Text('Crear Docente'),
                onTap: () {
                  Navigator.pushNamed(context, 'crearDocente')
                      .then((value) => Navigator.pop(context));
                },
              ),
              Container(
                width: double.infinity,
                height: 0.5,
                color: Theme.of(context).textTheme.bodyText1!.color,
              ),
              SingleChildScrollView(
                child: Column(
                  children: docenteListWidgets,
                ),
              )
            ],
          );
        });
  }

  _getDocentes() async {
    setState(() {
      isLoading = true;
    });
    // docenteList.clear();
    DocenteProvider docenteProvider = DocenteProvider();
    docenteList = await docenteProvider.getDocentes();

    setState(() {
      isLoading = false;
    });
  }
}
