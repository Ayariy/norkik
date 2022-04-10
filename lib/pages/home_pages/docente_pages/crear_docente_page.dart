import 'package:flutter/material.dart';
import 'package:norkik_app/models/docente_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/docente_provider.dart';

class CrearDocente extends StatefulWidget {
  CrearDocente({Key? key}) : super(key: key);

  @override
  _CrearDocenteState createState() => _CrearDocenteState();
}

class _CrearDocenteState extends State<CrearDocente> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _apellidoController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear docente'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: _formDocente(),
        ),
      ),
    );
  }

  _formDocente() {
    return Form(
        onWillPop: () async {
          return isLoading ? false : true;
        },
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nombreController,
              validator: (value) =>
                  value!.isNotEmpty ? null : 'Ingresa el nombre del docente',
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                hintText: 'Nombre del docente',
              ),
            ),
            TextFormField(
              controller: _apellidoController,
              validator: (value) =>
                  value!.isNotEmpty ? null : 'Ingresa el apellido del docente',
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person_outline_outlined),
                hintText: 'Apellido del docente',
              ),
            ),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Ingresa el correo';
                } else if (value.contains('@') &&
                    value.contains('.') &&
                    (value.endsWith('.com') || value.endsWith('.ec'))) {
                  return null;
                } else {
                  return 'Ingresa correctamente el correo';
                }
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.mail_rounded),
                hintText: 'Correo del docente',
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 30),
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
                        Icon(Icons.person),
                        SizedBox(
                          width: 15,
                        ),
                        Text('Crear Docente'),
                      ],
              ),
              textColor: Theme.of(context).appBarTheme.foregroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: isLoading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });
                        DocenteProvider docenteProvider = DocenteProvider();
                        docenteProvider.createDocente(DocenteModel(
                            idDocente: 'no-id',
                            nombre: _nombreController.text,
                            apellido: _apellidoController.text,
                            email: _emailController.text));
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.pop(context);
                      }
                    },
            )
          ],
        ));
  }
}
