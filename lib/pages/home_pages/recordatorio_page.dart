import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:norkik_app/models/recordatorio_model.dart';
import 'package:norkik_app/providers/notification.dart';
import 'package:norkik_app/providers/storage_shared.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class RecordatorioPage extends StatefulWidget {
  const RecordatorioPage({Key? key}) : super(key: key);

  @override
  State<RecordatorioPage> createState() => _RecordatorioPageState();
}

class _RecordatorioPageState extends State<RecordatorioPage> {
  String _opcionSeleccionada = 'Esta semana';
  List<String> _opcionesTiempo = [
    'Ayer',
    'Hoy',
    'Esta semana',
    'Próxima semana',
    'Este mes',
    'Próximo mes',
    'Este año',
    'Todo'
  ];

  StorageShared storageShared = StorageShared();
  List<RecordatorioModel> listRecordatorioModel = [];
  List<RecordatorioModel> listRecordatorioModelAux = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _getListRecordatorios();
    }
  }

  @override
  Widget build(BuildContext context) {
    NotificationProvider notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    return Scaffold(
      body: Column(
        children: [
          _crearDropdown(),
          // Expanded(child: _listRecordatorio()),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : listRecordatorioModel.isEmpty
                    ? Center(
                        child: Text('No hay recordatorios para esta fecha'),
                      )
                    : ListView.separated(
                        itemBuilder: (context, index) {
                          return FadeInLeft(
                              child: _listTile(listRecordatorioModel[index]));
                        },
                        separatorBuilder: (_, __) => FadeInLeft(
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 0),
                                width: double.infinity,
                                height: 0.5,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .color,
                              ),
                            ),
                        itemCount: listRecordatorioModel.length),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.pushNamed(context, 'crearRecordatorio')
              .then((value) => _getListRecordatorios());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  _getListRecordatoriosAyer() {
    DateTime nowDate = DateTime.now();
    setState(() {
      isLoading = true;
    });
    listRecordatorioModel = listRecordatorioModelAux.where((element) {
      return (nowDate.year == element.fecha.year &&
          nowDate.month == element.fecha.month &&
          (element.fecha.day - nowDate.day) == -1);
    }).toList();
    setState(() {
      isLoading = false;
    });
  }

  _getListRecordatoriosHoy() {
    DateTime now = DateTime.now();
    setState(() {
      isLoading = true;
    });
    listRecordatorioModel = listRecordatorioModelAux.where((element) {
      return element.fecha.year == now.year &&
          element.fecha.month == now.month &&
          element.fecha.day == now.day;
    }).toList();
    setState(() {
      isLoading = false;
    });
  }

  _getListRecordatoriosEstaSemana() {
    DateTime nowDate = DateTime.now();
    setState(() {
      isLoading = true;
    });
    listRecordatorioModel = listRecordatorioModelAux.where((element) {
      return (nowDate.year == element.fecha.year &&
              nowDate.month == element.fecha.month &&
              (element.fecha.day - nowDate.day) >= 0) &&
          (element.fecha.day - nowDate.day) < 8;
    }).toList();
    setState(() {
      isLoading = false;
    });
  }

  _getListRecordatoriosProximaSemana() {
    DateTime nowDate = DateTime.now();
    setState(() {
      isLoading = true;
    });
    listRecordatorioModel = listRecordatorioModelAux.where((element) {
      return (nowDate.year == element.fecha.year &&
              nowDate.month == element.fecha.month &&
              (element.fecha.day - nowDate.day) >= 8) &&
          (element.fecha.day - nowDate.day) <= 14;
    }).toList();
    setState(() {
      isLoading = false;
    });
  }

  _getListRecordatoriosEsteMes() {
    DateTime nowDate = DateTime.now();
    setState(() {
      isLoading = true;
    });
    listRecordatorioModel = listRecordatorioModelAux.where((element) {
      return (nowDate.year == element.fecha.year &&
          nowDate.month == element.fecha.month);
    }).toList();
    setState(() {
      isLoading = false;
    });
  }

  _getListRecordatoriosProximoMes() {
    DateTime nowDate = DateTime.now();
    setState(() {
      isLoading = true;
    });
    listRecordatorioModel = listRecordatorioModelAux.where((element) {
      return (nowDate.year == element.fecha.year &&
          (element.fecha.month - nowDate.month) == 1);
    }).toList();
    setState(() {
      isLoading = false;
    });
  }

  _getListRecordatoriosEsteAnio() {
    DateTime nowDate = DateTime.now();
    setState(() {
      isLoading = true;
    });
    listRecordatorioModel = listRecordatorioModelAux.where((element) {
      return (nowDate.year == element.fecha.year);
    }).toList();
    setState(() {
      isLoading = false;
    });
  }

  _getListRecordatoriosTodo() {
    setState(() {
      isLoading = true;
    });
    listRecordatorioModel = listRecordatorioModelAux;
    setState(() {
      isLoading = false;
    });
  }

  void _getListRecordatorios() async {
    isLoading = true;
    listRecordatorioModel =
        await storageShared.obtenerRecordatoriosStorageList();
    listRecordatorioModel.sort((a, b) {
      return a.fecha.compareTo(b.fecha);
    });

    listRecordatorioModelAux = listRecordatorioModel;
    _getListRecordatoriosEstaSemana();
    setState(() {
      _opcionSeleccionada = 'Esta semana';
      isLoading = false;
    });
  }

  Widget _listTile(RecordatorioModel recordatorioModel) {
    DateTime nowDate = DateTime.now();
    String textFecha = 'Fecha no calculada';
    if ((recordatorioModel.fecha.year - nowDate.year) <= -1) {
      int restaAnios = recordatorioModel.fecha.year - nowDate.year;
      if (restaAnios == -1) {
        //anterior año
        textFecha = 'Año anterior';
      } else {
        //anteriores años o mas
        textFecha = 'Hace ${restaAnios * -1} años';
      }
    } else if (nowDate.year == recordatorioModel.fecha.year &&
        (recordatorioModel.fecha.month - nowDate.month) <= -1) {
      int restaMeses = recordatorioModel.fecha.month - nowDate.month;
      if (restaMeses == -1) {
        //Anterior mes
        textFecha = 'Mes anterior';
      } else {
        //Anterior 2 o mas meses
        textFecha = 'Hace ${restaMeses * -1} meses';
      }
    } else if (nowDate.year == recordatorioModel.fecha.year &&
        nowDate.month == recordatorioModel.fecha.month &&
        (recordatorioModel.fecha.day - nowDate.day) < -1) {
      int restaDias = recordatorioModel.fecha.day - nowDate.day;
      if (restaDias < -1 && restaDias > -8) {
        // hace 2 dias o mas
        textFecha = 'Hace ${restaDias * -1} días';
      } else {
        //Anteriores semanas
        int semanasAnteriores = (restaDias / 7).floor();
        textFecha = 'Hace ${semanasAnteriores * -1} semana(s)';
      }
    } else if (nowDate.year == recordatorioModel.fecha.year &&
        nowDate.month == recordatorioModel.fecha.month &&
        (recordatorioModel.fecha.day - nowDate.day) == -1) {
      //ayer
      textFecha = 'Ayer';
    } else if (nowDate.year == recordatorioModel.fecha.year &&
        nowDate.month == recordatorioModel.fecha.month &&
        nowDate.day == recordatorioModel.fecha.day) {
      ///hoy
      textFecha = 'Hoy';
    } else if (nowDate.year == recordatorioModel.fecha.year &&
        nowDate.month == recordatorioModel.fecha.month &&
        (recordatorioModel.fecha.day - nowDate.day) == 1) {
      //mañana
      textFecha = 'Mañana';
    } else if (nowDate.year == recordatorioModel.fecha.year &&
        nowDate.month == recordatorioModel.fecha.month &&
        (recordatorioModel.fecha.day - nowDate.day) > 1) {
      int restaDias = recordatorioModel.fecha.day - nowDate.day;
      if (restaDias > 1 && restaDias < 8) {
        // esta semana (dias)
        textFecha = 'Próximos $restaDias días';
      } else if (restaDias >= 8 && restaDias <= 14) {
        //proxima semana
        textFecha = 'Próxima semana';
      } else {
        int semanasProximas = (restaDias / 7).ceil();
        textFecha = 'Próximas $semanasProximas semanas';
      }
    } else if (nowDate.year == recordatorioModel.fecha.year &&
        (recordatorioModel.fecha.month - nowDate.month) >= 1) {
      int restaMeses = recordatorioModel.fecha.month - nowDate.month;
      if (restaMeses == 1) {
        //Proximo mes
        textFecha = 'Próximo mes';
      } else {
        //proximos 2 o mas meses
        textFecha = 'Próximos $restaMeses meses';
      }
    } else if ((recordatorioModel.fecha.year - nowDate.year) >= 1) {
      int restaAnios = recordatorioModel.fecha.year - nowDate.year;
      if (restaAnios == 1) {
        //proximo año
        textFecha = 'Próximo año';
      } else {
        //proximos años
        textFecha = 'Próximos $restaAnios años';
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: _textoTiempoFecha(textFecha,
              DateFormat.yMMMEd('es').format(recordatorioModel.fecha)),
        ),
        ListTile(
          leading: Column(
            children: [
              Icon(Icons.share_arrival_time),
              Text(recordatorioModel.fecha.hour.toString() +
                  ":" +
                  recordatorioModel.fecha.minute.toString())
            ],
          ),
          title: Text(
            recordatorioModel.nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            recordatorioModel.descripcion,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: Icon(FontAwesomeIcons.ellipsisV),
            onPressed: () async {
              List<RecordatorioModel> listModel =
                  await storageShared.obtenerRecordatoriosStorageList();
              var contain = listModel
                  .where((element) => element.id == recordatorioModel.id);
              if (contain.isNotEmpty) {
                _showModalWidget(recordatorioModel);
              } else {
                getAlert(context, 'Recordatorio Inexistente',
                    'El recordatorio pulsado no existe');
              }
            },
          ),
          onTap: () {
            Navigator.pushNamed(context, 'verRecordatorio',
                arguments: recordatorioModel);
          },
        ),
      ],
    );
  }

  Widget _crearDropdown() {
    return Container(
      decoration: BoxDecoration(boxShadow: const [
        BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            spreadRadius: 2.0,
            offset: Offset(2.0, 4.0))
      ], color: Theme.of(context).cardColor),
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton(
              isDense: true,
              isExpanded: true,
              // dropdownColor: Colors.white,
              value: _opcionSeleccionada,
              items: getOpcionesDropdown(),
              onChanged: (String? op) {
                if (op == 'Ayer') {
                  _getListRecordatoriosAyer();
                } else if (op == 'Hoy') {
                  _getListRecordatoriosHoy();
                } else if (op == 'Esta semana') {
                  _getListRecordatoriosEstaSemana();
                } else if (op == 'Próxima semana') {
                  _getListRecordatoriosProximaSemana();
                } else if (op == 'Este mes') {
                  _getListRecordatoriosEsteMes();
                } else if (op == 'Próximo mes') {
                  _getListRecordatoriosProximoMes();
                } else if (op == 'Este año') {
                  _getListRecordatoriosEsteAnio();
                } else {
                  _getListRecordatoriosTodo();
                }
                setState(() {
                  _opcionSeleccionada = op ?? "sin seleccionar";
                });
              },
            ),
          ),
          Icon(Icons.calendar_today_outlined),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> getOpcionesDropdown() {
    List<DropdownMenuItem<String>> lista = [];

    // ignore: avoid_function_literals_in_foreach_calls
    _opcionesTiempo.forEach((opcion) {
      lista.add(DropdownMenuItem(
        child: Text(opcion),
        value: opcion,
      ));
    });

    return lista;
  }

  Widget _textoTiempoFecha(String tiempo, String fecha) {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            tiempo,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
          ),
          Text(fecha)
        ],
      ),
    );
  }

  void _showModalWidget(RecordatorioModel recordatorioModel) {
    NotificationProvider notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    showModalBottomSheet(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(),
                width: double.infinity,
                child: TextButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.edit_outlined),
                      SizedBox(
                        width: 15,
                      ),
                      Text('Editar Recordatorio')
                    ],
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, 'editarRecordatorio',
                            arguments: recordatorioModel)
                        .then((value) {
                      _getListRecordatorios();
                    });
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(0),
                width: double.infinity,
                height: 0.5,
                color: Theme.of(context).textTheme.bodyText1!.color,
              ),
              Container(
                decoration: const BoxDecoration(),
                width: double.infinity,
                child: TextButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.delete_forever),
                      SizedBox(
                        width: 15,
                      ),
                      Text('Eliminar Recordatorio')
                    ],
                  ),
                  onPressed: () async {
                    notificationProvider
                        .removeIdNotification(int.parse(recordatorioModel.id));
                    List<RecordatorioModel> listItemDelete =
                        listRecordatorioModelAux;
                    listItemDelete.removeWhere((element) {
                      return element.id == recordatorioModel.id;
                    });
                    storageShared
                        .agregarRecordatoriosStorageList(listItemDelete);
                    Navigator.pop(context);
                    setState(() {
                      _getListRecordatorios();
                    });
                  },
                ),
              ),
            ],
          );
        });
  }
}
