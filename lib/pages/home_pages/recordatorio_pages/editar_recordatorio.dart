import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:norkik_app/models/recordatorio_model.dart';
import 'package:norkik_app/providers/notification.dart';
import 'package:norkik_app/providers/storage_shared.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:provider/provider.dart';

class EditarRecordatorio extends StatefulWidget {
  const EditarRecordatorio({Key? key}) : super(key: key);

  @override
  State<EditarRecordatorio> createState() => _EditarRecordatorioState();
}

class _EditarRecordatorioState extends State<EditarRecordatorio> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _tituloPostController = TextEditingController();
  TextEditingController _fechaPostController = TextEditingController();
  TextEditingController _descripcionPostController = TextEditingController();

  bool isLoading = false;
  String _fecha = '';
  late RecordatorioModel recordatorioModel;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (mounted) {
      recordatorioModel =
          ModalRoute.of(context)!.settings.arguments as RecordatorioModel;
      _fecha = recordatorioModel.fecha.toString();
      _tituloPostController.text = recordatorioModel.nombre;
      _descripcionPostController.text = recordatorioModel.descripcion;
      _fechaPostController.text = recordatorioModel.fecha.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar recordatorio'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: recordatorioModel != null
              ? _formRecordatorio(context, recordatorioModel)
              : Center(
                  child: Text(
                      'No se logró encontrar el recordatorio con el id especificado'),
                ),
        ),
      ),
    );
  }

  Form _formRecordatorio(
      BuildContext context, RecordatorioModel recordatorioModel) {
    NotificationProvider notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    return Form(
        onWillPop: () async {
          return isLoading ? false : true;
        },
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
                controller: _tituloPostController,
                validator: (value) => value!.isNotEmpty
                    ? null
                    : 'Porfavor ingrese el titulo del recordatorio',
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.title_rounded),
                  hintText: 'Agrega un título a tu recordatorio',
                )),
            SizedBox(
              height: 15,
            ),
            TextFormField(
              readOnly: true,
              enableInteractiveSelection: false,
              controller: _fechaPostController,
              validator: (value) {
                if (value!.isNotEmpty) {
                  DateTime now = DateTime.now();
                  if (now.compareTo(DateTime.parse(_fecha)) <= 0) {
                    return null;
                  } else {
                    return 'La fecha debe se mayor a la actual';
                  }
                } else {
                  return 'Porfavor ingrese la fecha';
                }
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.date_range),
                hintText: 'Agregar una fecha',
              ),
              onTap: () {
                // FocusScope.of(context).requestFocus(new FocusNode());
                _selectDate(context);
              },
            ),
            const SizedBox(
              height: 15,
            ),
            TextFormField(
                maxLines: null,
                controller: _descripcionPostController,
                validator: (value) => value!.isNotEmpty
                    ? null
                    : 'Porfavor ingrese la descripción del recordatorio',
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.description_rounded),
                  hintText: 'Agrega una descripción a tu recordatorio',
                )),
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
                        Icon(Icons.notifications_active),
                        SizedBox(
                          width: 15,
                        ),
                        Text('Editar Recordatorio'),
                      ],
              ),
              textColor: Theme.of(context).appBarTheme.foregroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    isLoading = true;
                  });
                  notificationProvider
                      .removeIdNotification(int.parse(recordatorioModel.id));
                  StorageShared storageShared = StorageShared();
                  List<RecordatorioModel> listRecord =
                      await storageShared.obtenerRecordatoriosStorageList();
                  RecordatorioModel recordatorioModelEdit =
                      listRecord.firstWhere(
                          (element) => element.id == recordatorioModel.id);
                  recordatorioModelEdit.nombre = _tituloPostController.text;
                  recordatorioModelEdit.descripcion =
                      _descripcionPostController.text;
                  recordatorioModelEdit.fecha = DateTime.parse(_fecha);
                  bool val = await notificationProvider.timeNotification(
                      int.parse(recordatorioModelEdit.id),
                      _tituloPostController.text,
                      _descripcionPostController.text,
                      DateTime.parse(_fecha),
                      'recordatorios');
                  if (val) {
                    listRecord.removeWhere(
                        (element) => element.id == recordatorioModel.id);
                    listRecord.add(recordatorioModelEdit);
                    await storageShared
                        .agregarRecordatoriosStorageList(listRecord);
                  } else {
                    getAlert(context, 'Alerta Recordatorio',
                        'Lamentablemente no pudimos procesar tu petición');
                  }

                  setState(() {
                    isLoading = false;
                  });
                  Navigator.pop(context);
                }
              },
            ),
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

        _fechaPostController.text = DateFormat("yyyy-MM-dd HH:mm:ss", 'es')
            .format(DateTime.parse(_fecha));
      });
    }
  }
}
