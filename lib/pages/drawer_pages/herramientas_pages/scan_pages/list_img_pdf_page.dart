import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:norkik_app/models/pdf_model.dart';
import 'package:norkik_app/providers/img_list_provider.dart';
import 'package:norkik_app/providers/pdf_docs_provider.dart';
import 'package:norkik_app/providers/storage_shared.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:provider/provider.dart';

import 'new_image_page.dart';

class ListImgPagePDF extends StatefulWidget {
  File file;
  bool isFirst;
  Function? functionPdfList;
  ListImgPagePDF(
      {Key? key,
      required this.file,
      required this.isFirst,
      this.functionPdfList})
      : super(key: key);

  @override
  State<ListImgPagePDF> createState() => _ListImgPagePDFState();
}

class _ListImgPagePDFState extends State<ListImgPagePDF> {
  TextEditingController nameController = TextEditingController();
  final _focusNode = FocusNode();
  StorageShared storageShared = StorageShared();
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController.text = "Escaneo NorkikApp " + DateTime.now().toString();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        nameController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: nameController.text.length,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ImgListProvider imgListProvider = Provider.of<ImgListProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        if (isLoading) {
          return false;
        } else {
          return _onWillPop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: TextFormField(
            focusNode: _focusNode,
            controller: nameController,
          ),
          actions: [
            TextButton.icon(
              icon: isLoading
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.picture_as_pdf),
              label: const Text('Crear PDF'),
              onPressed: isLoading
                  ? null
                  : () async {
                      if (nameController.text.isNotEmpty) {
                        setState(() {
                          isLoading = true;
                        });
                        File filePDF = await PDFProvider.generatePdfImg(
                            nameController.text + ".pdf",
                            imgListProvider.listImg);
                        // if (filePDF != null) {
                        DateTime dateNow = DateTime.now();
                        List<PDFModel> listPdf =
                            await storageShared.obtenerPdfStorageList();
                        listPdf.add(PDFModel(
                            idPdf: dateNow.toString(),
                            nombre: nameController.text,
                            date: dateNow,
                            path: filePDF.path));
                        await storageShared.agregarPdfStorageList(listPdf);
                        (widget.functionPdfList!());
                        imgListProvider.clearList();
                        Navigator.pop(context);
                        setState(() {
                          isLoading = false;
                        });
                        // }
                      } else {
                        getAlert(context, 'Nombre PDF',
                            'Debe asignar un nombre al PDF que desea crear');
                      }
                    },
            )
          ],
        ),
        body: ReorderableListView.builder(
            itemBuilder: (_, index) {
              return _getCardImg(
                  imgListProvider.listImg[index], index, imgListProvider);
            },
            itemCount: imgListProvider.listImg.length,
            onReorder: (oldIndex, newIndex) {
              final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
              final file = imgListProvider.removeAtItemListImg(oldIndex);
              imgListProvider.insertItemListImg(index, file);
            }),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.camera),
                  onPressed: () async {
                    chooseImage(ImageSource.camera);
                  },
                ),
                Container(
                  color: Theme.of(context)
                      .appBarTheme
                      .foregroundColor!
                      .withOpacity(0.2),
                  width: 2,
                  height: 15,
                ),
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: () async {
                    chooseImage(ImageSource.gallery);
                  },
                )
              ],
            )),
      ),
    );
  }

  Widget _getCardImg(File imgFile, int index, ImgListProvider imgListProvider) {
    Size size = MediaQuery.of(context).size;
    return ListTile(
      key: ValueKey(imgFile),
      trailing: CircleAvatar(
        child: Text('${index + 1}'),
      ),
      title: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Container(
            // height: size.height * 0.5,
            // width: size.width * 0.7,
            margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            decoration: BoxDecoration(
                border: Border.all(
                    width: 0.3,
                    color: Theme.of(context).textTheme.bodyText1!.color!)),
            child: Image.file(
              imgFile,
              // width: size.width * 0.1,
              // height: size.height * 0.5,
              fit: BoxFit.contain,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.black.withAlpha(0),
                Colors.black26,
                Colors.black38,
                Colors.black45,
                Colors.black54,
                Colors.black87
              ],
            )),
            height: size.width * 0.15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => NewImagePage(
                                file: XFile(imgFile.path),
                                isFirst: false,
                                isEdit: true,
                              )));
                    },
                    icon: const Icon(Icons.edit)),
                IconButton(
                    onPressed: () {
                      imgListProvider.removeAtItemListImg(index);
                    },
                    icon: const Icon(Icons.delete)),
              ],
            ),
          )
        ],
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: ((context) => MostrarFoto(file: imgFile))));
      },
    );
  }

  void chooseImage(ImageSource source) async {
    XFile? fileGallery = await ImagePicker().pickImage(source: source);
    if (fileGallery != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => NewImagePage(
                file: fileGallery,
                isFirst: false,
                isEdit: false,
              )));
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('¿Deseas salir?'),
            content: Text('Se borrarán las páginas escaneadas'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () {
                  ImgListProvider imgListProvider =
                      Provider.of<ImgListProvider>(context, listen: false);
                  imgListProvider.clearList();
                  Navigator.of(context).pop(true);
                },
                child: Text('Si'),
              ),
            ],
          ),
        )) ??
        false;
  }
}

class MostrarFoto extends StatelessWidget {
  final File file;

  MostrarFoto({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: file != null
          ? Hero(
              tag: file.path,
              child: Center(
                child: GestureDetector(
                  onVerticalDragStart: (details) {
                    Navigator.pop(context);
                  },
                  child: InteractiveViewer(
                      maxScale: 5.0,
                      minScale: 0.1,
                      child: Image.file(
                        file,
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      )),
                ),
              ),
            )
          : const Center(
              child: Text('No se ha seleccionado la foto'),
            ),
    );
  }
}
