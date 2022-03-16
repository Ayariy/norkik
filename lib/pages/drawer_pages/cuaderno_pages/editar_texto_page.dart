import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:norkik_app/models/nota_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/asignatura_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/nota_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:provider/provider.dart';

class EditarNotaTexto extends StatefulWidget {
  NotaModel notaEdit;
  Function fucionUpdateListNotas;
  EditarNotaTexto(
      {Key? key, required this.notaEdit, required this.fucionUpdateListNotas})
      : super(key: key);

  @override
  State<EditarNotaTexto> createState() => _EditarNotaTextoState();
}

class _EditarNotaTextoState extends State<EditarNotaTexto> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descripcionController = TextEditingController();

  NotaProvider notaProvider = new NotaProvider();
  AsignaturaProvider asignaturaProvider = AsignaturaProvider();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tituloController.text = widget.notaEdit.titulo;
    _descripcionController.text = widget.notaEdit.descripcion;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar nota de texto'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.text_fields),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: _formNotaTexto(),
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
            validator: (value) => value!.isNotEmpty
                ? null
                : 'Porfavor ingrese el titulo de la nota',
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.class_),
              hintText: 'Titulo de la nota',
            ),
          ),
          TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: _descripcionController,
            validator: (value) => value!.isNotEmpty
                ? null
                : 'Porfavor ingrese una descripcion a la nota',
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
            title: Text(widget.notaEdit.asignatura.nombre),
            subtitle: Text('Msc. ' +
                widget.notaEdit.asignatura.docente.nombre +
                " " +
                widget.notaEdit.asignatura.docente.apellido),
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
            subtitle: Text(widget.notaEdit.categoria),
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
                        Icon(Icons.note_alt_rounded),
                        SizedBox(
                          width: 15,
                        ),
                        Text('Editar Nota de texto'),
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

                        UserProvider userProvider =
                            Provider.of<UserProvider>(context, listen: false);
                        DocumentReference<Map<String, dynamic>> userRef =
                            (await userProvider.getUserReferenceById(
                                userProvider.userGlobal.idUsuario))!;
                        DocumentReference<Map<String, dynamic>> asignaturaRef =
                            (await asignaturaProvider
                                .getAsignaturaReferenceById(
                                    widget.notaEdit.asignatura.idAsignatura))!;

                        NotaModel nota = NotaModel(
                            idNota: widget.notaEdit.idNota,
                            titulo: _tituloController.text,
                            descripcion: _descripcionController.text,
                            file: widget.notaEdit.file,
                            fecha: DateTime.now(),
                            categoria: 'Texto',
                            asignatura: widget.notaEdit.asignatura,
                            usuario: widget.notaEdit.usuario);
                        await notaProvider.updateNotaTexto(
                            nota, userRef, asignaturaRef);
                        widget.fucionUpdateListNotas();
                        Navigator.pop(context);
                        Navigator.pop(context);
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
