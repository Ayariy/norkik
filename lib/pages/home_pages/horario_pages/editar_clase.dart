import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:norkik_app/models/clases_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/clases_provider.dart';
import 'package:norkik_app/providers/storage_shared.dart';
import 'package:norkik_app/utils/alert_temp.dart';

class EditarClase extends StatefulWidget {
  EditarClase({Key? key}) : super(key: key);

  @override
  _EditarClaseState createState() => _EditarClaseState();
}

class _EditarClaseState extends State<EditarClase> {
  StorageShared storageShared = StorageShared();
  ClasesProvider clasesProvider = ClasesProvider();

  List<ClasesModel> listClasesModel = [];
  DocumentReference? docRefHorario;

  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _fechaInicioController = TextEditingController();
  TextEditingController _fechaFinController = TextEditingController();
  Color currentColor = Color(0xff2a4a4d);
  Color pickerColor = Color(0xff443a49);
  List<dynamic> listTime = [];
  ClasesModel? claseModel;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      listTime = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
      _fechaInicioController.text =
          listTime[0].hour.toString() + ":" + listTime[0].minute.toString();

      _fechaFinController.text =
          listTime[1].hour.toString() + ":" + listTime[1].minute.toString();
      claseModel = listTime[2] as ClasesModel;
      docRefHorario = listTime[3];
      _obtenerColor();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Editar clase ${listTime.isNotEmpty ? claseModel!.asignatura.nombre : ''}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: _formEditarAsignatura()),
      ),
    );
  }

  _formEditarAsignatura() {
    return Form(
        onWillPop: () async {
          return isLoading ? false : true;
        },
        key: _formKey,
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                Icons.color_lens,
                color: currentColor,
              ),
              title: Text('Color de la asignatura'),
              trailing: Container(
                width: 50,
                height: 30,
                color: currentColor,
              ),
              onTap: () {
                _showSelectColor();
              },
            ),
            Container(
              width: double.infinity,
              height: 0.5,
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
            ListTile(
              leading: Icon(Icons.view_week),
              title: Text(listTime.isEmpty
                  ? 'No día'
                  : getDayName(listTime[0].weekday)),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              width: double.infinity,
              height: 0.5,
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
            TextFormField(
              readOnly: true,
              enableInteractiveSelection: false,
              controller: _fechaInicioController,
              validator: (value) {
                if (value!.isNotEmpty) {
                  TimeOfDay initTimeOfDay =
                      _convertStringToTimeOfDay(_fechaInicioController.text);
                  TimeOfDay finTimeOfDay =
                      _convertStringToTimeOfDay(_fechaFinController.text);
                  DateTime inicio = DateTime(
                      2021, 12, 4, initTimeOfDay.hour, initTimeOfDay.minute);
                  DateTime fin = DateTime(
                      2021, 12, 4, finTimeOfDay.hour, finTimeOfDay.minute);

                  if (fin.compareTo(inicio) > 0) {
                    return null;
                  } else {
                    return 'La hora inicio debe ser menor a la hora fin';
                  }
                } else {
                  return 'Porfavor ingrese la hora de inicio';
                }
              },
              decoration: InputDecoration(
                  prefixIcon: Text('Inicio:'),
                  hintText: 'Selecciona la hora inicial',
                  icon: Icon(Icons.timelapse)),
              onTap: () {
                _showPickerTimeInicio();
              },
            ),
            SizedBox(
              height: 15,
            ),
            TextFormField(
              readOnly: true,
              enableInteractiveSelection: false,
              controller: _fechaFinController,
              validator: (value) {
                if (value!.isNotEmpty) {
                  TimeOfDay initTimeOfDay =
                      _convertStringToTimeOfDay(_fechaInicioController.text);
                  TimeOfDay finTimeOfDay =
                      _convertStringToTimeOfDay(_fechaFinController.text);
                  DateTime inicio = DateTime(
                      2021, 12, 4, initTimeOfDay.hour, initTimeOfDay.minute);
                  DateTime fin = DateTime(
                      2021, 12, 4, finTimeOfDay.hour, finTimeOfDay.minute);
                  if (fin.compareTo(inicio) > 0) {
                    return null;
                  } else {
                    return 'La hora inicio debe ser menor a la hora fin';
                  }
                } else {
                  return 'Porfavor ingrese la hora de finalización';
                }
              },
              decoration: InputDecoration(
                prefixIcon: Text('Fin'),
                hintText: 'Selecciona la hora final',
                icon: Icon(Icons.timelapse),
              ),
              onTap: () => _showPickerTimeFin(),
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
                          Icon(Icons.class_),
                          SizedBox(
                            width: 15,
                          ),
                          Text('Editar clase'),
                        ],
                ),
                textColor: Theme.of(context).appBarTheme.foregroundColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          if (listTime.isNotEmpty) {
                            setState(() {
                              isLoading = true;
                            });

                            listClasesModel.clear();
                            List<Future<ClasesModel>> listAuxClases =
                                await clasesProvider.getClasesByHorario(
                                    docRefHorario as DocumentReference<
                                        Map<String, dynamic>>);
                            bool chocaHorarios = false;
                            TimeOfDay initTimeOfDay = _convertStringToTimeOfDay(
                                _fechaInicioController.text);
                            TimeOfDay finTimeOfDay = _convertStringToTimeOfDay(
                                _fechaFinController.text);
                            for (var itemClases in listAuxClases) {
                              ClasesModel clasesModel = await itemClases;
                              for (var itemDays in clasesModel.fechaInicioFin) {
                                DateTime init = itemDays['Inicio'].toDate();
                                DateTime fin = itemDays['Fin'].toDate();
                                print(listTime[0].weekday);
                                if (init.weekday == listTime[0].weekday) {
                                  DateTime inicioComparar = DateTime(
                                      2021, 12, 4, init.hour, init.minute);
                                  DateTime finComparar = DateTime(
                                      2021, 12, 4, fin.hour, fin.minute);
                                  DateTime selectInitComparar = DateTime(
                                      2021,
                                      12,
                                      4,
                                      initTimeOfDay.hour,
                                      initTimeOfDay.minute);
                                  DateTime selectFinComparar = DateTime(
                                      2021,
                                      12,
                                      4,
                                      finTimeOfDay.hour,
                                      finTimeOfDay.minute);
                                  if ((inicioComparar.compareTo(
                                                  selectInitComparar) <
                                              0 &&
                                          finComparar.compareTo(
                                                  selectInitComparar) >
                                              0) ||
                                      (inicioComparar.compareTo(
                                                  selectFinComparar) <
                                              0 &&
                                          finComparar.compareTo(
                                                  selectFinComparar) >
                                              0)) {
                                    chocaHorarios = true;
                                  } else {
                                    print('no hay choque');
                                  }
                                }
                              }
                            }

                            if (chocaHorarios) {
                              getAlert(context, 'Choque de horarios',
                                  'Existe un choque de horarios');
                            } else {
                              //base de datos update
                              clasesProvider.removeClase(claseModel!.idClase,
                                  {'Inicio': listTime[0], 'Fin': listTime[1]});
                              DateTime inicio = listTime[0];
                              DateTime fin = listTime[1];
                              DateTime selectedInit = DateTime(
                                  inicio.year,
                                  inicio.month,
                                  inicio.day,
                                  initTimeOfDay.hour,
                                  initTimeOfDay.minute);
                              DateTime selectedFin = DateTime(
                                  fin.year,
                                  fin.month,
                                  fin.day,
                                  finTimeOfDay.hour,
                                  finTimeOfDay.minute);
                              clasesProvider.addClassMap(claseModel!.idClase,
                                  {'Inicio': selectedInit, 'Fin': selectedFin});
                              Map<String, dynamic> mapColores =
                                  await storageShared
                                      .obtenerColoresAsignaturaList();

                              mapColores[claseModel!.asignatura.idAsignatura] =
                                  currentColor.value;
                              await storageShared
                                  .agregarColoresAsignaturaList(mapColores);
                              Navigator.pop(context);
                            }

                            setState(() {
                              isLoading = false;
                            });
                          } else {
                            getAlert(context, 'Error en la ejecución',
                                'No se pudo completar su petición, intentelo más tarde');
                          }
                        }
                      })
          ],
        ));
  }

  TimeOfDay _convertStringToTimeOfDay(String time) {
    return TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1]));
  }

  void _showPickerTimeInicio() async {
    TimeOfDay timeInicio =
        _convertStringToTimeOfDay(_fechaInicioController.text);
    TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay(hour: timeInicio.hour, minute: timeInicio.minute));
    if (time != null) {
      _fechaInicioController.text =
          time.hour.toString() + ":" + time.minute.toString();
    }
  }

  void _showPickerTimeFin() async {
    TimeOfDay timeFin = _convertStringToTimeOfDay(_fechaFinController.text);
    TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: timeFin.hour, minute: timeFin.minute));
    if (time != null) {
      _fechaFinController.text =
          time.hour.toString() + ":" + time.minute.toString();
    }
  }

  void _showSelectColor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: MaterialPicker(
              pickerColor: pickerColor,
              onColorChanged: (value) {
                setState(() {
                  pickerColor = value;
                });
              },
              enableLabel: true, // only on portrait mode
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Seleccionar'),
              onPressed: () {
                setState(() => currentColor = pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String getDayName(int numeroDia) {
    switch (numeroDia) {
      case 1:
        return 'Lunes';

      case 2:
        return 'Martes';

      case 3:
        return 'Miércoles';
      case 4:
        return 'Jueves';
      case 5:
        return 'Viernes';
      case 6:
        return 'Sábado';
      default:
        return 'Domingo';
    }
  }

  void _obtenerColor() async {
    Map<String, dynamic> listColor =
        await storageShared.obtenerColoresAsignaturaList();
    setState(() {
      if (listColor.isNotEmpty) {
        if (listColor[claseModel!.asignatura.idAsignatura] != null) {
          currentColor = Color(listColor[claseModel!.asignatura.idAsignatura]);
        }
      }
    });
  }
}
