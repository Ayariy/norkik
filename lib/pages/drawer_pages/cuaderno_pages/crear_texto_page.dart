import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:norkik_app/models/asignatura_model.dart';
import 'package:norkik_app/models/nota_model.dart';
import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/asignatura_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/nota_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:provider/provider.dart';

class CrearNotaTexto extends StatefulWidget {
  CrearNotaTexto({Key? key}) : super(key: key);

  @override
  State<CrearNotaTexto> createState() => _CrearNotaTextoState();
}

class _CrearNotaTextoState extends State<CrearNotaTexto> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descripcionController = TextEditingController();

  NotaProvider notaProvider = new NotaProvider();
  AsignaturaProvider asignaturaProvider = AsignaturaProvider();
  AsignaturaModel? asignatura;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    asignatura = ModalRoute.of(context)!.settings.arguments as AsignaturaModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear nota de texto'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: asignatura == null
              ? const Center(
                  child: Text('Ocurrió un problema, inténtalo más tarde'),
                )
              : _formNotaTexto(),
        ),
      ),
    );
  }

  _formNotaTexto() {
    return Form(
      onWillPop: () async {
        return isLoading ? false : true;
      },
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _tituloController,
            validator: (value) =>
                value!.isNotEmpty ? null : 'Ingresa el título de la nota',
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.class_),
              hintText: 'Título de la nota',
            ),
          ),
          TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: _descripcionController,
            validator: (value) =>
                value!.isNotEmpty ? null : 'Ingresa una descripción de la nota',
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.description),
              hintText: 'Descripción de la nota',
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          ListTile(
            leading: Icon(Icons.class_),
            title: Text(asignatura!.nombre),
            subtitle: Text('Msc. ' +
                asignatura!.docente.nombre +
                " " +
                asignatura!.docente.apellido),
          ),
          Container(
            margin: const EdgeInsets.all(0),
            width: double.infinity,
            height: 0.5,
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
          ListTile(
            leading: Icon(Icons.text_fields),
            title: Text('Categoría'),
            subtitle: Text('Texto'),
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
                        Icon(Icons.note_add_rounded),
                        SizedBox(
                          width: 15,
                        ),
                        Text('Crear Nota de texto'),
                      ],
              ),
              textColor: Theme.of(context).appBarTheme.foregroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });
                        if (asignatura != null) {
                          UserProvider userProvider =
                              Provider.of<UserProvider>(context, listen: false);
                          DocumentReference<Map<String, dynamic>> userRef =
                              (await userProvider.getUserReferenceById(
                                  userProvider.userGlobal.idUsuario))!;
                          DocumentReference<Map<String, dynamic>>
                              asignaturaRef = (await asignaturaProvider
                                  .getAsignaturaReferenceById(
                                      asignatura!.idAsignatura))!;

                          NotaModel nota = NotaModel(
                              idNota: 'no-id',
                              titulo: _tituloController.text.toLowerCase(),
                              descripcion: _descripcionController.text,
                              file: '',
                              fecha: DateTime.now(),
                              categoria: 'Texto',
                              asignatura:
                                  AsignaturaModel.asignaturaModelNoData(),
                              usuario: UserModel.userModelNoData());
                          notaProvider.createNota(nota, asignaturaRef, userRef);
                          Navigator.pop(context);
                        } else {
                          getAlert(context, 'Error',
                              'Ocurrió un error inesperado, inténtalo más tarde');
                        }

                        setState(() {
                          isLoading = false;
                        });
                      }
                    })
        ],
      ),
    );
  }
}
