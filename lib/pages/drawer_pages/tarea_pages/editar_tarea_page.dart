import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:norkik_app/models/tarea_model.dart';
import 'package:intl/intl.dart';
import 'package:norkik_app/providers/norkikdb_providers/asignatura_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/tarea_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/providers/notification.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class EditarTareaPage extends StatefulWidget {
  TareaModel tareaModel;
  Function funtionGetListTareas;
  EditarTareaPage(
      {Key? key, required this.tareaModel, required this.funtionGetListTareas})
      : super(key: key);

  @override
  State<EditarTareaPage> createState() => _EditarTareaPageState();
}

class _EditarTareaPageState extends State<EditarTareaPage> {
  AsignaturaProvider asignaturaProvider = AsignaturaProvider();
  TareaProvider tareaProvider = TareaProvider();

  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _descripcionController = TextEditingController();
  TextEditingController _fechaController = TextEditingController();

  String _fecha = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      _nombreController.text = widget.tareaModel.nombre;
      _descripcionController.text = widget.tareaModel.descripcion;
      _fechaController.text = DateFormat("yyyy-MM-dd HH:mm:ss", 'es')
          .format(widget.tareaModel.fecha);
      ;
      _fecha = widget.tareaModel.fecha.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Tarea'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: _getFormTareaEdit(),
        ),
      ),
    );
  }

  Widget _getFormTareaEdit() {
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
                  : 'Ingrese una descripción a la tarea',
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.description),
                hintText: 'Descripción de la tarea',
              ),
              onChanged: (value) {
                // setState(() {});
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
                horizontalTitleGap: 5,
                minLeadingWidth: 5,
                minVerticalPadding: 18,
                leading: widget.tareaModel.realizado
                    ? Icon(
                        Icons.verified,
                        color: Colors.green,
                      )
                    : DateTime.now().compareTo(widget.tareaModel.fecha) >= 1
                        ? Icon(Icons.dangerous, color: Colors.red)
                        : Icon(Icons.dangerous, color: Colors.orange),
                trailing: Icon(Icons.arrow_forward_ios_rounded),
                title: Text('Estado de la tarea'),
                subtitle: Text(
                    '${widget.tareaModel.realizado ? 'Realizado' : DateTime.now().compareTo(widget.tareaModel.fecha) >= 1 ? 'Fuera de fecha límite, sin realizar' : 'Dentro de la fecha límite, sin realizar'}'),
                onTap: () {
                  setState(() {
                    widget.tareaModel.realizado = !widget.tareaModel.realizado;
                  });
                }),
            Container(
              margin: const EdgeInsets.all(0),
              width: double.infinity,
              height: 0.5,
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
            ListTile(
              leading: Icon(Icons.class_),
              title: Text(widget.tareaModel.asignatura.nombre),
              subtitle: Text('Msc. ' +
                  widget.tareaModel.asignatura.docente.nombre +
                  " " +
                  widget.tareaModel.asignatura.docente.apellido),
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
                          Text('Editar tarea'),
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
                          //elimina la notificacion
                          NotificationProvider notificationProvider =
                              Provider.of<NotificationProvider>(context,
                                  listen: false);
                          notificationProvider.removeIdNotification(
                              widget.tareaModel.idLocalNotification);

                          //crea la notificación

                          String idNotification = Uuid().v1();
                          int hashCodeId = idNotification.hashCode;

                          bool val =
                              await notificationProvider.timeNotification(
                                  hashCodeId,
                                  _nombreController.text,
                                  'Tienes tareas de ' +
                                      widget.tareaModel.asignatura.nombre,
                                  DateTime.parse(_fecha),
                                  'tareas');

                          //edita la tarea
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
                                        .tareaModel.asignatura.idAsignatura))!;
                            TareaModel tareaModel = TareaModel(
                                idTarea: widget.tareaModel.idTarea,
                                nombre: _nombreController.text,
                                descripcion: _descripcionController.text,
                                fecha: DateTime.parse(_fecha),
                                realizado: widget.tareaModel.realizado,
                                idLocalNotification: hashCodeId,
                                asignatura: widget.tareaModel.asignatura,
                                usuario: widget.tareaModel.usuario);
                            tareaProvider.updateTarea(
                                tareaModel, userRef, asignaturaRef);

                            setState(() {
                              widget.funtionGetListTareas();
                              isLoading = false;
                            });
                            Navigator.pop(context);
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
