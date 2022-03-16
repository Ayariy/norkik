import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:norkik_app/models/clases_model.dart';
import 'package:norkik_app/models/horario_model.dart';
import 'package:norkik_app/models/recordatorio_model.dart';
import 'package:norkik_app/models/tarea_model.dart';
import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/pages/drawer_pages/tarea_pages/ver_tarea_page.dart';
import 'package:norkik_app/providers/norkikdb_providers/clases_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/horario_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/tarea_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/providers/storage_shared.dart';

import 'package:norkik_app/widget/charts_lineal.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ResumenPage extends StatefulWidget {
  final String? pageName;
  Function setIndexPageNavigator;
  ResumenPage(
      {Key? key, @required this.pageName, required this.setIndexPageNavigator})
      : super(key: key);

  @override
  State<ResumenPage> createState() => _ResumenPageState();
}

class _ResumenPageState extends State<ResumenPage> {
  bool isLoadingClases = false;
  bool isLoadingTarea = false;
  bool isLoadingRecordatorio = false;

  Map<int, List<ClasesModel>> listClases = {
    1: [],
    2: [],
    3: [],
    4: [],
    5: [],
    6: [],
    7: []
  };
  Map<int, List<TareaModel>> listTarea = {
    1: [],
    2: [],
    3: [],
    4: [],
    5: [],
    6: [],
    7: []
  };
  Map<int, List<RecordatorioModel>> listRecordatorio = {
    1: [],
    2: [],
    3: [],
    4: [],
    5: [],
    6: [],
    7: []
  };

  Map<String, dynamic> mapColors = {};

  ClasesProvider clasesProvider = ClasesProvider();
  HorarioProvider horarioProvider = HorarioProvider();
  TareaProvider tareaProvider = TareaProvider();
  StorageShared storageShared = StorageShared();

  DateTime fechaHoy = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      _getMapClases();
      _getMapTarea();
      _getMapRecordatorio();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListTileTheme(
        iconColor: Theme.of(context).iconTheme.color,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            FadeInDown(child: _cardReporteChart(context)),
            _textoDiaFecha('HOY', DateFormat.yMMMEd('es').format(fechaHoy)),
            Column(
              children: [
                isLoadingRecordatorio || isLoadingTarea
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : listRecordatorio[1]!.isEmpty && listTarea[1]!.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                Text('No hay eventos pendientes para hoy día'),
                          )
                        : FadeInDown(child: _cardEventos(1)),
                isLoadingClases
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : listClases[1]!.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No hay clases para hoy día'),
                          )
                        : FadeInDown(child: _cardHorario(context, 1)),
              ],
            ),
            _textoDiaFecha(
                'MAÑANA',
                DateFormat.yMMMEd('es')
                    .format(fechaHoy.add(Duration(days: 1)))),
            Column(
              children: [
                isLoadingRecordatorio || isLoadingTarea
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : listRecordatorio[2]!.isEmpty && listTarea[2]!.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                Text('No hay eventos pendientes para mañana'),
                          )
                        : FadeInDown(child: _cardEventos(2)),
                isLoadingClases
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : listClases[2]!.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No hay clases para mañana'),
                          )
                        : FadeInDown(child: _cardHorario(context, 2)),
              ],
            ),
            _textoDiaFecha(
                DateFormat.EEEE('es')
                    .format(fechaHoy.add(Duration(days: 2)))
                    .toUpperCase(),
                DateFormat.yMMMEd('es')
                    .format(fechaHoy.add(Duration(days: 2)))),
            Column(
              children: [
                isLoadingRecordatorio || isLoadingTarea
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : listRecordatorio[3]!.isEmpty && listTarea[3]!.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No hay eventos pendientes para el ' +
                                DateFormat.EEEE('es')
                                    .format(fechaHoy.add(Duration(days: 2)))
                                    .toLowerCase()),
                          )
                        : FadeInDown(child: _cardEventos(3)),
                isLoadingClases
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : listClases[3]!.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No hay clases para el ' +
                                DateFormat.EEEE('es')
                                    .format(fechaHoy.add(Duration(days: 2)))
                                    .toLowerCase()),
                          )
                        : FadeInDown(child: _cardHorario(context, 3)),
              ],
            ),
            _textoDiaFecha(
                DateFormat.EEEE('es')
                    .format(fechaHoy.add(Duration(days: 3)))
                    .toUpperCase(),
                DateFormat.yMMMEd('es')
                    .format(fechaHoy.add(Duration(days: 3)))),
            Column(
              children: [
                isLoadingRecordatorio || isLoadingTarea
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : listRecordatorio[4]!.isEmpty && listTarea[4]!.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No hay eventos pendientes para el ' +
                                DateFormat.EEEE('es')
                                    .format(fechaHoy.add(Duration(days: 3)))
                                    .toLowerCase()),
                          )
                        : FadeInDown(child: _cardEventos(4)),
                isLoadingClases
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : listClases[4]!.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No hay clases para ' +
                                DateFormat.EEEE('es')
                                    .format(fechaHoy.add(Duration(days: 3)))
                                    .toLowerCase()),
                          )
                        : FadeInDown(child: _cardHorario(context, 4)),
              ],
            ),
            _textoDiaFecha(
                DateFormat.EEEE('es')
                    .format(fechaHoy.add(Duration(days: 4)))
                    .toUpperCase(),
                DateFormat.yMMMEd('es')
                    .format(fechaHoy.add(Duration(days: 4)))),
            Column(
              children: [
                isLoadingRecordatorio || isLoadingTarea
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : listRecordatorio[5]!.isEmpty && listTarea[5]!.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No hay eventos pendientes para el ' +
                                DateFormat.EEEE('es')
                                    .format(fechaHoy.add(Duration(days: 4)))
                                    .toLowerCase()),
                          )
                        : FadeInDown(child: _cardEventos(5)),
                isLoadingClases
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : listClases[5]!.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No hay clases para ' +
                                DateFormat.EEEE('es')
                                    .format(fechaHoy.add(Duration(days: 4)))
                                    .toLowerCase()),
                          )
                        : FadeInDown(child: _cardHorario(context, 5)),
              ],
            ),
            _textoDiaFecha(
                DateFormat.EEEE('es')
                    .format(fechaHoy.add(Duration(days: 5)))
                    .toUpperCase(),
                DateFormat.yMMMEd('es')
                    .format(fechaHoy.add(Duration(days: 5)))),
            Column(
              children: [
                isLoadingRecordatorio || isLoadingTarea
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : listRecordatorio[6]!.isEmpty && listTarea[6]!.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No hay eventos pendientes para el ' +
                                DateFormat.EEEE('es')
                                    .format(fechaHoy.add(Duration(days: 5)))
                                    .toLowerCase()),
                          )
                        : FadeInDown(child: _cardEventos(6)),
                isLoadingClases
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : listClases[6]!.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No hay clases para ' +
                                DateFormat.EEEE('es')
                                    .format(fechaHoy.add(Duration(days: 5)))
                                    .toLowerCase()),
                          )
                        : FadeInDown(child: _cardHorario(context, 6)),
              ],
            ),
            _textoDiaFecha(
                DateFormat.EEEE('es')
                    .format(fechaHoy.add(Duration(days: 6)))
                    .toUpperCase(),
                DateFormat.yMMMEd('es')
                    .format(fechaHoy.add(Duration(days: 6)))),
            Column(
              children: [
                isLoadingRecordatorio || isLoadingTarea
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : listRecordatorio[7]!.isEmpty && listTarea[7]!.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No hay eventos pendientes para el ' +
                                DateFormat.EEEE('es')
                                    .format(fechaHoy.add(Duration(days: 6)))
                                    .toLowerCase()),
                          )
                        : FadeInDown(child: _cardEventos(7)),
                isLoadingClases
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : listClases[7]!.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No hay clases para ' +
                                DateFormat.EEEE('es')
                                    .format(fechaHoy.add(Duration(days: 6)))
                                    .toLowerCase()),
                          )
                        : FadeInDown(child: _cardHorario(context, 7)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardReporteChart(context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            ListTile(
              horizontalTitleGap: 5,
              minLeadingWidth: 5,
              minVerticalPadding: 18,
              leading: Icon(
                Icons.bar_chart_rounded,
              ),
              title: Text('Reporte semanal'),
            ),
            isLoadingClases || isLoadingTarea || isLoadingRecordatorio
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )
                : ChartsLineal(
                    listClases: listClases,
                    listTarea: listTarea,
                    listRecordatorio: listRecordatorio,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _cardEventos(int dayArray) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: Column(
        children: [
          ListTile(
            horizontalTitleGap: 5,
            minLeadingWidth: 5,
            minVerticalPadding: 18,
            leading: Icon(
              Icons.view_agenda_rounded,
            ),
            title: Text('Eventos pendientes'),
          ),
          Column(
            children: _getWidgetChildrenEventos(dayArray),
          ),
        ],
      ),
    );
  }

  Widget _cardHorario(context, int dayArray) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: Column(
        children: [
          ListTile(
            horizontalTitleGap: 5,
            minLeadingWidth: 5,
            minVerticalPadding: 18,
            leading: Icon(
              Icons.calendar_view_week,
            ),
            title: Text('Horario de clases'),
          ),
          Column(children: _getWidgetChildrenClass(dayArray)),
          SizedBox(
            height: 0.15,
            child: Container(
              color: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .color!
                  .withOpacity(0.5),
            ),
          ),
          ListTile(
            horizontalTitleGap: 11,
            minLeadingWidth: 0,
            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
            title: Text('Mostrar más'),
            leading: Icon(Icons.arrow_forward_rounded),
            onTap: () {
              widget.setIndexPageNavigator(4);
            },
          )
        ],
      ),
    );
  }

  Widget _textoDiaFecha(String dia, String fecha) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dia,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
          ),
          Text(fecha)
        ],
      ),
    );
  }

  Future<void> _getMapClases() async {
    isLoadingClases = true;
    List<ClasesModel> listClasesModel = [];
    DocumentReference? referenceHorario;
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    List<Future<HorarioModel>> listHorario = await horarioProvider.getHorarios(
        (await userProvider
            .getUserReferenceById(userProvider.userGlobal.idUsuario))!);

    if (listHorario.isEmpty) {
      referenceHorario = await horarioProvider.createHorario(
          HorarioModel(
              idHorario: 'no-id',
              nombre: 'Horario de clases',
              descripcion: 'Primer horario de clases UPEC',
              fecha: DateTime.now(),
              activo: true,
              usuario: UserModel.userModelNoData()),
          (await userProvider
              .getUserReferenceById(userProvider.userGlobal.idUsuario))!);
    } else {
      for (var itemHorario in listHorario) {
        HorarioModel horario = await itemHorario;
        if (horario.activo) {
          referenceHorario =
              await horarioProvider.getHorarioReferenceById(horario.idHorario);
        }
      }
    }
    if (referenceHorario == null) {
      HorarioModel horarioM = await listHorario.first;
      horarioM.activo = true;
      horarioProvider.updateHorario(
          horarioM,
          (await userProvider
              .getUserReferenceById(userProvider.userGlobal.idUsuario))!);
      referenceHorario =
          await horarioProvider.getHorarioReferenceById(horarioM.idHorario);
    }

    List<Future<ClasesModel>> listAuxClases =
        await clasesProvider.getClasesByHorario(
            referenceHorario as DocumentReference<Map<String, dynamic>>);

    for (var itemClases in listAuxClases) {
      ClasesModel clasesModel = await itemClases;
      listClasesModel.add(clasesModel);
    }
    mapColors = await storageShared.obtenerColoresAsignaturaList();

    //llenando la variable MAPCLASES
    for (var i = 0; i < listClases.length; i++) {
      for (var itemClass in listClasesModel) {
        for (var itemDay in itemClass.fechaInicioFin) {
          DateTime fechaClase = itemDay['Inicio'].toDate();
          DateTime fechaComparar = fechaHoy.add(Duration(days: i));
          if (fechaClase.weekday == fechaComparar.weekday) {
            ClasesModel classAux = ClasesModel(
                idClase: itemClass.idClase,
                fechaInicioFin: itemClass.fechaInicioFin,
                horario: itemClass.horario,
                asignatura: itemClass.asignatura);
            Map<String, dynamic> mapFecha = {
              'Inicio': itemDay['Inicio'],
              'Fin': itemDay['Fin']
            };
            classAux.fechaInicioFin = [];
            classAux.fechaInicioFin.add(mapFecha);
            listClases[i + 1]!.add(classAux);
          }
        }
      }
    }

    // listClases.forEach((key, value) {
    //   print(key.toString() + "C" + value.length.toString());
    // });
    if (mounted) {
      setState(() {
        isLoadingClases = false;
      });
    }
  }

  void _getMapTarea() async {
    isLoadingTarea = true;
    List<TareaModel> listTareas = [];
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

    for (var i = 0; i < listTarea.length; i++) {
      for (var tarea in listTareas) {
        DateTime fechaTarea =
            DateTime(tarea.fecha.year, tarea.fecha.month, tarea.fecha.day);
        DateTime fechaComparar = DateTime(
            fechaHoy.add(Duration(days: i)).year,
            fechaHoy.add(Duration(days: i)).month,
            fechaHoy.add(Duration(days: i)).day);
        // DateTime fechaComparar = fechaHoy.add(Duration(days: i));
        if (fechaComparar.compareTo(fechaTarea) == 0) {
          listTarea[i + 1]!.add(tarea);
        }
      }
    }

    // listTarea.forEach((key, value) {
    //   print(key.toString() + "T" + value.length.toString());
    // });
    if (mounted) {
      setState(() {
        isLoadingTarea = false;
      });
    }
  }

  void _getMapRecordatorio() async {
    isLoadingRecordatorio = true;
    List<RecordatorioModel> listRecordatorioModel = [];
    listRecordatorioModel =
        await storageShared.obtenerRecordatoriosStorageList();
    listRecordatorioModel.sort((a, b) {
      return a.fecha.compareTo(b.fecha);
    });

    for (var i = 0; i < listRecordatorio.length; i++) {
      for (var recordatorio in listRecordatorioModel) {
        DateTime fechaRecordatorio = DateTime(recordatorio.fecha.year,
            recordatorio.fecha.month, recordatorio.fecha.day);
        DateTime fechaComparar = DateTime(
            fechaHoy.add(Duration(days: i)).year,
            fechaHoy.add(Duration(days: i)).month,
            fechaHoy.add(Duration(days: i)).day);
        // DateTime fechaComparar = fechaHoy.add(Duration(days: i));
        if (fechaComparar.compareTo(fechaRecordatorio) == 0) {
          listRecordatorio[i + 1]!.add(recordatorio);
        }
      }
    }

    // listRecordatorio.forEach((key, value) {
    //   print(key.toString() + "R" + value.length.toString());
    // });
    if (mounted) {
      setState(() {
        isLoadingRecordatorio = false;
      });
    }
  }

  //TARJETAS EVENTOS Y CLASES DIA HOY
  List<Widget> _getWidgetChildrenEventos(int dayArray) {
    List<Widget> widgetList = [];
    for (var tarea in listTarea[dayArray]!) {
      widgetList.add(
        ListTile(
          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
          minLeadingWidth: 5,
          minVerticalPadding: 0,
          title: Text(tarea.nombre +
              "(${tarea.realizado ? 'Realizado' : 'Sin realizar'})"),
          subtitle: Text('Tarea'),
          leading: Column(children: [
            tarea.realizado
                ? Icon(
                    Icons.verified,
                    color: Colors.green,
                  )
                : DateTime.now().compareTo(tarea.fecha) >= 1
                    ? Icon(Icons.dangerous, color: Colors.red)
                    : Icon(Icons.dangerous, color: Colors.orange),
            Text(tarea.fecha.hour.toString() +
                ":" +
                tarea.fecha.minute.toString())
          ]),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
          ),
          onTap: () {
            _showModalWidgetView(VerTareaPage(tareaModel: tarea));
          },
        ),
      );
    }

    for (var recordatorio in listRecordatorio[dayArray]!) {
      widgetList.add(
        ListTile(
          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
          minLeadingWidth: 5,
          minVerticalPadding: 0,
          title: Text(recordatorio.nombre),
          subtitle: Text('Recordatorio'),
          leading: Column(
            children: [
              Icon(Icons.share_arrival_time),
              Text(recordatorio.fecha.hour.toString() +
                  ":" +
                  recordatorio.fecha.minute.toString())
            ],
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
          ),
          onTap: () {
            Navigator.pushNamed(context, 'verRecordatorio',
                arguments: recordatorio);
          },
        ),
      );
    }

    return widgetList;
  }

  List<Widget> _getWidgetChildrenClass(int dayArray) {
    List<Widget> widgetList = [];

    for (var itemClass in listClases[dayArray]!) {
      for (var itemDay in itemClass.fechaInicioFin) {
        DateTime fechaInit = itemDay['Inicio'].toDate();
        DateTime fechaFin = itemDay['Fin'].toDate();

        widgetList.add(
          ListTile(
            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
            minLeadingWidth: 5,
            minVerticalPadding: 0,
            title: Text(itemClass.asignatura.nombre),
            subtitle: Text(
                '${fechaInit.hour}:${fechaInit.minute} - ${fechaFin.hour}:${fechaFin.minute}'),
            leading: Icon(
              Icons.class_,
              color: mapColors[itemClass.asignatura.idAsignatura] != null
                  ? Color(mapColors[itemClass.asignatura.idAsignatura])
                  : null,
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded),
            onTap: () {
              _showAsignaturaDetail(itemClass);
            },
          ),
        );
      }
    }
    return widgetList;
  }

  _showAsignaturaDetail(ClasesModel clasesModel) {
    DateTime fechaInit = clasesModel.fechaInicioFin.first['Inicio'].toDate();
    DateTime fechaFin = clasesModel.fechaInicioFin.first['Fin'].toDate();
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(clasesModel.asignatura.nombre),
              IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close))
            ],
          ),
          children: [
            ListTile(
              visualDensity: VisualDensity(horizontal: 0, vertical: -4),
              leading: Icon(Icons.access_time_filled),
              title: Text(getDayName(fechaInit.weekday)),
              subtitle: Text.rich(
                TextSpan(children: [
                  TextSpan(text: 'Inicia '),
                  TextSpan(
                      text: '${fechaInit.hour}:${fechaInit.minute} ',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  TextSpan(text: ' y finaliza '),
                  TextSpan(
                    text: '${fechaFin.hour}:${fechaFin.minute}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  )
                ]),
              ),
            ),
            ListTile(
              visualDensity: VisualDensity(horizontal: 0, vertical: -4),
              leading: Icon(Icons.person),
              title: Text('Docente'),
              subtitle: Text(clasesModel.asignatura.docente.nombre +
                  " " +
                  clasesModel.asignatura.docente.apellido),
            ),
            ListTile(
              visualDensity: VisualDensity(horizontal: 0, vertical: -4),
              leading: Icon(Icons.room),
              title: Text('Salón'),
              subtitle: Text(clasesModel.asignatura.salon),
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
}
