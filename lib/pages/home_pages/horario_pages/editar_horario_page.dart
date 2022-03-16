import 'package:flutter/material.dart';
import 'package:norkik_app/models/horario_model.dart';
import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/horario_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:provider/provider.dart';

class EditarHorario extends StatefulWidget {
  EditarHorario({Key? key}) : super(key: key);

  @override
  State<EditarHorario> createState() => _EditarHorarioState();
}

class _EditarHorarioState extends State<EditarHorario> {
  HorarioProvider clasesProvider = HorarioProvider();

  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nombreController = TextEditingController();
  TextEditingController _descripcionController = TextEditingController();

  HorarioModel? horarioSelected;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (mounted) {
      horarioSelected =
          ModalRoute.of(context)!.settings.arguments as HorarioModel;
      if (horarioSelected != null) {
        _nombreController.text = horarioSelected!.nombre;
        _descripcionController.text = horarioSelected!.descripcion;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar horario de clases'),
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
                  value!.isNotEmpty ? null : 'Porfavor ingrese el nombre',
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.class_),
                hintText: 'Nombre del horario',
              ),
            ),
            TextFormField(
              maxLines: null,
              controller: _descripcionController,
              validator: (value) => value!.isNotEmpty
                  ? null
                  : 'Porfavor ingrese una pequeña descripción',
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
                          Text('Editar Horario de clases'),
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
                          if (horarioSelected != null) {
                            horarioSelected!.nombre = _nombreController.text;
                            horarioSelected!.descripcion =
                                _descripcionController.text;
                            clasesProvider.updateHorario(
                                horarioSelected!,
                                (await userProvider.getUserReferenceById(
                                    userProvider.userGlobal.idUsuario))!);
                            Navigator.pop(context);
                          } else {
                            getAlert(context, 'Fallo la petición',
                                'No se pudo completar la petición, intentelo más tarde');
                          }
                          setState(() {
                            isLoading = false;
                          });
                        }
                      })
          ],
        ));
  }
}
