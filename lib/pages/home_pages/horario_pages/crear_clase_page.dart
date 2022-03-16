import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:norkik_app/models/asignatura_model.dart';
import 'package:norkik_app/models/clases_model.dart';
import 'package:norkik_app/models/horario_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/asignatura_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/clases_provider.dart';
import 'package:norkik_app/providers/storage_shared.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:norkik_app/utils/alert_temp.dart';

class CrearClase extends StatefulWidget {
  CrearClase({Key? key}) : super(key: key);

  @override
  _CrearClaseState createState() => _CrearClaseState();
}

class _CrearClaseState extends State<CrearClase> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff2a4a4d);

  StorageShared storageShared = StorageShared();
  ClasesProvider clasesProvider = ClasesProvider();
  AsignaturaProvider asignaturaProvider = AsignaturaProvider();

  TextEditingController _asignaturaController = TextEditingController();
  TextEditingController _fechaInicioController = TextEditingController();
  TextEditingController _fechaFinController = TextEditingController();
  String profesor = '';
  String salon = '';

  AsignaturaModel? asignaturaSelect;
  List<dynamic> listTime = [];
  List<AsignaturaModel> asignaturaList = [];
  Map<String, dynamic> mapColors = {};
  DocumentReference? docRefHorario;
  List<ClasesModel> listClasesModel = [];
  // bool isLoading = false;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (mounted) {
      listTime = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
      _fechaInicioController.text = listTime[0].toString() + ":" + '00';
      _fechaFinController.text = (listTime[0] + 1).toString() + ":" + '00';
      docRefHorario = listTime[2];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear clase'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: _formClase(),
        ),
      ),
    );
  }

  _formClase() {
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
              controller: _asignaturaController,
              validator: (value) =>
                  value!.isNotEmpty ? null : 'Porfavor ingrese la asignatura',
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.class_),
                hintText: 'Selecciona una asignatura',
              ),
              onTap: () {
                _showSelectAsignature();
              },
            ),
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
              title:
                  Text(listTime.isEmpty ? 'No día' : getDayName(listTime[1])),
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
            ListTile(
              leading: Icon(Icons.room),
              title: Text('Salón: ' + salon),
            ),
            ListTile(
              leading: Icon(Icons.group_outlined),
              title: Text('Profesor: ' + profesor),
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
                        Text('Crear clase'),
                      ],
              ),
              textColor: Theme.of(context).appBarTheme.foregroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        if (asignaturaSelect != null && listTime.isNotEmpty) {
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
                              if (init.weekday == listTime[1]) {
                                DateTime inicioComparar = DateTime(
                                    2021, 12, 4, init.hour, init.minute);
                                DateTime finComparar =
                                    DateTime(2021, 12, 4, fin.hour, fin.minute);
                                DateTime selectInitComparar = DateTime(
                                    2021,
                                    12,
                                    4,
                                    initTimeOfDay.hour,
                                    initTimeOfDay.minute);
                                DateTime selectFinComparar = DateTime(2021, 12,
                                    4, finTimeOfDay.hour, finTimeOfDay.minute);
                                if ((inicioComparar
                                                .compareTo(selectInitComparar) <
                                            0 &&
                                        finComparar
                                                .compareTo(selectInitComparar) >
                                            0) ||
                                    (inicioComparar
                                                .compareTo(selectFinComparar) <
                                            0 &&
                                        finComparar
                                                .compareTo(selectFinComparar) >
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
                            DateTime now = DateTime.now();
                            DateTime selectTimeInit = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                initTimeOfDay.hour,
                                initTimeOfDay.minute);
                            DateTime selectTimeFin = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                finTimeOfDay.hour,
                                finTimeOfDay.minute);
                            selectTimeInit = selectTimeInit.subtract(
                                Duration(days: selectTimeInit.weekday - 1));
                            selectTimeFin = selectTimeFin.subtract(
                                Duration(days: selectTimeFin.weekday - 1));
                            selectTimeInit = selectTimeInit
                                .add(Duration(days: (listTime[1] - 1)));
                            selectTimeFin = selectTimeFin
                                .add(Duration(days: (listTime[1] - 1)));
                            storageShared.obtenerColoresAsignaturaList();

                            Map<String, dynamic> mapColores =
                                await storageShared
                                    .obtenerColoresAsignaturaList();
                            ClasesModel? clases;
                            for (var item in listAuxClases) {
                              ClasesModel clasesModel = await item;
                              if (clasesModel.asignatura.idAsignatura ==
                                  asignaturaSelect!.idAsignatura) {
                                clases = clasesModel;
                              }
                            }

                            if (clases != null) {
                              clasesProvider.addClassMap(clases.idClase, {
                                'Inicio': selectTimeInit,
                                'Fin': selectTimeFin
                              });

                              if (mapColores.containsKey(
                                  asignaturaSelect!.idAsignatura)) {
                                mapColores[asignaturaSelect!.idAsignatura] =
                                    currentColor.value;
                              } else {
                                mapColores.addAll({
                                  asignaturaSelect!.idAsignatura:
                                      currentColor.value
                                });
                              }
                            } else {
                              clasesProvider.createClase(
                                  ClasesModel(
                                      idClase: 'no-id',
                                      fechaInicioFin: [
                                        {
                                          'Inicio': selectTimeInit,
                                          'Fin': selectTimeFin
                                        }
                                      ],
                                      horario:
                                          HorarioModel.horarioModelNoData(),
                                      asignatura: AsignaturaModel
                                          .asignaturaModelNoData()),
                                  (await asignaturaProvider
                                      .getAsignaturaReferenceById(
                                          asignaturaSelect!.idAsignatura))!,
                                  docRefHorario as DocumentReference<
                                      Map<String, dynamic>>);
                              if (mapColores.containsKey(
                                  asignaturaSelect!.idAsignatura)) {
                                mapColores[asignaturaSelect!.idAsignatura] =
                                    currentColor.value;
                              } else {
                                mapColores.addAll({
                                  asignaturaSelect!.idAsignatura:
                                      currentColor.value
                                });
                              }
                            }
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
                    },
            )
          ],
        ));
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

  TimeOfDay _convertStringToTimeOfDay(String time) {
    return TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1]));
  }

  Future<void> _getAsignaturas() async {
    setState(() {
      isLoading = true;
    });
    asignaturaList.clear();

    List<Future<AsignaturaModel>> listAsignaturaAux =
        await asignaturaProvider.getAsignaturas();
    for (var itemAsignatura in listAsignaturaAux) {
      AsignaturaModel asignatura = await itemAsignatura;
      asignaturaList.add(asignatura);
    }
    mapColors = await storageShared.obtenerColoresAsignaturaList();
    setState(() {
      isLoading = false;
    });
  }

  _showSelectAsignature() async {
    await _getAsignaturas();
    List<Widget> asignaturasListWidgets = [];
    for (var item in asignaturaList) {
      asignaturasListWidgets.add(ListTile(
        title: Text(item.nombre),
        leading: Icon(
          Icons.class_,
          color: mapColors[item.idAsignatura] != null
              ? Color(mapColors[item.idAsignatura])
              : null,
        ),
        subtitle: Text(item.docente.nombre + " " + item.docente.apellido),
        onTap: () {
          setState(() {
            _asignaturaController.text = item.nombre;
            profesor = item.docente.nombre + " " + item.docente.apellido;
            salon = item.salon;
            currentColor = mapColors[item.idAsignatura] != null
                ? Color(mapColors[item.idAsignatura])
                : currentColor;
          });
          asignaturaSelect = item;
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
            title: Text('Asignatura a selecionar'),
            children: [
              ListTile(
                leading: Icon(Icons.add),
                trailing: Icon(Icons.class_),
                title: Text('Crear Asignatura'),
                onTap: () {
                  Navigator.pushNamed(context, 'crearAsignatura')
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
                  children: asignaturasListWidgets,
                ),
              )
            ],
          );
        });
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
}
