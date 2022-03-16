import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:norkik_app/models/asignatura_model.dart';
import 'package:intl/intl.dart';
import 'package:norkik_app/models/nota_model.dart';
import 'package:norkik_app/pages/drawer_pages/cuaderno_pages/editar_texto_page.dart';
import 'package:norkik_app/pages/drawer_pages/cuaderno_pages/ver_texto_page.dart';
import 'package:norkik_app/providers/norkikdb_providers/asignatura_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/nota_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:provider/provider.dart';

class TextoPage extends StatefulWidget {
  AsignaturaModel asignaturaModel;
  TextoPage({Key? key, required this.asignaturaModel}) : super(key: key);

  @override
  State<TextoPage> createState() => TextoPageState();
}

class TextoPageState extends State<TextoPage> with TickerProviderStateMixin {
  TextEditingController buscarController = TextEditingController();

  bool isSearch = false;
  bool isLoading = false;
  bool isLoadingBottom = false;

  AnimationController? _animationController;
  final _scrollController = ScrollController();

  List<NotaModel> listNotas = [];

  NotaProvider notaProvider = NotaProvider();
  AsignaturaProvider asignaturaProvider = AsignaturaProvider();

  // @override
  // void setState(VoidCallback fn) {
  //   // TODO: implement setState
  //   super.setState(fn);
  //   print('objectasdas');
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      getListNotas();
    }
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // if (_textEditingController.text == '') {
        _agregarMasNotas();
        // }
      }
    });
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
    _animationController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          isSearch
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Buscar',
                        prefixIcon: buscarController.text == ''
                            ? null
                            : IconButton(
                                constraints: BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  getListNotas();
                                  setState(() {
                                    buscarController.text = '';
                                  });
                                },
                              ),
                        suffixIcon: IconButton(
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.search),
                          onPressed: () {
                            if (buscarController.text != '') {
                              _buscarNotas(buscarController.text.toLowerCase());
                            }
                          },
                        )),
                    controller: buscarController,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        getListNotas();
                      }
                      setState(() {});
                    },
                  ),
                )
              : SizedBox(),
          isLoading
              ? Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : listNotas.isEmpty
                  ? Expanded(
                      child: Center(
                          child: Text('No hay notas, para ' +
                              widget.asignaturaModel.nombre)))
                  : Expanded(
                      child: RefreshIndicator(
                      onRefresh: getListNotas,
                      child: Stack(
                        children: [
                          ListView.builder(
                            controller: _scrollController,
                            itemCount: listNotas.length,
                            itemBuilder: (context, index) {
                              return _getCardText(listNotas[index]);
                            },
                          ),
                          _getLoadingMore()
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
              label: '¿Deseas crear una nota?',
              child: const Icon(Icons.add),
              onTap: () {
                Navigator.pushNamed(context, 'crearNotaTexto',
                        arguments: widget.asignaturaModel)
                    .then((value) => getListNotas());
              }),
          SpeedDialChild(
              label: isSearch
                  ? '¿Ocultar campo de busqueda?'
                  : '¿Deseas buscar algo?',
              child: const Icon(Icons.search),
              onTap: () {
                setState(() {
                  isSearch = !isSearch;
                });
              })
        ],
      ),
    );
  }

  Widget _getCardText(NotaModel nota) {
    return GestureDetector(
      onTap: () {
        _showModalWidgetView(VerTextoPage(
          notaView: nota,
        ));
      },
      child: Container(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                horizontalTitleGap: 5,
                minLeadingWidth: 5,
                leading: Icon(Icons.text_format),
                title: Text(
                    '${nota.titulo.replaceFirst(nota.titulo.substring(0, 1), nota.titulo.substring(0, 1).toUpperCase())}: '),
                trailing: IconButton(
                    onPressed: () async {
                      if (await notaProvider.existNota(nota.idNota)) {
                        _showModalWidget(nota);
                      } else {
                        getListNotas();
                        getAlert(context, 'Nota eliminada',
                            'No existe la nota seleccionada');
                      }
                    },
                    icon: Icon(Icons.more_vert)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    nota.descripcion,
                    textAlign: TextAlign.justify,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(5, 0, 20, 10),
                alignment: Alignment.centerRight,
                child: Text(
                  DateFormat.yMMMEd('es').format(nota.fecha),
                  textAlign: TextAlign.right,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getListNotas() async {
    isLoading = true;
    listNotas.clear();
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    DocumentReference<Map<String, dynamic>> userRef = (await userProvider
        .getUserReferenceById(userProvider.userGlobal.idUsuario))!;
    DocumentReference<Map<String, dynamic>> asignaturaRef =
        (await asignaturaProvider
            .getAsignaturaReferenceById(widget.asignaturaModel.idAsignatura))!;
    List<Future<NotaModel>> listFutureNotas =
        await notaProvider.getNotas(null, 'Texto', asignaturaRef, userRef);
    for (var nota in listFutureNotas) {
      NotaModel notaModel = await nota;
      listNotas.add(notaModel);
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _agregarMasNotas() async {
    setState(() {
      isLoadingBottom = true;
    });

    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    DocumentReference<Map<String, dynamic>> userRef = (await userProvider
        .getUserReferenceById(userProvider.userGlobal.idUsuario))!;
    DocumentReference<Map<String, dynamic>> asignaturaRef =
        (await asignaturaProvider
            .getAsignaturaReferenceById(widget.asignaturaModel.idAsignatura))!;
    List<Future<NotaModel>> listFutureNotas = await notaProvider.getNotas(
        listNotas.last.fecha, 'Texto', asignaturaRef, userRef);
    for (var nota in listFutureNotas) {
      NotaModel notaModel = await nota;
      listNotas.add(notaModel);
    }

    setState(() {
      isLoadingBottom = false;
    });
    _scrollController.animateTo(_scrollController.position.pixels + 100,
        curve: Curves.fastOutSlowIn,
        duration: const Duration(milliseconds: 250));
  }

  Widget _getLoadingMore() {
    if (isLoadingBottom) {
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [CircularProgressIndicator()],
          ),
          const SizedBox(height: 15.0),
        ],
      );
    } else {
      return Container();
    }
  }

  void _showModalWidget(NotaModel notaSelected) {
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
                      Text('Editar Nota')
                    ],
                  ),
                  onPressed: () {
                    _showModalWidgetView(EditarNotaTexto(
                      notaEdit: notaSelected,
                      fucionUpdateListNotas: () {
                        setState(() {
                          getListNotas();
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
                      Text('Eliminar Nota')
                    ],
                  ),
                  onPressed: () async {
                    await notaProvider.deleteNotaTextoById(notaSelected.idNota);
                    Navigator.pop(context);
                    setState(() {
                      getListNotas();
                    });
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

  void _buscarNotas(String title) async {
    setState(() {
      isLoading = true;
    });
    listNotas.clear();

    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    DocumentReference<Map<String, dynamic>> userRef = (await userProvider
        .getUserReferenceById(userProvider.userGlobal.idUsuario))!;
    DocumentReference<Map<String, dynamic>> asignaturaRef =
        (await asignaturaProvider
            .getAsignaturaReferenceById(widget.asignaturaModel.idAsignatura))!;
    List<Future<NotaModel>> listFutureNotas = await notaProvider
        .getNotasByTitle(title, 'Texto', asignaturaRef, userRef);
    for (var nota in listFutureNotas) {
      NotaModel notaModel = await nota;
      listNotas.add(notaModel);
    }
    setState(() {
      isLoading = false;
    });
  }
}
