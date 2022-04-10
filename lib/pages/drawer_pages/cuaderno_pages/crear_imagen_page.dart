import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:norkik_app/models/asignatura_model.dart';
import 'package:norkik_app/models/nota_model.dart';
import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/asignatura_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/nota_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:provider/provider.dart';

class CrearImgPage extends StatefulWidget {
  CrearImgPage({Key? key}) : super(key: key);

  @override
  State<CrearImgPage> createState() => _CrearImgPageState();
}

class _CrearImgPageState extends State<CrearImgPage> {
  TextEditingController _tituloController = TextEditingController();

  NotaProvider notaProvider = NotaProvider();
  AsignaturaProvider asignaturaProvider = AsignaturaProvider();
  AsignaturaModel? asignatura;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  String imgPath = '';
  File? compressedFile;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    asignatura = ModalRoute.of(context)!.settings.arguments as AsignaturaModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear imagen'),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(10),
            child: asignatura == null
                ? Center(
                    child: Text('Ocurrió un problema, intentelo más tarde'),
                  )
                : _getFormImg()),
      ),
    );
  }

  Widget _getFormImg() {
    return Form(
      onWillPop: () async {
        return isLoading ? false : true;
      },
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _tituloController,
            validator: (value) =>
                value!.isNotEmpty ? null : 'Ingresa el título de la imagen',
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.class_),
              hintText: 'Título de la imagen',
            ),
          ),
          _buildImgWidget(),
          Container(
            margin: const EdgeInsets.all(0),
            width: double.infinity,
            height: 0.5,
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
          ListTile(
            leading: Icon(Icons.class_),
            title: Text(asignatura!.nombre),
            subtitle: Text('Msc. ' +
                asignatura!.docente.nombre +
                " " +
                asignatura!.docente.apellido),
          ),
          Container(
            margin: const EdgeInsets.all(0),
            width: double.infinity,
            height: 0.5,
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
          ListTile(
            leading: Icon(Icons.text_fields),
            title: Text('Categoría'),
            subtitle: Text('Imagen'),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            width: double.infinity,
            height: 0.5,
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
          MaterialButton(
              minWidth: double.infinity,
              color: Theme.of(context).primaryColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: isLoading
                    ? [const CircularProgressIndicator()]
                    : [
                        Icon(Icons.photo),
                        SizedBox(
                          width: 15,
                        ),
                        Text('Crear imagen'),
                      ],
              ),
              textColor: Theme.of(context).appBarTheme.foregroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        if (compressedFile != null) {
                          setState(() {
                            isLoading = true;
                          });
                          UserProvider userProvider =
                              Provider.of<UserProvider>(context, listen: false);
                          String imgUrl = await notaProvider.uploadFile(
                              userProvider.userGlobal.idUsuario,
                              DateTime.now().toString(),
                              compressedFile!,
                              'Imagenes');

                          if (imgUrl != '') {
                            DocumentReference<Map<String, dynamic>> userRef =
                                (await userProvider.getUserReferenceById(
                                    userProvider.userGlobal.idUsuario))!;
                            DocumentReference<Map<String, dynamic>>
                                asignaturaRef = (await asignaturaProvider
                                    .getAsignaturaReferenceById(
                                        asignatura!.idAsignatura))!;

                            NotaModel nota = NotaModel(
                                idNota: 'no-id',
                                titulo: _tituloController.text.toLowerCase(),
                                descripcion: '',
                                file: imgUrl,
                                fecha: DateTime.now(),
                                categoria: 'Imagen',
                                asignatura:
                                    AsignaturaModel.asignaturaModelNoData(),
                                usuario: UserModel.userModelNoData());
                            notaProvider.createNota(
                                nota, asignaturaRef, userRef);
                            Navigator.pop(context);
                          } else {
                            getAlert(context, 'Error de carga',
                                'Ocurrió un error en la carga de la foto, Por favor, inténtalo más tarde');
                          }
                          setState(() {
                            isLoading = false;
                          });
                        } else {
                          getAlert(context, 'Imagen no seleccionada',
                              'Por favor seleccione una imagen a guardar');
                        }
                      }
                    })
        ],
      ),
    );
  }

  Widget _buildImgWidget() {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.image),
          title: Text('Agrega una imagen'),
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
                  _showModalWidgetView(MostrarFoto(foto: imgPath));
                },
                child: Hero(
                    tag: 'imgFoto',
                    child: Image.file(
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
              tag: 'imgFoto',
              child: Center(
                child: GestureDetector(
                  child: InteractiveViewer(
                    maxScale: 5.0,
                    minScale: 0.1,
                    child: Image.file(
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
