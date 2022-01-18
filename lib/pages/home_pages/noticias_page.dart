import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:norkik_app/models/noticia_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/noticia_provider.dart';
import 'package:intl/intl.dart';
import 'package:norkik_app/providers/storage_shared.dart';

class NoticiasPage extends StatefulWidget {
  const NoticiasPage({Key? key}) : super(key: key);

  @override
  State<NoticiasPage> createState() => _NoticiasPageState();
}

class _NoticiasPageState extends State<NoticiasPage>
    with TickerProviderStateMixin {
  List<NoticiaModel> listNoticias = [];
  NoticiaProvider noticiaProvider = NoticiaProvider();
  final _scrollController = ScrollController();
  bool isLoading = false;
  bool isLoadingBottom = false;
  int _currIndexIcon = 0;

  final TextEditingController _textEditingController = TextEditingController();
  AnimationController? _animationController;

  StorageShared storageShared = StorageShared();
  List<String> listFavoritos = [];
  @override
  void initState() {
    super.initState();
    if (mounted) {
      _cargarListFavoritos();
      _agregarNoticias();
    }
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_textEditingController.text == '') {
          _agregarMasNoticias();
        }
      }
    });
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
    _animationController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _getSearchWidget(),
          isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()))
              : listNoticias.isEmpty
                  ? Container(
                      margin: const EdgeInsets.symmetric(vertical: 50),
                      alignment: Alignment.center,
                      child: const Text('No existe información relacionada'))
                  : Expanded(
                      child: RefreshIndicator(
                        onRefresh: _agregarNoticias,
                        child: Stack(
                          children: [
                            ListView.builder(
                                controller: _scrollController,
                                itemCount: listNoticias.length,
                                itemBuilder: (context, index) {
                                  return FadeInDown(
                                      child: _cardNoticiaPost(
                                          context, listNoticias[index]));
                                }),
                            _getLoadingMore(),
                          ],
                        ),
                      ),
                    ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.star),
        onPressed: () {
          Navigator.pushNamed(context, 'noticiasFavoritos').then((value) {
            _agregarNoticias();

            _cargarListFavoritos();
          });
        },
      ),
    );
  }

  Widget _cardNoticiaPost(context, NoticiaModel noticiaItem) {
    final Size sizeScreen = MediaQuery.of(context).size;
    final card = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //ENCABEZADO DEL CARD HEADER
        _cardImageHeader(sizeScreen, noticiaItem),
        //DESCRIPCIÒN DEL CARD NOTICIA
        _cardBody(noticiaItem),
      ],
    );

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, 'noticia', arguments: noticiaItem);
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
          child: card,
        ),
      ),
    );
  }

  _cardBody(NoticiaModel noticiaItem) {
    if (listFavoritos.isNotEmpty) {
      bool boolfavItem = listFavoritos.any((element) {
        return noticiaItem.idNoticia == element;
      });
      noticiaItem.isFavorite = boolfavItem ? true : false;
    }

    return Column(
      children: [
        Container(
            padding: const EdgeInsets.all(10.0),
            child: Text(noticiaItem.descripcion,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                textAlign: TextAlign.justify)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () async {
                  if (noticiaItem.isFavorite) {
                    listFavoritos.remove(noticiaItem.idNoticia);
                    storageShared.agregarFavoritosStorageList(listFavoritos);
                    setState(() {
                      noticiaItem.isFavorite = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(snackBarFavorite(
                        'Se ha removido de favoritos', Icons.remove_circle));
                  } else {
                    listFavoritos.add(noticiaItem.idNoticia);
                    storageShared.agregarFavoritosStorageList(listFavoritos);
                    setState(() {
                      noticiaItem.isFavorite = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(snackBarFavorite(
                        'Se ha agregado a favoritos', Icons.add_circle));
                  }
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (widget, animation) {
                    return RotationTransition(
                      turns: widget.key == const ValueKey('iconFav1')
                          ? Tween<double>(begin: 1, end: 0).animate(animation)
                          : Tween<double>(begin: 0, end: 1).animate(animation),
                      child: ScaleTransition(scale: animation, child: widget),
                    );
                  },
                  child: !noticiaItem.isFavorite
                      ? const Icon(Icons.star_border, key: ValueKey('iconFav1'))
                      : const Icon(
                          Icons.star,
                          key: ValueKey('iconFav2'),
                        ),
                ),
                color: Colors.yellow.shade800,
                iconSize: 40,
              ),
              Text(DateFormat.yMMMEd('es').format(noticiaItem.fecha))
            ],
          ),
        ),
      ],
    );
  }

  SnackBar snackBarFavorite(String text, IconData icon) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    return SnackBar(
      duration: const Duration(seconds: 1),
      backgroundColor: Theme.of(context).primaryColor,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Theme.of(context).appBarTheme.foregroundColor),
          ),
        ],
      ),
    );
  }

  Stack _cardImageHeader(Size sizeScreen, NoticiaModel noticiaItem) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        Hero(
          tag: noticiaItem.idNoticia,
          child: FadeInImage(
            image: _getImagenNoticia(noticiaItem.imagen),
            placeholder: AssetImage('assets/loadingUno.gif'),
            fadeInDuration: Duration(milliseconds: 200),
            height: 200.0,
            width: sizeScreen.width,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Colors.black.withAlpha(0),
              Colors.black38,
              Colors.black45,
              Colors.black54,
              Colors.black54
            ],
          )),
          width: sizeScreen.width,
          height: 50,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              noticiaItem.titulo,
              style: TextStyle(
                  color: Colors.white, overflow: TextOverflow.ellipsis),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    );
  }

  Future<void> _agregarNoticias() async {
    isLoading = true;

    // await Future.delayed(Duration(seconds: 5), () async {
    listNoticias = await noticiaProvider.getNoticias(null);
    // });

    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _agregarMasNoticias() async {
    setState(() {
      isLoadingBottom = true;
    });

    List<NoticiaModel> listNoticiasAux =
        await noticiaProvider.getNoticias(listNoticias.last.fecha);
    listNoticiasAux.forEach((element) {
      listNoticias.add(element);
    });

    setState(() {
      isLoadingBottom = false;
    });
    _scrollController.animateTo(_scrollController.position.pixels + 100,
        curve: Curves.fastOutSlowIn,
        duration: const Duration(milliseconds: 250));
  }

  Future<void> _buscarNoticias(String title) async {
    isLoading = true;
    setState(() {});
    listNoticias = await noticiaProvider.getNoticiasByTitle(title);

    isLoading = false;
    setState(() {});
  }

  ImageProvider _getImagenNoticia(String imagenUrl) {
    if (imagenUrl == '' || imagenUrl == 'no-img') {
      return const AssetImage('assets/image_coming_soon.jpg');
    } else {
      return CachedNetworkImageProvider(imagenUrl);
    }
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

  Widget _getSearchWidget() {
    return ListTile(
      title: TextField(
        onChanged: (value) {
          if (value.isEmpty) {
            _agregarNoticias();
            _currIndexIcon = 0;
          }
          setState(() {});
        },
        controller: _textEditingController,
        decoration: InputDecoration(
          prefixIcon: _getPrefixIcon(),
          suffixIcon: IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (widget, animation) {
                return RotationTransition(
                  turns: widget.key == ValueKey('icon1')
                      ? Tween<double>(begin: 1, end: 0).animate(animation)
                      : Tween<double>(begin: 0, end: 1).animate(animation),
                  child: ScaleTransition(scale: animation, child: widget),
                );
              },
              child: _currIndexIcon == 0
                  ? const Icon(Icons.search, key: ValueKey('icon1'))
                  : const Icon(
                      Icons.saved_search_sharp,
                      key: ValueKey('icon2'),
                    ),
            ),
            onPressed: () {
              if (_textEditingController.text != '') {
                _buscarNoticias(_textEditingController.text.toUpperCase());
                _currIndexIcon = 1;
              }
            },
          ),
          hintText: 'Buscar por título',
        ),
      ),
    );
  }

  Widget _getPrefixIcon() {
    if (_textEditingController.text != '') {
      return IconButton(
          onPressed: () {
            _textEditingController.text = '';
            _agregarNoticias();
            _currIndexIcon = 0;
          },
          icon: const Icon(Icons.close));
    } else {
      return const Icon(Icons.text_fields);
    }
  }

  void _cargarListFavoritos() async {
    listFavoritos = await storageShared.obtenerFavoritosStorageList();
  }
}
