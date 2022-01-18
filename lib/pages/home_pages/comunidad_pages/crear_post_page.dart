import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:norkik_app/models/like_post_model.dart';
import 'package:norkik_app/models/post_model.dart';
import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/like_post_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/post_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class CrearPostComunidad extends StatelessWidget {
  const CrearPostComunidad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LikePostModel? likePostModel;
    if (ModalRoute.of(context)!.settings.arguments != null) {
      likePostModel =
          ModalRoute.of(context)!.settings.arguments as LikePostModel;
    }
    UserProvider loginProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear publicación'),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          children: [
            _buildNameFoto(loginProvider, context),
            _buildFormulario(
              likePostModel: likePostModel,
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildNameFoto(UserProvider usuarioProvider, BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50.0),
          child: FadeInImage(
            height: size.height * 0.065,
            fit: BoxFit.cover,
            image: _getUserImg(usuarioProvider),
            placeholder: AssetImage('assets/loadingDos.gif'),
          ),
        ),
        SizedBox(
          width: 15,
        ),
        Text(usuarioProvider.userGlobal.nombre +
            " " +
            usuarioProvider.userGlobal.apellido)
      ],
    );
  }

  ImageProvider<Object> _getUserImg(UserProvider usuarioProvider) {
    if (usuarioProvider.userGlobal.imgUrl == '' ||
        usuarioProvider.userGlobal.imgUrl == 'no-img') {
      return AssetImage('assets/user.png');
    } else {
      return CachedNetworkImageProvider(usuarioProvider.userGlobal.imgUrl);
    }
  }
}

class _buildFormulario extends StatefulWidget {
  final LikePostModel? likePostModel;
  _buildFormulario({Key? key, this.likePostModel}) : super(key: key);

  @override
  State<_buildFormulario> createState() => _buildFormularioState();
}

class _buildFormularioState extends State<_buildFormulario> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _tituloPostController = TextEditingController();
  TextEditingController _descripcionPostController = TextEditingController();

  String imgPath = '';
  File? compressedFile;

  bool isLoading = false;
  String idImgUrl = '';

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (widget.likePostModel != null) {
      idImgUrl = widget.likePostModel!.post.imagen;
      _tituloPostController.text = widget.likePostModel!.post.titulo;
      _descripcionPostController.text = widget.likePostModel!.post.descripcion;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        onWillPop: () async {
          return isLoading ? false : true;
        },
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
                controller: _tituloPostController,
                validator: (value) => value!.isNotEmpty
                    ? null
                    : 'Porfavor ingrese el titulo de la publicación',
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.title_rounded),
                  hintText: 'Agrega un título a tu publicación',
                )),
            TextFormField(
                maxLines: null,
                controller: _descripcionPostController,
                validator: (value) => value!.isNotEmpty
                    ? null
                    : 'Porfavor ingrese una pequeña descripción',
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.subtitles),
                  hintText: 'Agrega una descripción',
                )),
            _getWidgetImgPost(widget.likePostModel)
          ],
        ));
  }

  Widget _getWidgetImgPost(LikePostModel? likePostModel) {
    UserProvider userProvider = Provider.of<UserProvider>(context);

    // String auxImgUrl = 'no-img';
    if (likePostModel != null && compressedFile == null) {
      imgPath = likePostModel.post.imagen;
    }
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.image),
          title: Text('¿Deseas agregar una imagen?'),
          trailing: imgPath == ''
              ? SizedBox()
              : IconButton(
                  onPressed: () {
                    if (likePostModel != null) {
                      likePostModel.post.imagen = 'no-img';
                    }
                    setState(() {
                      imgPath = '';
                      compressedFile = null;
                    });
                  },
                  icon: Icon(Icons.close)),
        ),
        imgPath == ''
            ? SizedBox(
                height: size.height * 0.30,
              )
            : GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MostrarFoto(
                            foto: imgPath,
                            likePostModel: likePostModel,
                            compressedFile: compressedFile)),
                  );
                },
                child: Hero(
                  tag: 'imgFoto',
                  child: likePostModel == null
                      ? Image.file(
                          File(imgPath),
                          height: size.height * 0.30,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : imgPath != 'no-img'
                          ? compressedFile == null
                              ? CachedNetworkImage(
                                  height: size.height * 0.30,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  imageUrl: imgPath)
                              : Image.file(
                                  File(imgPath),
                                  height: size.height * 0.30,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                          : SizedBox(
                              height: size.height * 0.30,
                            ),
                ),
              ),
        MaterialButton(
            minWidth: double.infinity,
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_camera),
                SizedBox(
                  width: 15,
                ),
                Text('Tomar Foto'),
              ],
            ),
            textColor: Theme.of(context).appBarTheme.foregroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onPressed: () async {
              final ImagePicker _picker = ImagePicker();
              XFile? xfile =
                  await _picker.pickImage(source: ImageSource.camera);

              if (xfile != null) {
                compressedFile = await FlutterNativeImage.compressImage(
                  xfile.path,
                  percentage: 50,
                  quality: 50,
                );

                setState(() {
                  if (compressedFile != null) imgPath = compressedFile!.path;
                });
              }
            }),
        MaterialButton(
            minWidth: double.infinity,
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library),
                SizedBox(
                  width: 15,
                ),
                Text('Seleccionar de galería'),
              ],
            ),
            textColor: Theme.of(context).appBarTheme.foregroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onPressed: () async {
              final ImagePicker _picker = ImagePicker();
              XFile? xfile = await _picker.pickImage(
                source: ImageSource.gallery,
              );

              if (xfile != null) {
                compressedFile = await FlutterNativeImage.compressImage(
                  xfile.path,
                  percentage: 50,
                  quality: 50,
                );

                setState(() {
                  if (compressedFile != null) imgPath = compressedFile!.path;
                });
              }
              // print(xfile != null ? await xfile.length() / 1024 : null);
            }),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          width: double.infinity,
          height: 0.5,
          color: Theme.of(context).textTheme.bodyText1!.color,
        ),
        MaterialButton(
            minWidth: double.infinity,
            color: Theme.of(context).primaryColor,
            child: isLoading ? CircularProgressIndicator() : Text('Publicar'),
            textColor: Theme.of(context).appBarTheme.foregroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onPressed: isLoading
                ? null
                : () async {
                    DateTime date = DateTime.now();
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      _alertDialog();
                      PostProvider postProvider = PostProvider();
                      LikePostProvider likePostProvider = LikePostProvider();

                      if (likePostModel != null) {
                        likePostModel.post.titulo =
                            _tituloPostController.text.toLowerCase();
                        likePostModel.post.descripcion =
                            _descripcionPostController.text;
                        likePostModel.post.fecha = date;
                        likePostModel.fecha = date;
                        if (likePostModel.post.imagen == 'no-img' &&
                            compressedFile == null) {
                          if (idImgUrl != '' && idImgUrl != 'no-img') {
                            // 'eliminarimgen'
                            likePostModel.post.imagen = 'no-img';
                            await postProvider.deleteImgPost(idImgUrl);
                            await postProvider.updatePost(
                                likePostModel.post,
                                (await userProvider.getUserReferenceById(
                                    userProvider.userGlobal.idUsuario))!);

                            await likePostProvider.updateLikePost(
                                likePostModel,
                                (await postProvider.getPostReferenceById(
                                    likePostModel.post.idPost))!);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          } else {
                            await postProvider.updatePost(
                                likePostModel.post,
                                (await userProvider.getUserReferenceById(
                                    userProvider.userGlobal.idUsuario))!);

                            await likePostProvider.updateLikePost(
                                likePostModel,
                                (await postProvider.getPostReferenceById(
                                    likePostModel.post.idPost))!);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                        } else {
                          if (idImgUrl == 'no-img') {
                            String urlImg = await postProvider.uploadImg(
                                userProvider.userGlobal.idUsuario,
                                date,
                                compressedFile!);
                            if (urlImg != '') {
                              likePostModel.post.imagen = urlImg;
                              await postProvider.updatePost(
                                  likePostModel.post,
                                  (await userProvider.getUserReferenceById(
                                      userProvider.userGlobal.idUsuario))!);

                              await likePostProvider.updateLikePost(
                                  likePostModel,
                                  (await postProvider.getPostReferenceById(
                                      likePostModel.post.idPost))!);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                          } else {
                            //actualizar imagen
                            await postProvider.deleteImgPost(idImgUrl);
                            String urlImg = await postProvider.uploadImg(
                                userProvider.userGlobal.idUsuario,
                                date,
                                compressedFile!);
                            if (urlImg != '') {
                              likePostModel.post.imagen = urlImg;
                              await postProvider.updatePost(
                                  likePostModel.post,
                                  (await userProvider.getUserReferenceById(
                                      userProvider.userGlobal.idUsuario))!);

                              await likePostProvider.updateLikePost(
                                  likePostModel,
                                  (await postProvider.getPostReferenceById(
                                      likePostModel.post.idPost))!);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                          }
                        }
                      } else {
                        if (compressedFile != null) {
                          String urlImg = await postProvider.uploadImg(
                              userProvider.userGlobal.idUsuario,
                              date,
                              compressedFile!);
                          if (urlImg != '') {
                            PostModel postModel = PostModel(
                                idPost: 'no-id',
                                titulo:
                                    _tituloPostController.text.toLowerCase(),
                                descripcion: _descripcionPostController.text,
                                imagen: urlImg,
                                fecha: date,
                                usuario: UserModel.userModelNoData());
                            DocumentReference<Map<String, dynamic>> postRef =
                                await postProvider.createPost(
                                    postModel,
                                    (await userProvider.getUserReferenceById(
                                        userProvider.userGlobal.idUsuario))!);
                            postModel.idPost = postRef.id;
                            await likePostProvider.createLikePost(
                                LikePostModel(
                                    idLikePost: 'no-id',
                                    post: postModel,
                                    userList: [],
                                    fecha: date),
                                postRef);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                        } else {
                          PostModel postModel = PostModel(
                              idPost: 'no-id',
                              titulo: _tituloPostController.text.toLowerCase(),
                              descripcion: _descripcionPostController.text,
                              imagen: 'no-img',
                              fecha: date,
                              usuario: UserModel.userModelNoData());
                          DocumentReference<Map<String, dynamic>> postRef =
                              await postProvider.createPost(
                                  postModel,
                                  (await userProvider.getUserReferenceById(
                                      userProvider.userGlobal.idUsuario))!);
                          postModel.idPost = postRef.id;
                          await likePostProvider.createLikePost(
                              LikePostModel(
                                  idLikePost: 'no-id',
                                  post: postModel,
                                  userList: [],
                                  fecha: date),
                              postRef);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      }
                      setState(() {
                        isLoading = false;
                      });
                    }
                  }),
      ],
    );
  }

  _alertDialog() {
    if (isLoading) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (buildContext) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator()],
            );
          });
    }
  }
}

class MostrarFoto extends StatelessWidget {
  final String foto;
  final LikePostModel? likePostModel;
  final File? compressedFile;
  MostrarFoto(
      {Key? key, required this.foto, this.likePostModel, this.compressedFile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: foto != '' || foto != 'no-img'
          ? Hero(
              tag: 'imgFoto',
              child: Center(
                child: GestureDetector(
                  onVerticalDragStart: (details) {
                    Navigator.pop(context);
                  },
                  child: InteractiveViewer(
                    maxScale: 5.0,
                    minScale: 0.1,
                    child: likePostModel == null
                        ? Image.file(
                            File(foto),
                            height: double.infinity,
                            width: double.infinity,
                            fit: BoxFit.contain,
                          )
                        : compressedFile == null
                            ? CachedNetworkImage(
                                height: double.infinity,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                imageUrl: likePostModel!.post.imagen)
                            : Image.file(
                                File(foto),
                                height: double.infinity,
                                width: double.infinity,
                                fit: BoxFit.contain,
                              ),
                  ),
                ),
              ),
            )
          : Center(
              child: Text('No se ha seleccionado la foto'),
            ),
    );
  }
}
