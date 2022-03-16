import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:norkik_app/models/asignatura_model.dart';
import 'package:norkik_app/models/clases_model.dart';
import 'package:norkik_app/models/horario_model.dart';
import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/asignatura_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/clases_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/horario_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/providers/storage_shared.dart';
import 'package:provider/provider.dart';

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

  String nombreHorario = '';
  DocumentReference? referenceHorario;

  AsignaturaModel? asignaturaModel;

  List<ClasesModel> listClasesModel = [];
  Map<String, dynamic> mapColors = {};

  bool isLoading = false;
  bool isLoadingHorario = false;
  bool isLoadingTareas = false;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (mounted) {
      asignaturaModel =
          ModalRoute.of(context)!.settings.arguments as AsignaturaModel;
      _getColoresAsignatura();
      _getClasesDayHorario();
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
                    child: CircularProgressIndicator(),
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
                title: Text('Tareas'),
                // subtitle: Text(nombreHorario),
                trailing: Icon(Icons.arrow_forward_ios_rounded),
                onTap: () {},
              )
            ])));
  }
}
