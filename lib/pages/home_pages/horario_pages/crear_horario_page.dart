import 'package:flutter/material.dart';
import 'package:norkik_app/models/horario_model.dart';
import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/horario_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:provider/provider.dart';

class CrearHorario extends StatefulWidget {
  CrearHorario({Key? key}) : super(key: key);

  @override
  State<CrearHorario> createState() => _CrearHorarioState();
}

class _CrearHorarioState extends State<CrearHorario> {
  HorarioProvider clasesProvider = HorarioProvider();

  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nombreController = TextEditingController();
  TextEditingController _descripcionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear horario de clases'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: _getFormHorario(),
        ),
      ),
    );
  }

  _getFormHorario() {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Form(
        key: _formKey,
        onWillPop: () async {
          return isLoading ? false : true;
        },
        child: Column(
          children: [
            TextFormField(
              controller: _nombreController,
              validator: (value) =>
                  value!.isNotEmpty ? null : 'Ingresa el nombre',
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.class_),
                hintText: 'Nombre del horario',
              ),
            ),
            TextFormField(
              maxLines: null,
              controller: _descripcionController,
              validator: (value) =>
                  value!.isNotEmpty ? null : 'Ingresa una descripción',
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.description),
                hintText: 'Descripción del horario',
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 35),
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
                          Icon(Icons.calendar_view_week),
                          SizedBox(
                            width: 15,
                          ),
                          Text('Crear horario de clases'),
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
                          clasesProvider.createHorario(
                              HorarioModel(
                                  idHorario: 'no-id',
                                  nombre: _nombreController.text,
                                  descripcion: _descripcionController.text,
                                  fecha: DateTime.now(),
                                  usuario: UserModel.userModelNoData(),
                                  activo: false),
                              (await userProvider.getUserReferenceById(
                                  userProvider.userGlobal.idUsuario))!);
                          Navigator.pop(context);
                          setState(() {
                            isLoading = false;
                          });
                        }
                      })
          ],
        ));
  }
}
