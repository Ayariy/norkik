import 'package:flutter/material.dart';
import 'package:norkik_app/models/asignatura_model.dart';

import 'package:norkik_app/pages/drawer_pages/cuaderno_pages/img_page.dart';
import 'package:norkik_app/pages/drawer_pages/cuaderno_pages/sonido_page.dart';
import 'package:norkik_app/pages/drawer_pages/cuaderno_pages/texto_page.dart';
import 'package:norkik_app/providers/norkikdb_providers/asignatura_provider.dart';
import 'package:norkik_app/providers/storage_shared.dart';

class NotasPage extends StatefulWidget {
  const NotasPage({Key? key}) : super(key: key);

  @override
  State<NotasPage> createState() => _NotasPageState();
}

class _NotasPageState extends State<NotasPage>
    with SingleTickerProviderStateMixin {
  StorageShared storageShared = StorageShared();
  AsignaturaProvider asignaturaProvider = AsignaturaProvider();

  Map<String, dynamic> mapColors = {};
  List<AsignaturaModel> listAsignatura = [];
  int selectedPage = 0;
  TabController? tabController;
  AsignaturaModel? asignaturaSelected;

  bool isLoading = false;

  GlobalKey<TextoPageState> globalKeyTxt = GlobalKey();
  GlobalKey<SonidoPageState> globalKeySound = GlobalKey();
  GlobalKey<SonidoPageState> globalKeyImg = GlobalKey();
  @override
  void initState() {
    super.initState();
    tabController =
        TabController(length: 3, initialIndex: selectedPage, vsync: this);
    tabController!.addListener(() {
      setState(() {});
    });
    if (mounted) {
      _getListAsignaturas();
    }
  }

  // @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   super.didChangeDependencies();
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            appBar: AppBar(
              title: Text('Notas-Cuaderno digital'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : listAsignatura.isNotEmpty
            ? Scaffold(
                appBar: AppBar(
                    title: Text('Notas - Cuaderno digital'),
                    bottom: PreferredSize(
                      child: isLoading
                          ? CircularProgressIndicator()
                          : _crearDropdown(),
                      preferredSize: Size.fromHeight(35.0),
                    )),
                body: isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Column(
                        children: [
                          Material(
                            child: TabBar(
                              labelColor:
                                  Theme.of(context).textTheme.bodyText1!.color,
                              controller: tabController,
                              tabs: [
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.text_format),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        decoration: BoxDecoration(
                                            color: tabController!.index == 0
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(context).cardColor,
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 5.0,
                                                  spreadRadius: 2.0,
                                                  offset: Offset(2.0, 4.0))
                                            ],
                                            borderRadius:
                                                BorderRadius.horizontal(
                                                    right:
                                                        Radius.circular(10))),
                                        child: Text(
                                          'Texto',
                                          style: TextStyle(
                                              color: tabController!.index == 0
                                                  ? Colors.white
                                                  : null),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.mic_sharp),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        decoration: BoxDecoration(
                                            color: tabController!.index == 1
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(context).cardColor,
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 5.0,
                                                  spreadRadius: 2.0,
                                                  offset: Offset(2.0, 4.0))
                                            ],
                                            borderRadius:
                                                BorderRadius.horizontal(
                                                    right:
                                                        Radius.circular(10))),
                                        child: Text(
                                          'Audio',
                                          style: TextStyle(
                                              color: tabController!.index == 1
                                                  ? Colors.white
                                                  : null),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .color,
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        decoration: BoxDecoration(
                                            color: tabController!.index == 2
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(context).cardColor,
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 5.0,
                                                  spreadRadius: 2.0,
                                                  offset: Offset(2.0, 4.0))
                                            ],
                                            borderRadius:
                                                BorderRadius.horizontal(
                                                    right:
                                                        Radius.circular(10))),
                                        child: Text(
                                          'Fotos',
                                          style: TextStyle(
                                              color: tabController!.index == 2
                                                  ? Colors.white
                                                  : null),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                              child: TabBarView(
                            controller: tabController,
                            children: [
                              TextoPage(
                                key: globalKeyTxt,
                                asignaturaModel: asignaturaSelected!,
                              ),
                              SonidoPage(
                                  key: globalKeySound,
                                  asignaturaModel: asignaturaSelected!),
                              ImagenPage(
                                key: globalKeyImg,
                                asignaturaModel: asignaturaSelected!,
                              )
                            ],
                          ))
                        ],
                      ),
              )
            : Scaffold(
                appBar: AppBar(
                  title: Text('Notas - Cuaderno digital'),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Center(
                    child: Text(
                        'Por el momento no hay asignaturas asignadas al horario para crear su cuaderno digital'),
                  ),
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
  }

  Widget _crearDropdown() {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
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
                if (tabController!.index == 0) {
                  globalKeyTxt.currentState!.getListNotas();
                } else if (tabController!.index == 1) {
                  globalKeySound.currentState!.getListNotas();
                } else {}
                setState(() {
                  asignaturaSelected = listAsignatura
                      .firstWhere((element) => element.idAsignatura == op);
                });
              },
            ),
          ),
          Icon(Icons.calendar_today_outlined),
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
}
