import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:norkik_app/models/apariencia_model.dart';
import 'package:norkik_app/models/privacidad_model.dart';
import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/apariencia_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/privacidad_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:provider/provider.dart';

class EditarUsuarioPage extends StatefulWidget {
  EditarUsuarioPage({Key? key}) : super(key: key);

  @override
  State<EditarUsuarioPage> createState() => _EditarUsuarioPageState();
}

class _EditarUsuarioPageState extends State<EditarUsuarioPage> {
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _apellidoController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _apodoController = TextEditingController();
  TextEditingController _whatsAppController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  String imgPath = '';
  File? compressedFile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      _setTextControllers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar usuario'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(9),
          child: _getFormEditUser(),
        ),
      ),
    );
  }

  _getFormEditUser() {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    print(userProvider.userGlobal.password);
    return Form(
        onWillPop: () async {
          return isLoading ? false : true;
        },
        key: _formKey,
        child: Column(
          children: [
            _buildImgWidget(),
            TextFormField(
              controller: _nombreController,
              validator: (value) =>
                  value!.isNotEmpty ? null : 'Ingresa tu nombre ',
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.badge),
                hintText: 'Nombre',
              ),
            ),
            // Container(
            //   margin: const EdgeInsets.all(0),
            //   width: double.infinity,
            //   height: 0.5,
            //   color: Theme.of(context).textTheme.bodyText1!.color,
            // ),
            TextFormField(
              controller: _apellidoController,
              validator: (value) =>
                  value!.isNotEmpty ? null : 'Ingresa tu apellido ',
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.assignment),
                hintText: 'Apellido',
              ),
            ),

            TextFormField(
              controller: _apodoController,
              validator: (value) =>
                  value!.isNotEmpty ? null : 'Ingrese tu apodo',
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.assignment_ind),
                hintText: 'Apodo',
              ),
            ),

            TextFormField(
              maxLength: 10,
              controller: _whatsAppController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value!.isNotEmpty) {
                  if (value.length > 9) {
                    return null;
                  } else {
                    return 'Ingresa tu número de celular';
                  }
                } else {
                  return 'Ingresa tu número celular';
                }
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.whatsapp),
                hintText: 'Número celular',
              ),
            ),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              readOnly:
                  userProvider.userGlobal.password == '******' ? true : false,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Ingresa tu correo';
                } else if (value.contains('@') &&
                    value.contains('.') &&
                    value.endsWith('.com')) {
                  return null;
                } else {
                  return 'Ingresa correctamente tu correo';
                }
              },
              decoration: InputDecoration(
                label: userProvider.userGlobal.password == '******'
                    ? Text('No se puede editar por autenticación con Google')
                    : null,
                prefixIcon: Icon(Icons.email),
                hintText: 'Correo',
              ),
            ),

            TextFormField(
              readOnly:
                  userProvider.userGlobal.password == '******' ? true : false,
              controller: _passwordController,
              validator: (value) {
                if (value!.length >= 5)
                  return null;
                else
                  return 'Su contraseña debe ser mayor a 5 dígitos';
              },
              obscureText: true,
              decoration: InputDecoration(
                label: userProvider.userGlobal.password == '******'
                    ? Text('No se puede editar por autenticación con Google')
                    : null,
                prefixIcon: Icon(Icons.vpn_key),
                hintText: 'Contraseña',
              ),
            ),

            MaterialButton(
                minWidth: double.infinity,
                color: Theme.of(context).primaryColor,
                child: isLoading
                    ? CircularProgressIndicator()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Icon(Icons.person_pin_outlined),
                            SizedBox(
                              width: 15,
                            ),
                            Text('Editar perfil')
                          ]),
                textColor: Theme.of(context).appBarTheme.foregroundColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: isLoading
                    ? null
                    : () async {
                        DateTime date = DateTime.now();
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          AparienciaProvider aparienciaProvider =
                              AparienciaProvider();
                          PrivacidadProvider privacidadProvider =
                              PrivacidadProvider();
                          DocumentReference<Map<String, dynamic>>
                              aparienciaRef = await aparienciaProvider
                                      .getReferenceAparienciaById(userProvider
                                          .userGlobal.apariencia.idApariencia)
                                  as DocumentReference<Map<String, dynamic>>;
                          DocumentReference<Map<String, dynamic>>
                              privacidadRef = await privacidadProvider
                                      .getReferencePrivacidadById(userProvider
                                          .userGlobal.privacidad.idPrivacidad)
                                  as DocumentReference<Map<String, dynamic>>;
                          if (compressedFile == null) {
                            if (imgPath == '') {
                              if (userProvider.userGlobal.imgUrl != '') {
                                if (userProvider.userGlobal.password ==
                                    '******') {
                                  //quita foto de perfil poniendo vacio en imgurl sin eliminar nada de storage
                                  UserModel userModel = UserModel(
                                      idUsuario:
                                          userProvider.userGlobal.idUsuario,
                                      nombre: _nombreController.text,
                                      apellido: _apellidoController.text,
                                      apodo: _apodoController.text,
                                      whatsapp: _whatsAppController.text,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      imgUrl: '',
                                      apariencia:
                                          AparienciaModel.aparienciaNoData(),
                                      privacidad:
                                          PrivacidadModel.privacidadNoData());
                                  await userProvider.updateUser(
                                      userModel, privacidadRef, aparienciaRef);
                                } else {
                                  //quita foto de perfil eliminando de estorage  y actualiando datos en ambos

                                  UserModel userModel = UserModel(
                                      idUsuario:
                                          userProvider.userGlobal.idUsuario,
                                      nombre: _nombreController.text,
                                      apellido: _apellidoController.text,
                                      apodo: _apodoController.text,
                                      whatsapp: _whatsAppController.text,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      imgUrl: '',
                                      apariencia:
                                          AparienciaModel.aparienciaNoData(),
                                      privacidad:
                                          PrivacidadModel.privacidadNoData());
                                  await userProvider.updateUser(
                                      userModel, privacidadRef, aparienciaRef);
                                  await userProvider.deleteFilePerfil(
                                      userProvider.userGlobal.imgUrl);
                                }
                              } else {
                                //actualiza solo datos de usuario
                                UserModel userModel = UserModel(
                                    idUsuario:
                                        userProvider.userGlobal.idUsuario,
                                    nombre: _nombreController.text,
                                    apellido: _apellidoController.text,
                                    apodo: _apodoController.text,
                                    whatsapp: _whatsAppController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    imgUrl: '',
                                    apariencia:
                                        AparienciaModel.aparienciaNoData(),
                                    privacidad:
                                        PrivacidadModel.privacidadNoData());
                                await userProvider.updateUser(
                                    userModel, privacidadRef, aparienciaRef);
                              }
                            } else {
                              if (userProvider.userGlobal.imgUrl != '') {
                                //solo actualiza los datos sin tocar foto
                                print(
                                    'solo actualiza los datos sin tocar foto');
                                UserModel userModel = UserModel(
                                    idUsuario:
                                        userProvider.userGlobal.idUsuario,
                                    nombre: _nombreController.text,
                                    apellido: _apellidoController.text,
                                    apodo: _apodoController.text,
                                    whatsapp: _whatsAppController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    imgUrl: userProvider.userGlobal.imgUrl,
                                    apariencia:
                                        AparienciaModel.aparienciaNoData(),
                                    privacidad:
                                        PrivacidadModel.privacidadNoData());
                                await userProvider.updateUser(
                                    userModel, privacidadRef, aparienciaRef);
                              }
                            }
                          } else {
                            if (userProvider.userGlobal.imgUrl != '') {
                              if (userProvider.userGlobal.password ==
                                  '******') {
                                //cambia foto de perfil sin eliminar nada de storage
                                String imgUrl = await userProvider.uploadFile(
                                  userProvider.userGlobal.idUsuario,
                                  DateTime.now().toString(),
                                  compressedFile!,
                                );
                                if (imgUrl != '') {
                                  UserModel userModel = UserModel(
                                      idUsuario:
                                          userProvider.userGlobal.idUsuario,
                                      nombre: _nombreController.text,
                                      apellido: _apellidoController.text,
                                      apodo: _apodoController.text,
                                      whatsapp: _whatsAppController.text,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      imgUrl: imgUrl,
                                      apariencia:
                                          AparienciaModel.aparienciaNoData(),
                                      privacidad:
                                          PrivacidadModel.privacidadNoData());
                                  await userProvider.updateUser(
                                      userModel, privacidadRef, aparienciaRef);
                                } else {
                                  getAlert(context, 'Error de carga',
                                      'Ocurrió un error en la carga de la foto. Por favor, inténtalo más tarde');
                                }
                              } else {
                                //cambia foto de perfil y datos tocando storage

                                String imgUrl = await userProvider.uploadFile(
                                  userProvider.userGlobal.idUsuario,
                                  DateTime.now().toString(),
                                  compressedFile!,
                                );
                                if (imgUrl != '') {
                                  await userProvider.deleteFilePerfil(
                                      userProvider.userGlobal.imgUrl);
                                  UserModel userModel = UserModel(
                                      idUsuario:
                                          userProvider.userGlobal.idUsuario,
                                      nombre: _nombreController.text,
                                      apellido: _apellidoController.text,
                                      apodo: _apodoController.text,
                                      whatsapp: _whatsAppController.text,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      imgUrl: imgUrl,
                                      apariencia:
                                          AparienciaModel.aparienciaNoData(),
                                      privacidad:
                                          PrivacidadModel.privacidadNoData());
                                  await userProvider.updateUser(
                                      userModel, privacidadRef, aparienciaRef);
                                } else {
                                  getAlert(context, 'Error de carga',
                                      'Ocurrió un error en la carga de la foto. Por favor, inténtalo más tarde');
                                }
                              }
                            } else {
                              //pone foto de perfil y actualiza datos
                              String imgUrl = await userProvider.uploadFile(
                                userProvider.userGlobal.idUsuario,
                                DateTime.now().toString(),
                                compressedFile!,
                              );
                              if (imgUrl != '') {
                                UserModel userModel = UserModel(
                                    idUsuario:
                                        userProvider.userGlobal.idUsuario,
                                    nombre: _nombreController.text,
                                    apellido: _apellidoController.text,
                                    apodo: _apodoController.text,
                                    whatsapp: _whatsAppController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    imgUrl: imgUrl,
                                    apariencia:
                                        AparienciaModel.aparienciaNoData(),
                                    privacidad:
                                        PrivacidadModel.privacidadNoData());
                                await userProvider.updateUser(
                                    userModel, privacidadRef, aparienciaRef);
                              } else {
                                getAlert(context, 'Error de carga',
                                    'Ocurrió un error en la carga de la foto. Porfavor, inténtalo más tarde');
                              }
                            }
                          }

                          UserModel userCompleted = await userProvider
                              .getUserById(userProvider.userGlobal.idUsuario);
                          userProvider.setUserGlobal(userCompleted);

                          setState(() {
                            isLoading = false;
                            Navigator.pop(context);
                          });
                        }
                      })
          ],
        ));
  }

  void _setTextControllers() {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    _nombreController.text = userProvider.userGlobal.nombre;
    _apellidoController.text = userProvider.userGlobal.apellido;
    _apodoController.text = userProvider.userGlobal.apodo;

    _whatsAppController.text = userProvider.userGlobal.whatsapp;
    _emailController.text = userProvider.userGlobal.email;
    _passwordController.text = userProvider.userGlobal.password;
    imgPath = userProvider.userGlobal.imgUrl;
  }

  _buildImgWidget() {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.image),
          title: Text('Agrega una imagen de perfil'),
          trailing: imgPath == ''
              ? SizedBox()
              : IconButton(
                  onPressed: () {
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
                  // _showModalWidgetView(MostrarFoto(foto: imgPath));
                },
                child: Hero(
                    tag: 'imgFoto',
                    child: compressedFile == null
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
                          )),
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
            }),
      ],
    );
  }
}
