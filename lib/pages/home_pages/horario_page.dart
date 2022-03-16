import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:norkik_app/models/clases_model.dart';
import 'package:norkik_app/models/horario_model.dart';
import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/clases_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/horario_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/providers/storage_shared.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:provider/provider.dart';

class HorarioPage extends StatefulWidget {
  HorarioPage({Key? key}) : super(key: key);

  @override
  State<HorarioPage> createState() => _HorarioPageState();
}

class _HorarioPageState extends State<HorarioPage> {
  List<List<bool>> matrizBool =
      List.generate(23, (index) => List.generate(7, (index) => false));

  final _scrollController = ScrollController(initialScrollOffset: 360);
  int x = 0;
  int y = 0;
  HorarioProvider horarioProvider = HorarioProvider();
  ClasesProvider clasesProvider = ClasesProvider();
  StorageShared storageShared = StorageShared();
  bool isLoading = false;

  String nombreHorario = '';

  DocumentReference? referenceHorario;

  List<ClasesModel> listClasesModel = [];
  Map<String, dynamic> mapColors = {};
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (mounted) {
      _getHorarioDefault();
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5.0,
                        spreadRadius: 2.0,
                        offset: Offset(2.0, 4.0))
                  ], color: Theme.of(context).cardColor),
                  child: Column(
                    children: [
                      Text(
                        nombreHorario,
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            width: 18,
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            width: 62,
                            child: Text('Lun'),
                          ),
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.zero,
                            width: 62,
                            child: Text('Mar'),
                          ),
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.zero,
                            width: 62,
                            child: Text('Mie'),
                          ),
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.zero,
                            width: 62,
                            child: Text('Jue'),
                          ),
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.zero,
                            width: 62,
                            child: Text('Vie'),
                          ),
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.zero,
                            width: 62,
                            child: Text('Sab'),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.vertical,
                    child: Table(
                      columnWidths: {0: FractionColumnWidth(0.05)},
                      border: TableBorder(
                          verticalInside: BorderSide(width: 0.8),
                          horizontalInside: BorderSide(width: 0.5)),
                      children: _getTableRowList(),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.calendar_view_week),
        onPressed: () {
          Navigator.pushNamed(context, 'gestionarHorario')
              .then((value) => _getHorarioDefault());
        },
      ),
    );
  }

  List<Widget> _getListRow(int indexRow) {
    List<Widget> widet = [];
    for (var colDays = 0; colDays < 7; colDays++) {
      widet.add(
        GestureDetector(
          onTap: () {
            if (x == indexRow && y == colDays) {
              x = 0;
              y = 0;
              Navigator.pushNamed(context, 'crearClase',
                      arguments: [indexRow, colDays, referenceHorario])
                  .then((value) => _getHorarioDefault());
            } else {
              matrizBool[x][y] = false;
              x = indexRow;
              y = colDays;
            }
            setState(() {
              matrizBool[indexRow][colDays] = true;
            });
          },
          child: Container(
              decoration: BoxDecoration(),
              height: 60,
              child: colDays == 0
                  ? Text(
                      indexRow.toString(),
                      textAlign: TextAlign.right,
                    )
                  : _getWidgetAsignaturas(indexRow, colDays)),
        ),
      );
    }

    return widet;
  }

  List<TableRow> _getTableRowList() {
    List<TableRow> widetRow = [];
    for (var i = 0; i <= 22; i++) {
      widetRow.add(TableRow(children: _getListRow(i)));
    }
    return widetRow;
  }

  void _getHorarioDefault() async {
    listClasesModel.clear();
    matrizBool =
        List.generate(24, (index) => List.generate(7, (index) => false));
    setState(() {
      isLoading = true;
    });
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

    List<Future<ClasesModel>> listAuxClases =
        await clasesProvider.getClasesByHorario(
            referenceHorario as DocumentReference<Map<String, dynamic>>);

    for (var itemClases in listAuxClases) {
      ClasesModel clasesModel = await itemClases;
      listClasesModel.add(clasesModel);
    }
    mapColors = await storageShared.obtenerColoresAsignaturaList();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  _getWidgetAsignaturas(int indexRow, int colDays) {
    Widget asignaturaWidget = Icon(
      Icons.add,
      size: 40,
      color: Theme.of(context).appBarTheme.foregroundColor,
    );

    DateTime? inicio;
    DateTime? fin;
    int? top;
    int? altura;

    ClasesModel claseModelSelect = ClasesModel.clasesModelNoData();
    List<int> list = [];
    List<Widget> addContainerAsignatura = [];
    for (var itemClases in listClasesModel) {
      for (var itemDay in itemClases.fechaInicioFin) {
        if (isDay(indexRow, colDays, itemDay['Inicio'].toDate(),
            itemDay['Fin'].toDate())) {
          inicio = itemDay['Inicio'].toDate();
          fin = itemDay['Fin'].toDate();
          matrizBool[indexRow][colDays] = true;
          claseModelSelect = itemClases;
          asignaturaWidget = Text(
            itemClases.asignatura.nombre,
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Theme.of(context).appBarTheme.foregroundColor),
          );
          DateTime tiempoRow = DateTime(2021, 12, 4, indexRow + 1);
          if (inicio!.hour == indexRow && fin!.hour == indexRow) {
            top = inicio.minute;
            altura = fin.minute - inicio.minute;
          } else if (inicio.hour == indexRow) {
            DateTime tiempoAux = inicio;
            tiempoAux = tiempoRow.subtract(
                Duration(hours: tiempoAux.hour, minutes: tiempoAux.minute));
            top = inicio.minute;

            if (tiempoAux.hour == 1) {
              altura = 60;
            } else {
              altura = tiempoAux.minute;
            }
          } else if (fin!.hour == indexRow) {
            altura = fin.minute;
            top = 0;
          } else if (inicio.hour < indexRow && fin.hour > indexRow) {
            top = 0;

            altura = 60;
          }

          //
          DateTime initShowDialog = inicio;
          DateTime finShowDialog = fin!;
          ClasesModel claseShowDialog = claseModelSelect;
          addContainerAsignatura.add(
            Positioned(
              top: top!.toDouble(),
              right: 0,
              left: 0,
              // height: 60,
              child: GestureDetector(
                onTap: () async {
                  if (await clasesProvider
                      .existClass(claseShowDialog.idClase)) {
                    _showAsignaturaDetail(
                        claseShowDialog, initShowDialog, finShowDialog);
                  } else {
                    getAlert(context, 'No existe',
                        'La clase seleccionada no existe');
                    _getHorarioDefault();
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color:
                        mapColors[claseModelSelect.asignatura.idAsignatura] !=
                                null
                            ? Color(mapColors[claseModelSelect
                                .asignatura.idAsignatura
                                .toString()])
                            : Theme.of(context).primaryColor,
                  ),
                  height: altura!.toDouble(),
                  child: asignaturaWidget,
                ),
              ),
            ),
          );
        }
      }
    }

    return matrizBool[indexRow][colDays]
        ? inicio != null && top != null && altura != null
            ? Stack(
                children: addContainerAsignatura,
              )
            : Container(
                margin: EdgeInsets.all(1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Theme.of(context).primaryColor,
                ),
                height: 60,
                child: asignaturaWidget,
              )
        : SizedBox();
  }

  bool isDay(int rowHoras, int colDays, DateTime timeInicio, DateTime timeFin) {
    //     DateTime time = itemDay['Inicio'].toDate();
    // print(time.weekday == colDays);
    if ((timeInicio.weekday == colDays && rowHoras >= timeInicio.hour) &&
        (timeInicio.weekday == colDays && rowHoras < timeFin.hour)) {
      return true;
    } else if ((timeInicio.weekday == colDays && rowHoras >= timeInicio.hour) &&
        (timeInicio.weekday == colDays && rowHoras <= timeFin.hour) &&
        (timeInicio.weekday == colDays && timeFin.minute >= 1)) {
      return true;
    } else {
      return false;
    }
  }

  _showAsignaturaDetail(ClasesModel clasesModel, DateTime init, DateTime fin) {
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
              title: Text(getDayName(init.weekday)),
              subtitle: Text.rich(
                TextSpan(children: [
                  TextSpan(text: 'Inicia '),
                  TextSpan(
                      text: '${init.hour}:${init.minute} ',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  TextSpan(text: ' y finaliza '),
                  TextSpan(
                    text: '${fin.hour}:${fin.minute}',
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
            Wrap(
              alignment: WrapAlignment.spaceAround,
              children: [
                TextButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Editar')
                    ],
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, 'editarClase', arguments: [
                      init,
                      fin,
                      clasesModel,
                      referenceHorario
                    ]).then((value) {
                      Navigator.pop(context);
                      _getHorarioDefault();
                    });
                  },
                ),
                TextButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Quitar esta clase')
                    ],
                  ),
                  onPressed: () {
                    clasesProvider.removeClase(
                        clasesModel.idClase, {'Inicio': init, 'Fin': fin});
                    Navigator.pop(context);
                    _getHorarioDefault();
                  },
                ),
                TextButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_forever),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Eliminar todas las clases')
                    ],
                  ),
                  onPressed: () async {
                    clasesProvider.deleteClase(clasesModel.idClase);
                    mapColors =
                        await storageShared.obtenerColoresAsignaturaList();
                    mapColors.remove(clasesModel.asignatura.idAsignatura);
                    await storageShared.agregarColoresAsignaturaList(mapColors);
                    Navigator.pop(context);
                    _getHorarioDefault();
                  },
                )
              ],
            )
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
}
