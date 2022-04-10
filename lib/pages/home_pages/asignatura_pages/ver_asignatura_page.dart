import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:norkik_app/models/asignatura_model.dart';
import 'package:norkik_app/models/clases_model.dart';
import 'package:norkik_app/models/horario_model.dart';
import 'package:norkik_app/models/tarea_model.dart';
import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/asignatura_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/clases_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/horario_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/tarea_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/providers/storage_shared.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/notification.dart';
import '../../drawer_pages/tarea_pages/editar_tarea_page.dart';
import '../../drawer_pages/tarea_pages/ver_tarea_page.dart';

class VerAsignatura extends StatefulWidget {
  VerAsignatura({Key? key}) : super(key: key);

  @override
  State<VerAsignatura> createState() => _VerAsignaturaState();
}

class _VerAsignaturaState extends State<VerAsignatura> {
  StorageShared storageShared = StorageShared();
  HorarioProvider horarioProvider = HorarioProvider();
  ClasesProvider clasesProvider = ClasesProvider();
  AsignaturaProvider asignaturaProvider = AsignaturaProvider();
  TareaProvider tareaProvider = TareaProvider();

  String nombreHorario = '';
  DocumentReference? referenceHorario;

  AsignaturaModel? asignaturaModel;

  List<ClasesModel> listClasesModel = [];
  List<TareaModel> listTareas = [];
  Map<String, dynamic> mapColors = {};

  bool isLoading = false;
  bool isLoadingHorario = false;
  bool isLoadingTareas = false;
  bool isLoadingAsignatura = false;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (mounted) {
      asignaturaModel =
          ModalRoute.of(context)!.settings.arguments as AsignaturaModel;
      _getColoresAsignatura();
      _getClasesDayHorario();
      _getTareasAsignatura();
    }
  }

  @override
  Widget build(BuildContext context) {
    return asignaturaModel != null
        ? Scaffold(
            appBar: AppBar(
              title: Text(asignaturaModel!.nombre),
              actions: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.class_),
                )
              ],
            ),
            body: SingleChildScrollView(
                child: _getCardsAsignaturaDetails(asignaturaModel!)),
          )
        : const Scaffold(
            body: Center(
              child: Text('No se ha seleccionado la asignatura a mostrar'),
            ),
          );
  }

  _getCardsAsignaturaDetails(AsignaturaModel asignaturaModel) {
    return Column(
      children: [
        _cardDetailAsignatura(asignaturaModel),
        _cardClasesAsignatura(asignaturaModel),
        _cardTareasAsignatura(asignaturaModel)
      ],
    );
  }

  Container _cardDetailAsignatura(AsignaturaModel asignaturaModel) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Theme.of(context).cardColor,
          boxShadow: const <BoxShadow>[
            BoxShadow(
                color: Colors.black26,
                blurRadius: 5.0,
                spreadRadius: 2.0,
                offset: Offset(2.0, 4.0))
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: Column(
          children: [
            ListTile(
              leading: Hero(
                tag: asignaturaModel.docente.idDocente,
                child: CircleAvatar(
                  child: Text(asignaturaModel.docente.nombre[0] +
                      asignaturaModel.docente.apellido[0]),
                ),
              ),
              title: Text(asignaturaModel.docente.nombre +
                  " " +
                  asignaturaModel.docente.apellido),
              subtitle: Text(asignaturaModel.docente.email),
              trailing: Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                Navigator.pushNamed(context, 'verDocente',
                    arguments: asignaturaModel.docente);
              },
            ),
            ListTile(
              leading: Icon(Icons.room),
              title: Text('Salón'),
              subtitle: Text(asignaturaModel.salon),
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: Text('Descripción de la asignatura'),
              subtitle: Text(asignaturaModel.descripcion),
            ),
            ListTile(
              leading: Icon(
                Icons.color_lens,
                color: mapColors[asignaturaModel.idAsignatura] != null
                    ? Color(mapColors[asignaturaModel.idAsignatura])
                    : null,
              ),
              title: Text('Color'),
              subtitle: mapColors[asignaturaModel.idAsignatura] != null
                  ? Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color:
                              Color(mapColors[asignaturaModel.idAsignatura])),
                      // width: MediaQuery.of(context).size.width * 0.12,
                      height: 15,
                    )
                  : Text('Color sin establecer'),
            ),
          ],
        ),
      ),
    );
  }

  void _getColoresAsignatura() async {
    isLoading = true;
    mapColors = await storageShared.obtenerColoresAsignaturaList();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  _cardClasesAsignatura(AsignaturaModel asignaturaModel) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Theme.of(context).cardColor,
          boxShadow: const <BoxShadow>[
            BoxShadow(
                color: Colors.black26,
                blurRadius: 5.0,
                spreadRadius: 2.0,
                offset: Offset(2.0, 4.0))
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.calendar_view_week),
              title: Text('Horario de clases'),
              subtitle: Text(nombreHorario),
              trailing: Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                Navigator.pushNamed(context, 'horario').then((value) {
                  _getColoresAsignatura();
                  _getClasesDayHorario();
                });
              },
            ),
            isLoadingHorario
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 25,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: mapColors[asignaturaModel.idAsignatura] !=
                                      null
                                  ? _isDay(1)
                                      ? Color(mapColors[
                                          asignaturaModel.idAsignatura])
                                      : null
                                  : null),
                          child: Text(
                            'Lunes',
                            style: TextStyle(
                                color:
                                    mapColors[asignaturaModel.idAsignatura] !=
                                            null
                                        ? _isDay(1)
                                            ? Theme.of(context)
                                                .appBarTheme
                                                .foregroundColor
                                            : null
                                        : null),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: mapColors[asignaturaModel.idAsignatura] !=
                                      null
                                  ? _isDay(2)
                                      ? Color(mapColors[
                                          asignaturaModel.idAsignatura])
                                      : null
                                  : null),
                          child: Text(
                            'Martes',
                            style: TextStyle(
                                color:
                                    mapColors[asignaturaModel.idAsignatura] !=
                                            null
                                        ? _isDay(2)
                                            ? Theme.of(context)
                                                .appBarTheme
                                                .foregroundColor
                                            : null
                                        : null),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: mapColors[asignaturaModel.idAsignatura] !=
                                      null
                                  ? _isDay(3)
                                      ? Color(mapColors[
                                          asignaturaModel.idAsignatura])
                                      : null
                                  : null),
                          child: Text(
                            'Miércoles',
                            style: TextStyle(
                                color:
                                    mapColors[asignaturaModel.idAsignatura] !=
                                            null
                                        ? _isDay(3)
                                            ? Theme.of(context)
                                                .appBarTheme
                                                .foregroundColor
                                            : null
                                        : null),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: mapColors[asignaturaModel.idAsignatura] !=
                                      null
                                  ? _isDay(4)
                                      ? Color(mapColors[
                                          asignaturaModel.idAsignatura])
                                      : null
                                  : null),
                          child: Text(
                            'Jueves',
                            style: TextStyle(
                                color:
                                    mapColors[asignaturaModel.idAsignatura] !=
                                            null
                                        ? _isDay(4)
                                            ? Theme.of(context)
                                                .appBarTheme
                                                .foregroundColor
                                            : null
                                        : null),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: mapColors[asignaturaModel.idAsignatura] !=
                                      null
                                  ? _isDay(5)
                                      ? Color(mapColors[
                                          asignaturaModel.idAsignatura])
                                      : null
                                  : null),
                          child: Text(
                            'Viernes',
                            style: TextStyle(
                                color:
                                    mapColors[asignaturaModel.idAsignatura] !=
                                            null
                                        ? _isDay(5)
                                            ? Theme.of(context)
                                                .appBarTheme
                                                .foregroundColor
                                            : null
                                        : null),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: mapColors[asignaturaModel.idAsignatura] !=
                                      null
                                  ? _isDay(6)
                                      ? Color(mapColors[
                                          asignaturaModel.idAsignatura])
                                      : null
                                  : null),
                          child: Text(
                            'Sábado',
                            style: TextStyle(
                                color:
                                    mapColors[asignaturaModel.idAsignatura] !=
                                            null
                                        ? _isDay(6)
                                            ? Theme.of(context)
                                                .appBarTheme
                                                .foregroundColor
                                            : null
                                        : null),
                          ),
                        ),
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }

  _getClasesDayHorario() async {
    isLoadingHorario = true;
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
      nombreHorario = 'Horario de clases';
    } else {
      for (var itemHorario in listHorario) {
        HorarioModel horario = await itemHorario;
        if (horario.activo) {
          nombreHorario = horario.nombre;
          referenceHorario =
              await horarioProvider.getHorarioReferenceById(horario.idHorario);
        }
      }
    }
    if (referenceHorario == null) {
      HorarioModel horarioM = await listHorario.first;
      nombreHorario = horarioM.nombre;
      horarioM.activo = true;
      horarioProvider.updateHorario(
          horarioM,
          (await userProvider
              .getUserReferenceById(userProvider.userGlobal.idUsuario))!);
      referenceHorario =
          await horarioProvider.getHorarioReferenceById(horarioM.idHorario);
    }

    if (asignaturaModel != null) {
      DocumentReference<Map<String, dynamic>>? docRefAsignatura =
          await asignaturaProvider
              .getAsignaturaReferenceById(asignaturaModel!.idAsignatura);
      List<Future<ClasesModel>> listAuxClases =
          await clasesProvider.getClasesByHorarioAndAsignatura(
              referenceHorario as DocumentReference<Map<String, dynamic>>,
              docRefAsignatura!);

      for (var itemClases in listAuxClases) {
        ClasesModel clasesModel = await itemClases;
        listClasesModel.add(clasesModel);
      }

      if (mounted) {
        setState(() {
          isLoadingHorario = false;
        });
      }
    }
  }

  bool _isDay(int dayNum) {
    for (var itemClases in listClasesModel) {
      for (var itemDay in itemClases.fechaInicioFin) {
        DateTime fecha = itemDay['Inicio'].toDate();
        if (fecha.weekday == dayNum) {
          return true;
        }
      }
    }

    return false;
  }

  _cardTareasAsignatura(AsignaturaModel asignaturaModel) {
    return Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Theme.of(context).cardColor,
            boxShadow: const <BoxShadow>[
              BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5.0,
                  spreadRadius: 2.0,
                  offset: Offset(2.0, 4.0))
            ]),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: Column(children: [
              ListTile(
                leading: Icon(Icons.home_work),
                title: Text('Todas las tareas'),
                // subtitle: Text(nombreHorario),
                trailing: Icon(Icons.arrow_forward_ios_rounded),
                onTap: () {
                  Navigator.pushNamed(context, 'tareas').then((value) {
                    setState(() {
                      _getTareasAsignatura();
                    });
                  });
                },
              ),
              isLoadingTareas
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                      child: const CircularProgressIndicator(),
                    )
                  : listTareas.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                          child: Text('No hay tareas para esta asignatura'),
                        )
                      : Column(
                          children: _getWidgetListTareas(),
                        )
            ])));
  }

  void _getTareasAsignatura() async {
    isLoadingTareas = true;
    if (asignaturaModel != null) {
      listTareas.clear();
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      DocumentReference<Map<String, dynamic>> userRef = (await userProvider
          .getUserReferenceById(userProvider.userGlobal.idUsuario))!;
      // print(listAsignatura.length);
      DocumentReference<Map<String, dynamic>> asignaturaRef =
          (await asignaturaProvider
              .getAsignaturaReferenceById(asignaturaModel!.idAsignatura))!;
      List<Future<TareaModel>> listFutureTareas = await tareaProvider
          .getAllTareasByUserAsignatura(userRef, asignaturaRef);
      for (var tarea in listFutureTareas) {
        TareaModel tareaModel = await tarea;
        listTareas.add(tareaModel);
      }
    }
    setState(() {
      isLoadingTareas = false;
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
                      isLoadingTareas = true;
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
                    Navigator.pop(context);

                    // setState(() {
                    _getTareasAsignatura();
                    // isLoadingTareas = false;
                    // });
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
                          _getTareasAsignatura();
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
                      _getTareasAsignatura();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          );
        });
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

  _getWidgetListTareas() {
    List<Widget> widgetList = [];
    for (var tarea in listTareas) {
      widgetList.add(ListTile(
        leading: Column(
          children: [
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
          ],
        ),
        title: Text(
          tarea.nombre + ' (${tarea.realizado ? 'Realizado' : 'Sin realizar'})',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          DateFormat.yMMMEd('es').format(tarea.fecha),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: Icon(FontAwesomeIcons.ellipsisV),
          onPressed: () async {
            if (await tareaProvider.existTarea(tarea.idTarea)) {
              _showModalWidget(tarea);
            } else {
              getAlert(
                  context, 'Tarea Inexistente', 'La tarea pulsada no existe');
            }
          },
        ),
        onTap: () {
          _showModalWidgetView(VerTareaPage(tareaModel: tarea));
        },
      ));
    }
    return widgetList;
  }
}
