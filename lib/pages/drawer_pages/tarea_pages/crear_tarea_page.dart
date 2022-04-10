import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:norkik_app/models/asignatura_model.dart';
import 'package:norkik_app/models/tarea_model.dart';
import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/asignatura_provider.dart';
import 'package:intl/intl.dart';
import 'package:norkik_app/providers/norkikdb_providers/tarea_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/providers/notification.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CrearTareaPage extends StatefulWidget {
  AsignaturaModel asignaturaModel;
  Function funtionGetListTareas;
  CrearTareaPage(
      {Key? key,
      required this.asignaturaModel,
      required this.funtionGetListTareas})
      : super(key: key);

  @override
  State<CrearTareaPage> createState() => _CrearTareaPageState();
}

class _CrearTareaPageState extends State<CrearTareaPage> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _descripcionController = TextEditingController();
  TextEditingController _fechaController = TextEditingController();

  String _fecha = '';
  // NotaProvider notaProvider = new NotaProvider();
  AsignaturaProvider asignaturaProvider = AsignaturaProvider();
  TareaProvider tareaProvider = TareaProvider();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear tarea'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: _getFormTarea(),
        ),
      ),
    );
  }

  Widget _getFormTarea() {
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
                  value!.isNotEmpty ? null : 'Ingresa el nombre de la tarea',
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.home_work),
                hintText: 'Nombre de la tarea',
              ),
            ),
            TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _descripcionController,
              validator: (value) => value!.isNotEmpty
                  ? null
                  : 'Ingresa una descripción a la tarea',
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.description),
                hintText: 'Descripción de la tarea',
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            TextFormField(
              readOnly: true,
              enableInteractiveSelection: false,
              controller: _fechaController,
              validator: (value) {
                if (value!.isNotEmpty) {
                  DateTime now = DateTime.now();
                  if (now.compareTo(DateTime.parse(_fecha)) <= 0) {
                    return null;
                  } else {
                    return 'La fecha debe ser mayor a la actual';
                  }
                } else {
                  return 'Ingresa la fecha';
                }
              },
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.date_range),
                  hintText: 'Agregar una fecha',
                  suffixIcon: Icon(Icons.arrow_forward_ios_rounded)),
              onTap: () {
                _selectDate(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.class_),
              title: Text(widget.asignaturaModel.nombre),
              subtitle: Text('Msc. ' +
                  widget.asignaturaModel.docente.nombre +
                  " " +
                  widget.asignaturaModel.docente.apellido),
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
                          Icon(Icons.home_work),
                          SizedBox(
                            width: 15,
                          ),
                          Text('Crear tarea'),
                        ],
                ),
                textColor: Theme.of(context).appBarTheme.foregroundColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          if (widget.asignaturaModel != null) {
                            setState(() {
                              isLoading = true;
                            });

                            NotificationProvider notificationProvider =
                                Provider.of<NotificationProvider>(context,
                                    listen: false);
                            String idNotification = Uuid().v1();
                            int hashCodeId = idNotification.hashCode;

                            bool val =
                                await notificationProvider.timeNotification(
                                    hashCodeId,
                                    _nombreController.text,
                                    'Tienes tareas de ' +
                                        widget.asignaturaModel.nombre,
                                    DateTime.parse(_fecha),
                                    'tareas');
                            if (val) {
                              UserProvider userProvider =
                                  Provider.of<UserProvider>(context,
                                      listen: false);
                              DocumentReference<Map<String, dynamic>> userRef =
                                  (await userProvider.getUserReferenceById(
                                      userProvider.userGlobal.idUsuario))!;
                              DocumentReference<Map<String, dynamic>>
                                  asignaturaRef = (await asignaturaProvider
                                      .getAsignaturaReferenceById(widget
                                          .asignaturaModel.idAsignatura))!;
                              TareaModel tareaModel = TareaModel(
                                  idTarea: '',
                                  nombre: _nombreController.text,
                                  descripcion: _descripcionController.text,
                                  fecha: DateTime.parse(_fecha),
                                  realizado: false,
                                  idLocalNotification: hashCodeId,
                                  asignatura:
                                      AsignaturaModel.asignaturaModelNoData(),
                                  usuario: UserModel.userModelNoData());

                              await tareaProvider.createTarea(
                                  tareaModel, asignaturaRef, userRef);
                            } else {
                              getAlert(context, 'Alerta Tarea',
                                  'Lamentablemente no pudimos procesar tu petición');
                            }
                            setState(() {
                              isLoading = false;
                            });
                            widget.funtionGetListTareas();
                            Navigator.pop(context);
                          } else {
                            getAlert(context, 'Alerta',
                                'Ocurrió un problema, inténtalo más tarde');
                          }
                        }
                      })
          ],
        ));
  }

  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime.now(),
        lastDate: new DateTime(2030),
        locale: Locale('es', 'ES'));
    TimeOfDay? time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && time != null) {
      setState(() {
        picked = picked!.add(Duration(hours: time.hour, minutes: time.minute));
        _fecha = picked.toString();

        _fechaController.text = DateFormat("yyyy-MM-dd HH:mm:ss", 'es')
            .format(DateTime.parse(_fecha));
      });
    }
  }
}
