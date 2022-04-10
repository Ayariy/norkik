import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:norkik_app/models/asignatura_model.dart';
import 'package:norkik_app/models/tarea_model.dart';
import 'package:norkik_app/pages/drawer_pages/tarea_pages/crear_tarea_page.dart';
import 'package:norkik_app/pages/drawer_pages/tarea_pages/editar_tarea_page.dart';
import 'package:norkik_app/pages/drawer_pages/tarea_pages/ver_tarea_page.dart';
import 'package:norkik_app/providers/norkikdb_providers/asignatura_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/tarea_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/providers/notification.dart';
import 'package:norkik_app/providers/storage_shared.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TareasPage extends StatefulWidget {
  const TareasPage({Key? key}) : super(key: key);

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  String _opcionSeleccionada = 'Esta semana';
  final List<String> _opcionesTiempo = [
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
  AsignaturaProvider asignaturaProvider = AsignaturaProvider();
  TareaProvider tareaProvider = TareaProvider();

  Map<String, dynamic> mapColors = {};
  List<AsignaturaModel> listAsignatura = [];
  List<TareaModel> listTareas = [];
  List<TareaModel> listTareasAux = [];
  int selectedPage = 0;

  bool isSearch = false;
  bool isLoading = false;
  bool isLoadingList = false;

  AsignaturaModel? asignaturaSelected;

  final _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      _getListAsignaturas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tareas'),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : listAsignatura.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Por el momento no hay asignaturas asignadas al horario para crear tareas',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      _crearDropdown(),
                      isLoadingList
                          ? Expanded(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : listTareas.isEmpty
                              ? Expanded(
                                  child: Center(
                                      child: Text('No hay tareas, para ' +
                                          asignaturaSelected!.nombre +
                                          " " +
                                          _opcionSeleccionada)))
                              : Expanded(
                                  child: RefreshIndicator(
                                  onRefresh: getListTareas,
                                  child: Stack(
                                    children: [
                                      ListView.builder(
                                        controller: _scrollController,
                                        itemCount: listTareas.length,
                                        itemBuilder: (context, index) {
                                          return _getTileTarea(
                                              listTareas[index]);
                                        },
                                      ),
                                      // _getLoadingMore()
                                    ],
                                  ),
                                ))
                    ],
                  ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          overlayOpacity: 0.3,
          spacing: 10,
          children: [
            SpeedDialChild(
                label: '¿Deseas crear una tarea?',
                child: const Icon(Icons.add),
                onTap: () {
                  if (asignaturaSelected != null) {
                    _showModalWidgetView(CrearTareaPage(
                      asignaturaModel: asignaturaSelected!,
                      funtionGetListTareas: () {
                        setState(() {
                          getListTareas();
                        });
                      },
                    ));
                  } else {
                    getAlert(context, 'Asignatura sin seleccionar',
                        'Por el momento no se ha seleccionado una asignatura para crear la tarea');
                  }
                }),
            SpeedDialChild(
                label: isSearch
                    ? '¿Ocultar campo de búsqueda?'
                    : '¿Deseas buscar algo?',
                child: const Icon(Icons.search),
                onTap: () {
                  setState(() {
                    isSearch = !isSearch;
                  });
                })
          ],
        ),
        bottomSheet:
            isLoadingList || isLoading ? SizedBox() : _crearDropdownFecha(),
      ),
    );
  }

  _getListAsignaturas() async {
    setState(() {
      isLoading = true;
    });
    mapColors = await storageShared.obtenerColoresAsignaturaList();
    await Future.forEach(mapColors.entries, (MapEntry element) async {
      AsignaturaModel asignaturaModel =
          await asignaturaProvider.getAsignaturaById(element.key);

      listAsignatura.add(asignaturaModel);
    });
    if (listAsignatura.isNotEmpty) {
      asignaturaSelected = listAsignatura.first;
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    getListTareas();
  }

  Future<void> getListTareas() async {
    if (asignaturaSelected != null) {
      isLoadingList = true;
      listTareas.clear();
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      DocumentReference<Map<String, dynamic>> userRef = (await userProvider
          .getUserReferenceById(userProvider.userGlobal.idUsuario))!;
      // print(listAsignatura.length);
      DocumentReference<Map<String, dynamic>> asignaturaRef =
          (await asignaturaProvider
              .getAsignaturaReferenceById(asignaturaSelected!.idAsignatura))!;
      List<Future<TareaModel>> listFutureTareas =
          await tareaProvider.getTareas(null, asignaturaRef, userRef);
      for (var tarea in listFutureTareas) {
        TareaModel tareaModel = await tarea;
        listTareas.add(tareaModel);
      }

      listTareasAux = listTareas;
      _getListRecordatoriosEstaSemana();
      if (mounted) {
        setState(() {
          isLoadingList = false;
          _opcionSeleccionada = 'Esta semana';
        });
      }
    }
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
              value: asignaturaSelected!.idAsignatura,
              items: _getOpcionesDropdown(),
              onChanged: (String? op) {
                getListTareas();
                setState(() {
                  asignaturaSelected = listAsignatura
                      .firstWhere((element) => element.idAsignatura == op);
                });
              },
            ),
          ),
          Icon(Icons.class_),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _getOpcionesDropdown() {
    List<DropdownMenuItem<String>> lista = [];

    // ignore: avoid_function_literals_in_foreach_calls
    listAsignatura.forEach((asignatura) {
      lista.add(DropdownMenuItem(
        child: Text(asignatura.nombre),
        value: asignatura.idAsignatura,
      ));
    });

    return lista;
  }

  Widget _crearDropdownFecha() {
    return Container(
      decoration: BoxDecoration(boxShadow: const [
        BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            spreadRadius: 2.0,
            offset: Offset(-2.0, -4.0))
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
              items: getOpcionesDropdownFecha(),
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

  List<DropdownMenuItem<String>> getOpcionesDropdownFecha() {
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

  void _showModalWidgetView(Widget widgetShow) {
    showModalBottomSheet(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return widgetShow;
        });
  }

  void _showModalWidget(TareaModel tareaSelected) {
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
                    children: [
                      !tareaSelected.realizado
                          ? Icon(
                              Icons.verified,
                              color: Colors.green,
                            )
                          : DateTime.now().compareTo(tareaSelected.fecha) >= 1
                              ? Icon(Icons.dangerous, color: Colors.red)
                              : Icon(Icons.dangerous, color: Colors.orange),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                          '${tareaSelected.realizado ? 'Marcar como NO realizado' : 'Marcar como realizado'}')
                    ],
                  ),
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    UserProvider userProvider =
                        Provider.of<UserProvider>(context, listen: false);
                    DocumentReference<Map<String, dynamic>> userRef =
                        (await userProvider.getUserReferenceById(
                            userProvider.userGlobal.idUsuario))!;
                    DocumentReference<Map<String, dynamic>> asignaturaRef =
                        (await asignaturaProvider.getAsignaturaReferenceById(
                            tareaSelected.asignatura.idAsignatura))!;
                    TareaModel tareaModel = TareaModel(
                        idTarea: tareaSelected.idTarea,
                        nombre: tareaSelected.nombre,
                        descripcion: tareaSelected.descripcion,
                        fecha: tareaSelected.fecha,
                        realizado: !tareaSelected.realizado,
                        idLocalNotification: tareaSelected.idLocalNotification,
                        asignatura: tareaSelected.asignatura,
                        usuario: tareaSelected.usuario);
                    tareaProvider.updateTarea(
                        tareaModel, userRef, asignaturaRef);

                    setState(() {
                      getListTareas();
                      isLoading = false;
                    });
                    Navigator.pop(context);
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
                      Icon(Icons.edit_outlined),
                      SizedBox(
                        width: 15,
                      ),
                      Text('Editar Tarea')
                    ],
                  ),
                  onPressed: () {
                    _showModalWidgetView(EditarTareaPage(
                      tareaModel: tareaSelected,
                      funtionGetListTareas: () {
                        setState(() {
                          getListTareas();
                        });
                      },
                    ));
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
                      Text('Eliminar Tarea')
                    ],
                  ),
                  onPressed: () async {
                    NotificationProvider notificationProvider =
                        Provider.of<NotificationProvider>(context,
                            listen: false);
                    notificationProvider.removeIdNotification(
                        tareaSelected.idLocalNotification);
                    await tareaProvider.deleteTareaById(tareaSelected.idTarea);
                    setState(() {
                      getListTareas();
                    });
                    Navigator.pop(context);
                    // await notaProvider.deleteNotaTextoById(tareaSelected.idNota);
                    // Navigator.pop(context);
                    // setState(() {
                    //   getListNotas();
                    // });
                  },
                ),
              ),
            ],
          );
        });
  }

  Widget _getTileTarea(TareaModel tareaModel) {
    DateTime nowDate = DateTime.now();
    String textFecha = 'Fecha no calculada';
    if ((tareaModel.fecha.year - nowDate.year) <= -1) {
      int restaAnios = tareaModel.fecha.year - nowDate.year;
      if (restaAnios == -1) {
        //anterior año
        textFecha = 'Año anterior';
      } else {
        //anteriores años o mas
        textFecha = 'Hace ${restaAnios * -1} años';
      }
    } else if (nowDate.year == tareaModel.fecha.year &&
        (tareaModel.fecha.month - nowDate.month) <= -1) {
      int restaMeses = tareaModel.fecha.month - nowDate.month;
      if (restaMeses == -1) {
        //Anterior mes
        textFecha = 'Mes anterior';
      } else {
        //Anterior 2 o mas meses
        textFecha = 'Hace ${restaMeses * -1} meses';
      }
    } else if (nowDate.year == tareaModel.fecha.year &&
        nowDate.month == tareaModel.fecha.month &&
        (tareaModel.fecha.day - nowDate.day) < -1) {
      int restaDias = tareaModel.fecha.day - nowDate.day;
      if (restaDias < -1 && restaDias > -8) {
        // hace 2 dias o mas
        textFecha = 'Hace ${restaDias * -1} días';
      } else {
        //Anteriores semanas
        int semanasAnteriores = (restaDias / 7).floor();
        textFecha = 'Hace ${semanasAnteriores * -1} semana(s)';
      }
    } else if (nowDate.year == tareaModel.fecha.year &&
        nowDate.month == tareaModel.fecha.month &&
        (tareaModel.fecha.day - nowDate.day) == -1) {
      //ayer
      textFecha = 'Ayer';
    } else if (nowDate.year == tareaModel.fecha.year &&
        nowDate.month == tareaModel.fecha.month &&
        nowDate.day == tareaModel.fecha.day) {
      ///hoy
      textFecha = 'Hoy';
    } else if (nowDate.year == tareaModel.fecha.year &&
        nowDate.month == tareaModel.fecha.month &&
        (tareaModel.fecha.day - nowDate.day) == 1) {
      //mañana
      textFecha = 'Mañana';
    } else if (nowDate.year == tareaModel.fecha.year &&
        nowDate.month == tareaModel.fecha.month &&
        (tareaModel.fecha.day - nowDate.day) > 1) {
      int restaDias = tareaModel.fecha.day - nowDate.day;
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
    } else if (nowDate.year == tareaModel.fecha.year &&
        (tareaModel.fecha.month - nowDate.month) >= 1) {
      int restaMeses = tareaModel.fecha.month - nowDate.month;
      if (restaMeses == 1) {
        //Proximo mes
        textFecha = 'Próximo mes';
      } else {
        //proximos 2 o mas meses
        textFecha = 'Próximos $restaMeses meses';
      }
    } else if ((tareaModel.fecha.year - nowDate.year) >= 1) {
      int restaAnios = tareaModel.fecha.year - nowDate.year;
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
          child: _textoTiempoFecha(
              textFecha, DateFormat.yMMMEd('es').format(tareaModel.fecha)),
        ),
        ListTile(
          leading: Column(
            children: [
              tareaModel.realizado
                  ? Icon(
                      Icons.verified,
                      color: Colors.green,
                    )
                  : DateTime.now().compareTo(tareaModel.fecha) >= 1
                      ? Icon(Icons.dangerous, color: Colors.red)
                      : Icon(Icons.dangerous, color: Colors.orange),
              Text(tareaModel.fecha.hour.toString() +
                  ":" +
                  tareaModel.fecha.minute.toString())
            ],
          ),
          title: Text(
            tareaModel.nombre +
                ' (${tareaModel.realizado ? 'Realizado' : 'Sin realizar'})',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            tareaModel.descripcion,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: Icon(FontAwesomeIcons.ellipsisV),
            onPressed: () async {
              if (await tareaProvider.existTarea(tareaModel.idTarea)) {
                _showModalWidget(tareaModel);
              } else {
                getAlert(context, 'Tarea Inexistente',
                    'La tarea seleccionada no existe');
              }
            },
          ),
          onTap: () {
            _showModalWidgetView(VerTareaPage(tareaModel: tareaModel));
          },
        ),
      ],
    );
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
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
          ),
          Text(fecha)
        ],
      ),
    );
  }

  //combo box fecha ---------------------------- metodos

  _getListRecordatoriosAyer() {
    DateTime nowDate = DateTime.now();
    setState(() {
      isLoading = true;
    });
    listTareas = listTareasAux.where((element) {
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
    listTareas = listTareasAux.where((element) {
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
    listTareas = listTareasAux.where((element) {
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
    listTareas = listTareasAux.where((element) {
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
    listTareas = listTareasAux.where((element) {
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
    listTareas = listTareasAux.where((element) {
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
    listTareas = listTareasAux.where((element) {
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
    listTareas = listTareasAux;
    setState(() {
      isLoading = false;
    });
  }
}
