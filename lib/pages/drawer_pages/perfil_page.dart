import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:norkik_app/models/like_post_model.dart';
import 'package:norkik_app/models/post_model.dart';
import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/like_post_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/post_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({Key? key}) : super(key: key);

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  LikePostProvider likePostProvider = LikePostProvider();
  PostProvider postProvider = PostProvider();

  final _scrollController = ScrollController();
  bool isLoading = false;
  bool isLoadingPerfil = false;
  bool isLoadingFavorite = false;

  UserModel globalUser = UserModel.userModelNoData();

  GlobalKey _scaffoldKey = GlobalKey();

  List<LikePostModel> listLikePost = [];
  List<bool> listIsFavoriteIcon = [];

  UserModel userGet = UserModel.userModelNoData();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      _getGlobalUser();
      _agregarLikePost();
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(
        slivers: [
          _customAppBar(),
          isLoadingPerfil
              ? SliverList(
                  delegate: SliverChildListDelegate([
                  Center(
                    child: CircularProgressIndicator(),
                  )
                ]))
              : SliverList(
                  delegate: SliverChildListDelegate([
                  _bodySliver(),
                ])),
          isLoading
              ? SliverList(
                  delegate: SliverChildListDelegate([
                  Center(
                    child: CircularProgressIndicator(),
                  )
                ]))
              : listLikePost.isEmpty
                  ? SliverList(
                      delegate: SliverChildListDelegate([
                      Center(
                        child: Text('No tienes publicaciones realizadas'),
                      )
                    ]))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                      return _cardComunidadPost(
                          context, index, listLikePost[index]);
                    }, childCount: listLikePost.length))
        ],
      ),
    );
  }

  Widget _customAppBar() {
    return SliverAppBar(
      actions: [
        IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(Icons.edit),
          onPressed: () {
            Navigator.pushNamed(context, 'editUser').then((value) {
              setState(() {
                _getGlobalUser();
              });
            });
          },
        ),
        IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(Icons.more_vert),
          onPressed: () {},
        ),
      ],
      expandedHeight: 300,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        centerTitle: true,
        title: Container(
            color: Colors.black38,
            width: double.infinity,
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              userGet.nombre + " " + userGet.apellido,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyText2!.fontSize),
            )),
        background: FadeInImage(
          placeholder: AssetImage('assets/loadingDos.gif'),
          image: _getImagenUser(userGet.imgUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _bodySliver() {
    return Column(
      children: [
        _getUserDetail(userGet),
        Divider(),
      ],
    );
  }

  _getImagenPost(String imagenUrl) {
    if (imagenUrl == '' || imagenUrl == 'no-img') {
      return AssetImage('assets/image_coming_soon.jpg');
    } else {
      return CachedNetworkImageProvider(imagenUrl);
    }
  }

  ImageProvider _getImagenUser(String imagenUrl) {
    if (imagenUrl == '' || imagenUrl == 'no-img') {
      return const AssetImage('assets/user.png');
    } else {
      return CachedNetworkImageProvider(imagenUrl);
    }
  }

  _getUserDetail(UserModel user) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      children: [
        _getItemDetail(Icons.person, 'Nombre y Apellido',
            user.nombre + " " + user.apellido),
        _getItemDetail(Icons.perm_contact_cal, 'Apodo', user.apodo),
        _getItemDetail(FontAwesomeIcons.whatsapp, 'WhatsApp', user.whatsapp),
        _getItemDetail(Icons.email, 'Email', user.email),
      ],
    );
  }

  _getItemDetail(IconData iconData, String etiquetea, String detalle) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 45,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiquetea,
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              Text(detalle)
            ],
          )
        ],
      ),
    );
  }

  Widget _cardComunidadPost(
      BuildContext context, int index, LikePostModel likePostModel) {
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

  _cardBody(LikePostModel likePostModel) {
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
          child: Text.rich(TextSpan(children: [
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

  _cardImageHeader(Size sizeScreen, BuildContext context, int index,
      LikePostModel likePostModel) {
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

  void _agregarLikePost() async {
    isLoading = true;
    listLikePost.clear();
    listIsFavoriteIcon.clear();

    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    List<Future<PostModel>> listAuxPost = await postProvider.getPostByUser(
        null,
        (await userProvider
            .getUserReferenceById(userProvider.userGlobal.idUsuario))!);

    for (var post in listAuxPost) {
      PostModel postModel = await post;
      LikePostModel likePostModel =
          await likePostProvider.getLikePostByPostId(postModel);
      listLikePost.add(likePostModel);
      listIsFavoriteIcon.add(false);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _getGlobalUser() async {
    isLoadingPerfil = true;

    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    userGet = await userProvider
        .getUserByIdWithoutNotify(userProvider.userGlobal.idUsuario);
    setState(() {
      isLoadingPerfil = false;
    });
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
