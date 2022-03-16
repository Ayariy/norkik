import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:norkik_app/models/recordatorio_model.dart';
import 'package:norkik_app/models/tarea_model.dart';
import 'package:norkik_app/pages/drawer_pages/tarea_pages/editar_tarea_page.dart';
import 'package:norkik_app/pages/drawer_pages/tarea_pages/ver_tarea_page.dart';
import 'package:norkik_app/providers/norkikdb_providers/asignatura_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/tarea_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/providers/notification.dart';
import 'package:norkik_app/providers/storage_shared.dart';
import 'package:flutter_clean_calendar/flutter_clean_calendar.dart';
import 'package:provider/provider.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
import 'package:collection/collection.dart';

class CalendarioPage extends StatefulWidget {
  Function funtionIndexPage;
  CalendarioPage({Key? key, required this.funtionIndexPage}) : super(key: key);

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  TareaProvider tareaProvider = TareaProvider();
  StorageShared storageShared = StorageShared();
  AsignaturaProvider asignaturaProvider = AsignaturaProvider();

  DateTime? selectDay;
  List<CleanCalendarEvent> selectedEvent = [];
  // DateTime nowDate = ;

  bool isLoadingTarea = false;
  List<TareaModel> listTareas = [];

  bool isLoadingRecordatorio = false;
  List<RecordatorioModel> listRecordatorioModel = [];

  Map<DateTime, List<CleanCalendarEvent>> events = {};

  void _handleData(date) {
    setState(() {
      selectDay = date;
      selectedEvent = events[selectDay] ?? [];
    });

    print(selectDay);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectDay = DateTime.now();
    selectedEvent = events[selectDay] ?? [];

    _getListTarea();
    // _getListRecordatorio();
    // _getEventsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoadingRecordatorio || isLoadingTarea
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Calendar(
              startOnMonday: true,
              selectedColor: Theme.of(context).primaryColor,
              todayColor: Colors.red,
              eventColor: Theme.of(context).primaryColor,
              eventDoneColor: Colors.green,
              bottomBarColor: Colors.grey,
              locale: 'es_ES',
              todayButtonText: 'Ir a Hoy',
              onDateSelected: (date) {
                return _handleData(date);
              },
              events: events,
              isExpanded: true,
              dayOfWeekStyle:
                  TextStyle(color: Theme.of(context).indicatorColor),
              // bottomBarTextStyle: TextStyle(color: Colors.purple),
              hideBottomBar: false,
              hideArrows: false,
              weekDays: ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'],
              eventListBuilder: (context, events) {
                return events.isEmpty
                    ? Expanded(
                        child: Center(
                        child: Text('No hay eventos para este día'),
                      ))
                    : Expanded(
                        child: Timeline(
                        children: _getTimeLineModelList(events),
                        position: TimelinePosition.Left,
                        iconSize: 25,
                        lineColor: Theme.of(context).indicatorColor,
                      ));
              },
            ),
    );
  }

  List<TimelineModel> _getTimeLineModelList(List<CleanCalendarEvent> events) {
    List<TimelineModel> listTimeLineModel = [];
    listTimeLineModel.add(TimelineModel(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('Tus eventos'), Divider()],
        ),
        icon: Icon(
          Icons.event,
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
        iconBackground: Theme.of(context).primaryColor));
    events.forEach((element) {
      String idEvent = element.location;
      RecordatorioModel? recordatorio = listRecordatorioModel.firstWhereOrNull(
          (elementRecordatorio) => elementRecordatorio.id == idEvent);
      TareaModel? tarea = listTareas.firstWhereOrNull(
          (elementTarea) => elementTarea.idTarea == element.location);

      listTimeLineModel.add(
        recordatorio != null
            ? TimelineModel(
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(recordatorio.fecha.hour.toString() +
                                    ":" +
                                    recordatorio.fecha.minute.toString())
                              ],
                            ),
                            title: Text(
                              element.summary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(element.description),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          // alignment: Alignment.centerRight,
                          icon: Icon(Icons.more_vert),
                          onPressed: () {
                            _showModalWidgetRecordatorio(recordatorio);
                          },
                        ),
                      ],
                    ),
                    Divider()
                  ],
                ),
                icon: Icon(
                  Icons.notifications_active,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
                iconBackground:
                    DateTime.now().compareTo(recordatorio.fecha) >= 0
                        ? Colors.amber
                        : Theme.of(context).indicatorColor,
                onTap: () {
                  Navigator.pushNamed(context, 'verRecordatorio',
                      arguments: recordatorio);
                },
              )
            : TimelineModel(
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(tarea!.fecha.hour.toString() +
                                    ":" +
                                    tarea.fecha.minute.toString())
                              ],
                            ),
                            title: Text(element.summary),
                            subtitle: Text(element.description +
                                ' (${tarea.realizado ? 'Realizado' : 'Sin realizar'})'),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          // alignment: Alignment.centerRight,
                          icon: Icon(Icons.more_vert),
                          onPressed: () {
                            _showModalWidgetTarea(tarea);
                          },
                        ),
                      ],
                    ),
                    Divider()
                  ],
                ),
                icon: Icon(Icons.home_work,
                    color: Theme.of(context).appBarTheme.foregroundColor),
                iconBackground: tarea.realizado
                    ? Colors.green
                    : DateTime.now().compareTo(tarea.fecha) >= 0
                        ? Theme.of(context).errorColor
                        : Colors.amber, onTap: () {
                _showModalWidgetView(VerTareaPage(tareaModel: tarea));
              }),
      );
    });

    return listTimeLineModel;
  }

  void _getListTarea() async {
    isLoadingTarea = true;
    listTareas.clear();
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    DocumentReference<Map<String, dynamic>> userRef = (await userProvider
        .getUserReferenceById(userProvider.userGlobal.idUsuario))!;
    List<Future<TareaModel>> listFutureTareas =
        await tareaProvider.getAllTareasByUser(userRef);
    for (var tarea in listFutureTareas) {
      TareaModel tareaModel = await tarea;
      listTareas.add(tareaModel);
    }
    _getListRecordatorio();
    if (mounted) {
      setState(() {
        isLoadingTarea = false;
      });
    }
  }

  void _getListRecordatorio() async {
    isLoadingRecordatorio = true;

    listRecordatorioModel.clear();

    listRecordatorioModel =
        await storageShared.obtenerRecordatoriosStorageList();
    listRecordatorioModel.sort((a, b) {
      return a.fecha.compareTo(b.fecha);
    });
    _getEventsList();
    if (mounted) {
      setState(() {
        isLoadingRecordatorio = false;
      });
    }
  }

  void _getEventsList() {
    List<dynamic> listItemsAll = [];
    events.clear();
    listTareas.forEach((element) {
      listItemsAll.add(element);
    });

    listRecordatorioModel.forEach((element) {
      listItemsAll.add(element);
    });

    //ordena por fechas
    listItemsAll.sort((a, b) {
      return a.fecha.compareTo(b.fecha);
    });

    listItemsAll.forEach((element) {
      DateTime fechaAux =
          DateTime(element.fecha.year, element.fecha.month, element.fecha.day);
      if (events.containsKey(fechaAux)) {
        if (element is TareaModel) {
          events[fechaAux]!.add(
            CleanCalendarEvent(element.nombre,
                description: 'Tarea',
                location: element.idTarea,
                startTime: element.fecha,
                endTime: element.fecha,
                color: Colors.orange),
          );
        } else if (element is RecordatorioModel) {
          events[fechaAux]!.add(
            CleanCalendarEvent(element.nombre,
                description: 'Recordatorio',
                location: element.id,
                startTime: element.fecha,
                endTime: element.fecha,
                color: Colors.orange),
          );
        }
      } else {
        if (element is TareaModel) {
          events.addAll({
            fechaAux: [
              CleanCalendarEvent(element.nombre,
                  description: 'Tarea',
                  location: element.idTarea,
                  startTime: element.fecha,
                  endTime: element.fecha,
                  color: Colors.orange),
            ]
          });
        } else if (element is RecordatorioModel) {
          events.addAll({
            fechaAux: [
              CleanCalendarEvent(element.nombre,
                  description: 'Recordatorio',
                  location: element.id,
                  startTime: element.fecha,
                  endTime: element.fecha,
                  color: Colors.orange),
            ]
          });
        }
      }
    });
    // int cont = 0;
    // listItemsAll.forEach((element) {
    //   cont++;
    //   print(element.runtimeType.toString() + "---" + cont.toString());
    // });
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

  void _showModalWidgetTarea(TareaModel tareaSelected) {
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
                      isLoadingTarea = true;
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
                      _getListTarea();
                      // isLoadingTarea = false;
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
                          _getListTarea();
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
                      _getListTarea();
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
                      Icon(Icons.home_work),
                      SizedBox(
                        width: 15,
                      ),
                      Text('Ver todas las Tarea')
                    ],
                  ),
                  onPressed: () async {
                    Navigator.pushNamed(context, 'tareas');
                  },
                ),
              ),
            ],
          );
        });
  }

  void _showModalWidgetRecordatorio(RecordatorioModel recordatorioModel) {
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
                      setState(() {
                        _getListTarea();
                      });
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

                    listRecordatorioModel.removeWhere((element) {
                      return element.id == recordatorioModel.id;
                    });
                    storageShared
                        .agregarRecordatoriosStorageList(listRecordatorioModel);
                    Navigator.pop(context);
                    setState(() {
                      _getListTarea();
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
                      Icon(Icons.notifications),
                      SizedBox(
                        width: 15,
                      ),
                      Text('Ver todos los Recordatorios')
                    ],
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    widget.funtionIndexPage(3);
                  },
                ),
              ),
            ],
          );
        });
  }
}
