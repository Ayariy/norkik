import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:norkik_app/models/asignatura_model.dart';
import 'package:norkik_app/models/nota_model.dart';
import 'package:norkik_app/pages/drawer_pages/cuaderno_pages/editar_imagen_page.dart';
import 'package:norkik_app/providers/norkikdb_providers/asignatura_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/nota_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ImagenPage extends StatefulWidget {
  AsignaturaModel asignaturaModel;
  ImagenPage({Key? key, required this.asignaturaModel}) : super(key: key);

  @override
  State<ImagenPage> createState() => ImagenPageState();
}

class ImagenPageState extends State<ImagenPage> with TickerProviderStateMixin {
  NotaProvider notaProvider = NotaProvider();
  AsignaturaProvider asignaturaProvider = AsignaturaProvider();

  bool isSearch = false;

  TextEditingController buscarController = TextEditingController();

  bool isLoading = false;
  bool isLoadingBottom = false;

  AnimationController? _animationController;
  final _scrollController = ScrollController();

  List<NotaModel> listNotas = [];

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
        vsync: this, duration: const Duration(milliseconds: 4));
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
                          child: Text('No hay fotos, para ' +
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
                              return _getCardImg(listNotas[index]);
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
              label: '¿Deseas crear una imagen?',
              child: const Icon(Icons.image),
              onTap: () {
                Navigator.pushNamed(context, 'crearNotaImg',
                        arguments: widget.asignaturaModel)
                    .then((value) => getListNotas());
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
        await notaProvider.getNotas(null, 'Imagen', asignaturaRef, userRef);
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
        listNotas.last.fecha, 'Imagen', asignaturaRef, userRef);
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
        .getNotasByTitle(title, 'Imagen', asignaturaRef, userRef);
    for (var nota in listFutureNotas) {
      NotaModel notaModel = await nota;
      listNotas.add(notaModel);
    }
    setState(() {
      isLoading = false;
    });
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

  Widget _getCardImg(NotaModel nota) {
    return GestureDetector(
      onTap: () {},
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
                leading: Icon(Icons.mic),
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
              Hero(
                tag: nota.file,
                child: GestureDetector(
                  onTap: () {
                    _showModalWidgetView(MostrarFoto(foto: nota.file));
                  },
                  child: FadeInImage(
                    image: _getImagenPost(nota.file),
                    placeholder: const AssetImage('assets/loadingUno.gif'),
                    fadeInDuration: const Duration(milliseconds: 200),
                    height: 200.0,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(5, 10, 20, 10),
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

  ImageProvider _getImagenPost(String imagenUrl) {
    if (imagenUrl == '' || imagenUrl == 'no-img') {
      return const AssetImage('assets/image_coming_soon.jpg');
    } else {
      return CachedNetworkImageProvider(imagenUrl);
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
                      Text('Editar título de nota')
                    ],
                  ),
                  onPressed: () {
                    _showModalWidgetView(EditarImgPage(
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
                      Text('Eliminar imagen')
                    ],
                  ),
                  onPressed: () async {
                    await notaProvider.deleteNotaTextoById(notaSelected.idNota);
                    await notaProvider.deleteFilePost(notaSelected.file);
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
}

class MostrarFoto extends StatelessWidget {
  final String foto;

  MostrarFoto({Key? key, required this.foto}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: foto != '' || foto != 'no-img'
          ? Hero(
              tag: foto,
              child: Center(
                child: GestureDetector(
                  child: InteractiveViewer(
                      maxScale: 5.0,
                      minScale: 0.1,
                      child: FadeInImage(
                        image: _getImagenPost(foto),
                        placeholder: const AssetImage('assets/loadingUno.gif'),
                        fadeInDuration: const Duration(milliseconds: 200),
                        // height: 200.0,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      )),
                ),
              ),
            )
          : Center(
              child: Text('No se ha seleccionado la foto'),
            ),
    );
  }

  ImageProvider _getImagenPost(String imagenUrl) {
    if (imagenUrl == '' || imagenUrl == 'no-img') {
      return const AssetImage('assets/image_coming_soon.jpg');
    } else {
      return CachedNetworkImageProvider(imagenUrl);
    }
  }
}
