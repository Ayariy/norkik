import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:norkik_app/models/like_post_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/like_post_provider.dart';
import 'package:intl/intl.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class ComunidadPage extends StatefulWidget {
  const ComunidadPage({Key? key}) : super(key: key);

  @override
  State<ComunidadPage> createState() => _ComunidadPageState();
}

class _ComunidadPageState extends State<ComunidadPage>
    with TickerProviderStateMixin {
  bool selectedIconButtonLike = true;

  List<LikePostModel> listLikePost = [];
  List<bool> listIsFavoriteIcon = [];

  LikePostProvider likePostProvider = LikePostProvider();
  final _scrollController = ScrollController();
  bool isLoading = false;
  bool isLoadingBottom = false;
  bool isLoadingFavorite = false;
  int _currIndexIcon = 0;
  bool _isWidgetSearch = false;

  final TextEditingController _textEditingController = TextEditingController();
  AnimationController? _animationController;
  GlobalKey _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _agregarLikePost();
    }
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // if (_textEditingController.text == '') {
        _agregarMasLikePost();
        // }
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
        key: _scaffoldKey,
        body: Column(
          children: [
            _isWidgetSearch
                ? FadeIn(
                    child: _getSearchWidget(),
                  )
                : SizedBox(),
            isLoading
                ? const Expanded(
                    child: Center(child: CircularProgressIndicator()))
                : listLikePost.isEmpty
                    ? Container(
                        margin: const EdgeInsets.symmetric(vertical: 50),
                        alignment: Alignment.center,
                        child: const Text('No existe información relacionada'))
                    : Expanded(
                        child: RefreshIndicator(
                        onRefresh: _agregarLikePost,
                        child: Stack(
                          children: [
                            ListView.builder(
                                controller: _scrollController,
                                itemCount: listLikePost.length,
                                itemBuilder: (context, index) {
                                  return FadeInDown(
                                      // key: UniqueKey(),
                                      child: _cardComunidadPost(
                                          context, index, listLikePost[index]));
                                }),
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
                label: '¿Deseas publicar algo?',
                child: const Icon(Icons.add),
                onTap: () {
                  Navigator.pushNamed(context, 'crearPost').then((value) {
                    _agregarLikePost();
                  });
                }),
            SpeedDialChild(
                label: '¿Deseas buscar algo?',
                child: const Icon(Icons.search),
                onTap: () {
                  setState(() {
                    _isWidgetSearch = !_isWidgetSearch;
                  });
                })
          ],
        ));
  }

  Widget _cardComunidadPost(context, int index, LikePostModel likePostModel) {
    final Size sizeScreen = MediaQuery.of(context).size;
    final card = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //ENCABEZADO DEL CARD HEADER
        //DESCRIPCIÒN DEL CARD NOTICIA
        _cardBody(likePostModel),
        _cardImageHeader(sizeScreen, context, index, likePostModel),
      ],
    );

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
        child: card,
      ),
    );
  }

  Column _cardBody(LikePostModel likePostModel) {
    return Column(
      children: [
        ListTile(
          title: Text(likePostModel.post.usuario.nombre +
              " " +
              likePostModel.post.usuario.apellido),
          subtitle: Text(likePostModel.post.usuario.apodo),
          leading: CircleAvatar(
            backgroundImage: _getImagenUser(likePostModel.post.usuario.imgUrl),
          ),
          trailing: Text(DateFormat.yMMMEd('es').format(likePostModel.fecha)),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
          alignment: Alignment.centerLeft,
          child: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                        text:
                            '${likePostModel.post.titulo.replaceFirst(likePostModel.post.titulo.substring(0, 1), likePostModel.post.titulo.substring(0, 1).toUpperCase())}: ',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    TextSpan(text: '${likePostModel.post.descripcion}'),
                  ])),
        ),
      ],
    );
  }

  Widget _cardImageHeader(
      Size sizeScreen, context, int index, LikePostModel likePostModel) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Column(
      children: [
        likePostModel.post.imagen == 'no-img'
            ? const SizedBox()
            : GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MostrarFoto(
                            foto: likePostModel.post.imagen,
                            idLikePostHero: likePostModel.idLikePost)),
                  );
                },
                child: Hero(
                  tag: likePostModel.idLikePost,
                  child: FadeInImage(
                    image: _getImagenPost(likePostModel.post.imagen),
                    placeholder: const AssetImage('assets/loadingUno.gif'),
                    fadeInDuration: const Duration(milliseconds: 200),
                    height: 200.0,
                    width: sizeScreen.width,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
        Container(
          alignment: Alignment.center,
          width: sizeScreen.width,
          height: 50,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                        onPressed: () async {
                          setState(() {
                            listIsFavoriteIcon[index] = true;
                          });
                          if (await likePostProvider
                              .existLikePost(likePostModel.idLikePost)) {
                            if (await likePostProvider.isFavoritePost(
                                likePostModel.idLikePost,
                                userProvider.userGlobal.idUsuario)) {
                              likePostProvider.removeFavoritePost(
                                  likePostModel.idLikePost,
                                  userProvider.userGlobal.idUsuario);
                            } else {
                              likePostProvider.addFavoritePost(
                                  likePostModel.idLikePost,
                                  userProvider.userGlobal.idUsuario);
                            }
                            listLikePost[index] = await likePostProvider
                                .getLikePostById(likePostModel.idLikePost);
                            setState(() {
                              listIsFavoriteIcon[index] = false;
                            });
                          } else {
                            getAlert(
                                _scaffoldKey.currentContext!,
                                'Publicación Eliminada',
                                'La publicación ha sido eliminada');
                            _agregarLikePost();
                          }
                        },
                        padding: EdgeInsets.zero,
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (widget, animation) {
                            return FadeTransition(
                              opacity: widget.key == const ValueKey('iconFav1')
                                  ? Tween<double>(begin: 1, end: 1)
                                      .animate(animation)
                                  : Tween<double>(begin: 1, end: 1)
                                      .animate(animation),
                              child: ScaleTransition(
                                  scale: animation, child: widget),
                            );
                          },
                          child: listIsFavoriteIcon[index]
                              ? CircularProgressIndicator(
                                  color: Colors.red.shade600,
                                )
                              : (!listLikePost[index].userList.contains(
                                      userProvider.userGlobal.idUsuario))
                                  ? const Icon(Icons.favorite_border,
                                      key: ValueKey('iconFav1'))
                                  : const Icon(
                                      Icons.favorite,
                                      key: ValueKey('iconFav2'),
                                    ),
                        ),
                        iconSize: 35,
                        color: Colors.red.shade600),
                    Text(likePostModel.userList.length.toString()),
                    SizedBox(width: 10),
                    SizedBox(
                      height: 35,
                      width: 1,
                      child: Container(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .color!
                            .withOpacity(0.5),
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                        onPressed: () async {
                          if ((await likePostProvider
                              .existLikePost(likePostModel.idLikePost))) {
                            String whatsApp =
                                likePostModel.post.usuario.whatsapp;
                            if (whatsApp.startsWith('0')) {
                              whatsApp = whatsApp.replaceFirst('0', '593');
                            } else if (whatsApp.startsWith('+593')) {
                              whatsApp = whatsApp.replaceFirst('+', '');
                            }

                            // print(likePostModel.post.usuario.email);
                            String urlWhatsApp =
                                'whatsapp://send?phone=$whatsApp';
                            if (whatsApp != '' &&
                                whatsApp != 'Celular desconocido') {
                              setState(() {
                                isLoading = true;
                              });
                              if (await canLaunch(urlWhatsApp)) {
                                await launch(urlWhatsApp);
                                setState(() {
                                  isLoading = false;
                                });
                              } else {
                                setState(() {
                                  isLoading = false;
                                });
                                getAlert(
                                    _scaffoldKey.currentContext!,
                                    'Alerta WhatsApp',
                                    'No se pudó abrir la aplicación WhatsApp');
                              }
                            } else {
                              // if (mounted) {
                              getAlert(
                                  // context,
                                  _scaffoldKey.currentContext!,
                                  'Alerta WhatsApp',
                                  'El usuario no ha escpecificado correctamente su número de contacto');
                              // }
                            }
                          } else {
                            getAlert(
                                _scaffoldKey.currentContext!,
                                'Publicación Eliminada',
                                'La publicación ha sido eliminada');
                            _agregarLikePost();
                          }
                        },
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          FontAwesomeIcons.whatsappSquare,
                        ),
                        iconSize: 35,
                        color: Colors.green.shade700),
                  ],
                ),
                likePostModel.post.usuario.idUsuario ==
                        userProvider.userGlobal.idUsuario
                    ? IconButton(
                        onPressed: () async {
                          if ((await likePostProvider
                              .existLikePost(likePostModel.idLikePost))) {
                            _showModalWidget(
                                likePostModel.idLikePost,
                                likePostModel.post.idPost,
                                likePostModel.post.imagen,
                                likePostModel);
                          } else {
                            getAlert(
                                _scaffoldKey.currentContext!,
                                'Publicación Eliminada',
                                'La publicación ha sido eliminada');
                            _agregarLikePost();
                          }
                        },
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.more_vert),
                        iconSize: 30,
                      )
                    : SizedBox()
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _getSearchWidget() {
    return ListTile(
      title: TextField(
        onChanged: (value) {
          if (value.isEmpty) {
            _agregarLikePost();
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
                _buscarLikePost(_textEditingController.text.toUpperCase());
                _currIndexIcon = 1;
              }
            },
          ),
          hintText: 'Buscar por título',
        ),
      ),
    );
  }

  Future<void> _buscarLikePost(String title) async {
    isLoading = true;
    setState(() {});
    listLikePost =
        await likePostProvider.getLikePostByTitle(title.toLowerCase());

    isLoading = false;
    setState(() {});
  }

  Widget _getPrefixIcon() {
    if (_textEditingController.text != '') {
      return IconButton(
          onPressed: () {
            _textEditingController.text = '';
            _agregarLikePost();
            _currIndexIcon = 0;
          },
          icon: const Icon(Icons.close));
    } else {
      return const Icon(Icons.text_fields);
    }
  }

  void _showModalWidget(String idLikePost, String idPost, String urlImg,
      LikePostModel likePostModel) {
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
                      Text('Editar publicación')
                    ],
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, 'crearPost',
                            arguments: likePostModel)
                        .then((value) {
                      _agregarLikePost();
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
                      Text('Eliminar publicación')
                    ],
                  ),
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    if (urlImg == 'no-img') {
                      await likePostProvider.deleteLikePostById(
                          idLikePost, idPost);
                    } else {
                      if ((await likePostProvider.existLikePost(idLikePost))) {
                        await likePostProvider.deleteLikePostWithImgById(
                            idLikePost, idPost, urlImg);
                      }
                    }
                    Navigator.pop(context);
                    setState(() {
                      isLoading = false;
                      _agregarLikePost();
                    });
                  },
                ),
              ),
            ],
          );
        });
  }

  Future<void> _agregarLikePost() async {
    isLoading = true;
    listLikePost.clear();
    listIsFavoriteIcon.clear();
    List<Future<LikePostModel>> listAuxPost =
        await likePostProvider.getLikePost(null);

    for (var item in listAuxPost) {
      LikePostModel likePost = await item;
      listLikePost.add(likePost);
      listIsFavoriteIcon.add(false);
      // listIsFavoriteIcon.add(item.)
    }

    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _agregarMasLikePost() async {
    setState(() {
      isLoadingBottom = true;
    });

    List<Future<LikePostModel>> listAuxPost =
        await likePostProvider.getLikePost(listLikePost.last.fecha);

    for (var item in listAuxPost) {
      listLikePost.add(await item);
      listIsFavoriteIcon.add(false);
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

  ImageProvider _getImagenUser(String imagenUrl) {
    if (imagenUrl == '' || imagenUrl == 'no-img') {
      return const AssetImage('assets/user.png');
    } else {
      return CachedNetworkImageProvider(imagenUrl);
    }
  }

  ImageProvider _getImagenPost(String imagenUrl) {
    if (imagenUrl == '' || imagenUrl == 'no-img') {
      return const AssetImage('assets/image_coming_soon.jpg');
    } else {
      return CachedNetworkImageProvider(imagenUrl);
    }
  }
}

class MostrarFoto extends StatelessWidget {
  final String foto;
  final String idLikePostHero;
  MostrarFoto({Key? key, required this.foto, required this.idLikePostHero})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: foto != '' || foto != 'no-img'
          ? Hero(
              tag: idLikePostHero,
              child: Center(
                child: GestureDetector(
                  onVerticalDragStart: (details) {
                    Navigator.pop(context);
                  },
                  child: InteractiveViewer(
                      maxScale: 5.0,
                      minScale: 0.1,
                      child: CachedNetworkImage(
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        imageUrl: foto,
                      )),
                ),
              ),
            )
          : Center(
              child: Text('No se ha seleccionado la foto'),
            ),
    );
  }
}
