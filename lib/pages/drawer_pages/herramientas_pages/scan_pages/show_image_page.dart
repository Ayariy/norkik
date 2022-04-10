import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:image/image.dart' as imagen;
import 'package:norkik_app/pages/drawer_pages/herramientas_pages/scan_pages/crop_second_page.dart';
import 'package:norkik_app/pages/drawer_pages/herramientas_pages/scan_pages/list_img_pdf_page.dart';
import 'package:norkik_app/pages/drawer_pages/herramientas_pages/scan_pages/recangle_clip.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:opencv_4/opencv_4.dart';
import 'package:provider/provider.dart';

import '../../../../providers/img_list_provider.dart';

class ShowImagePage extends StatefulWidget {
  final GlobalKey keyBoxImg = GlobalKey();
  File file;
  bool isFirst;
  bool isEdit;
  Size imagePixelSize;
  double width;
  double height;
  Offset tl, tr, bl, br;
  Function? functionPdfList;
  ShowImagePage(
      {Key? key,
      required this.file,
      required this.imagePixelSize,
      required this.isFirst,
      required this.isEdit,
      required this.width,
      required this.height,
      required this.tl,
      required this.tr,
      required this.bl,
      required this.br,
      this.functionPdfList})
      : super(key: key);

  @override
  State<ShowImagePage> createState() => _ShowImagePageState();
}

class _ShowImagePageState extends State<ShowImagePage> {
  TextEditingController nameController = TextEditingController();
  final _focusNode = FocusNode();
  // MethodChannel channel = new MethodChannel('opencv');
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int index = 2;
  bool isBottomOpened = false;
  PersistentBottomSheetController? controller;

  Uint8List? whiteboardBytes;
  Uint8List? originalBytes;
  Uint8List? grayBytes;
  Uint8List? biLateral;
  Uint8List? dilate;
  Uint8List? filter2D;
  Uint8List? medianBlur;
  Uint8List? morphology;
  Uint8List? schar;
  Uint8List? colorMap;

  bool isGrayBytes = false;
  bool isOriginalBytes = false;
  bool isWhiteBoardBytes = false;
  bool isBiLateral = false;
  bool isDilate = false;
  bool isfilter2D = false;
  bool isMedianBlur = false;
  bool isMorphology = false;
  bool isSchar = false;
  bool isColorMap = false;

  bool isRotating = false;

  bool isLoading = false;
  double angle = 0;
  // String canvasType = "whiteboard";
  double tl_x = 0;
  double tr_x = 0;
  double bl_x = 0;
  double br_x = 0;
  double tl_y = 0;
  double tr_y = 0;
  double bl_y = 0;
  double br_y = 0;
  Uint8List? bytes;
  final GlobalKey keyBoxImg = GlobalKey();
  @override
  void initState() {
    super.initState();
    nameController.text = "Scan" + DateTime.now().toString();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        nameController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: nameController.text.length,
        );
      }
    });

    getGrayAndSquare();
    BackButtonInterceptor.add(myInterceptor);
  }

  getGrayAndSquare() {
    Offset tlAux = Offset(
        (widget.tl.dx - widget.bl.dx) < 0
            ? (((widget.tl.dx - widget.bl.dx) * -1) / 2) + widget.tl.dx
            : ((widget.tl.dx - widget.bl.dx) / 2) + widget.bl.dx,
        (widget.tl.dy - widget.tr.dy) < 0
            ? (((widget.tl.dy - widget.tr.dy) * -1) / 2) + widget.tl.dy
            : ((widget.tl.dy - widget.tr.dy) / 2) + widget.tr.dy);

    Offset trAux = Offset(
        (widget.tr.dx - widget.br.dx) < 0
            ? (((widget.tr.dx - widget.br.dx) * -1) / 2) + widget.tr.dx
            : ((widget.tr.dx - widget.br.dx) / 2) + widget.br.dx,
        (widget.tr.dy - widget.tl.dy) < 0
            ? (((widget.tr.dy - widget.tl.dy) * -1) / 2) + widget.tr.dy
            : ((widget.tr.dy - widget.tl.dy) / 2) + widget.tl.dy);

    Offset blAux = Offset(
        (widget.bl.dx - widget.tl.dx) < 0
            ? (((widget.bl.dx - widget.tl.dx) * -1) / 2) + widget.bl.dx
            : ((widget.bl.dx - widget.tl.dx) / 2) + widget.tl.dx,
        (widget.bl.dy - widget.br.dy) < 0
            ? (((widget.bl.dy - widget.br.dy) * -1) / 2) + widget.bl.dy
            : ((widget.bl.dy - widget.br.dy) / 2) + widget.br.dy);

    Offset brAux = Offset(
        (widget.br.dx - widget.tr.dx) < 0
            ? (((widget.br.dx - widget.tr.dx) * -1) / 2) + widget.br.dx
            : ((widget.br.dx - widget.tr.dx) / 2) + widget.tr.dx,
        (widget.br.dy - widget.bl.dy) < 0
            ? (((widget.br.dy - widget.bl.dy) * -1) / 2) + widget.br.dy
            : ((widget.br.dy - widget.bl.dy) / 2) + widget.bl.dy);
    widget.tl = tlAux;
    widget.tr = trAux;
    widget.bl = blAux;
    widget.br = brAux;

    convertToGray();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    bool interceptorBool = true;
    if (isBottomOpened) {
      Navigator.of(context).pop();
      isBottomOpened = false;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Container(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Text(
              "¿Descartar escaneo?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Divider(
              thickness: 2,
            ),
            Text(
              "Esto descartará los escaneos que ha capturado. ¿Está seguro?",
            )
          ],
        )),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.black),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              interceptorBool = false;
            },
            child: const Text(
              "Descartar",
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
    return interceptorBool;
  }

  @override
  Widget build(BuildContext context) {
    ImgListProvider imgListProvider = Provider.of<ImgListProvider>(context);
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(children: [
          Card(
            color: Theme.of(context).primaryColor,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context).appBarTheme.foregroundColor,
                      ),
                      onPressed: () {
                        isBottomOpened = false;
                        if (isLoading == false) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    TextButton(
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              "Continuar",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .foregroundColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (bytes != null) {
                                setState(() {
                                  isLoading = true;
                                });
                                RenderBox imageBox = keyBoxImg.currentContext!
                                    .findRenderObject() as RenderBox;
                                widget.tl = Offset(
                                    (widget.imagePixelSize.width /
                                            imageBox.size.width) *
                                        widget.tl.dx,
                                    (widget.imagePixelSize.height /
                                            imageBox.size.height) *
                                        widget.tl.dy);
                                widget.tr = Offset(
                                    (widget.imagePixelSize.width /
                                            imageBox.size.width) *
                                        widget.tr.dx,
                                    (widget.imagePixelSize.height /
                                            imageBox.size.height) *
                                        widget.tr.dy);
                                widget.bl = Offset(
                                    (widget.imagePixelSize.width /
                                            imageBox.size.width) *
                                        widget.bl.dx,
                                    (widget.imagePixelSize.height /
                                            imageBox.size.height) *
                                        widget.bl.dy);
                                widget.br = Offset(
                                    (widget.imagePixelSize.width /
                                            imageBox.size.width) *
                                        widget.br.dx,
                                    (widget.imagePixelSize.height /
                                            imageBox.size.height) *
                                        widget.br.dy);

                                File fileFinal =
                                    await widget.file.writeAsBytes(bytes!);
                                imagen.Image imgCrop = imagen.copyCrop(
                                    imagen.decodeImage(
                                        fileFinal.readAsBytesSync())!,
                                    widget.tl.dx.toInt(),
                                    widget.tl.dy.toInt(),
                                    widget.tr.dx.toInt() - widget.tl.dx.toInt(),
                                    widget.bl.dy.toInt() -
                                        widget.tr.dy.toInt());
                                imagen.Image imgRotar =
                                    imagen.copyRotate(imgCrop, angle);
                                fileFinal.writeAsBytesSync(
                                    imagen.encodeJpg(imgRotar));
                                imageCache!.clear();
                                if (widget.isEdit) {
                                  Navigator.pop(context);
                                } else {
                                  if (widget.isFirst) {
                                    imgListProvider.addItemListImg(fileFinal);
                                    Navigator.of(context)
                                        .pushReplacement(MaterialPageRoute(
                                      builder: (context) {
                                        return ListImgPagePDF(
                                          file: fileFinal,
                                          isFirst: widget.isFirst,
                                          functionPdfList:
                                              widget.functionPdfList,
                                        );
                                      },
                                    ));
                                  } else {
                                    imgListProvider.addItemListImg(fileFinal);
                                    Navigator.pop(context);
                                  }
                                }
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                    )
                  ],
                ),
              ],
            ),
          ),
          bytes == null
              ? Container()
              : isRotating
                  ? Center(
                      child: Container(
                          height: 150,
                          width: 100,
                          child: Center(
                              child: Container(
                            width: 20,
                            height: 20,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ))))
                  : Center(
                      child: Container(
                          // padding: EdgeInsets.all(10),

                          constraints: BoxConstraints(
                              maxHeight: 450,
                              maxWidth: MediaQuery.of(context).size.height),
                          child: Transform.rotate(
                            angle: (angle * pi) / 180,
                            child: ClipPath(
                                clipper: RectangleClip(
                                    tl: widget.tl,
                                    tr: widget.tr,
                                    bl: widget.bl,
                                    br: widget.br),
                                child: Image.memory(
                                  bytes!,
                                  key: keyBoxImg,
                                )),
                          ))),
        ]),
      )),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: Theme.of(context).textTheme.bodyText1!.color,
        onTap: (index) async {
          if (index == 0) {
            if (isBottomOpened) {
              isBottomOpened = false;
              Navigator.of(context).pop();
            }
            setState(() {
              isRotating = true;
            });
            if (angle == 360) {
              angle = 0;
            }
            angle = angle + 90;

            setState(() {
              isRotating = false;
            });
          }
          if (index == 1) {
            if (isBottomOpened) {
              isBottomOpened = false;
              Navigator.of(context).pop();
            }
            Navigator.of(context)
                .push(MaterialPageRoute(
              builder: (context) => CropImage(widget.file),
            ))
                .then((value) {
              if (value != null) {
                setState(() {
                  widget.tl = value[0];
                  widget.tr = value[1];
                  widget.bl = value[2];
                  widget.br = value[3];
                  bytes = null;
                  isGrayBytes = false;
                  isOriginalBytes = false;
                  isWhiteBoardBytes = false;
                  isBiLateral = false;
                  isDilate = false;
                  isfilter2D = false;
                  isMedianBlur = false;
                  isMorphology = false;
                  isSchar = false;
                  isColorMap = false;
                  getGrayAndSquare();
                });
              }
            });
          }
          if (index == 2) {
            if (isBottomOpened) {
              Navigator.of(context).pop();
              isBottomOpened = false;
            } else {
              isBottomOpened = true;
              BottomSheet bottomSheet = BottomSheet(
                onClosing: () {},
                builder: (context) => colorBottomSheet(),
                enableDrag: true,
              );
              controller = scaffoldKey.currentState!
                  .showBottomSheet((context) => bottomSheet);
            }
          }
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.rotate_right,
              ),
              label: "Rotar"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.crop,
              ),
              label: "Cortar"),
          BottomNavigationBarItem(
              icon: Icon(Icons.color_lens,
                  color: Theme.of(context).textTheme.bodyText1!.color),
              label: "Color"),
        ],
      ),
    );
  }

  Widget colorBottomSheet() {
    if (isOriginalBytes == false) {
      grayandoriginal();
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (originalBytes != null) {
                  print("original");
                  Navigator.of(context).pop();
                  isBottomOpened = false;
                  // canvasType = "original";
                  Timer(Duration(milliseconds: 500), () {
                    angle = 0;
                    setState(() {
                      bytes = originalBytes;
                    });
                  });
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      width: 80,
                      margin: EdgeInsets.all(10),
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: isOriginalBytes
                          ? Image.memory(
                              originalBytes!,
                              fit: BoxFit.fill,
                              height: 120,
                            )
                          : Container(
                              height: 120,
                              child: Center(
                                child: Container(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.black),
                                    )),
                              ),
                            )),
                  Text("Original"),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                print("whiteboard");
                Navigator.of(context).pop();
                isBottomOpened = false;
                angle = 0;
                // canvasType = "whiteboard";
                Timer(Duration(milliseconds: 500), () {
                  setState(() {
                    bytes = whiteboardBytes;
                  });
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 80,
                    margin: EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: isWhiteBoardBytes
                        ? Image.memory(
                            whiteboardBytes!,
                            fit: BoxFit.fill,
                            height: 120,
                          )
                        : Container(
                            height: 120,
                            child: Center(
                              child: Container(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.black),
                                  )),
                            ),
                          ),
                  ),
                  Text("Whiteboard"),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                print("gray");
                Navigator.of(context).pop();
                isBottomOpened = false;
                angle = 0;
                // canvasType = "gray";
                Timer(Duration(milliseconds: 500), () {
                  setState(() {
                    bytes = grayBytes;
                  });
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 80,
                    margin: EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: isGrayBytes
                        ? Image.memory(
                            grayBytes!,
                            fit: BoxFit.fill,
                            height: 120,
                          )
                        : Container(
                            height: 120,
                            child: Center(
                              child: Container(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.black),
                                  )),
                            ),
                          ),
                  ),
                  Text("Grayscale"),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                print("bilateral");
                Navigator.of(context).pop();
                isBottomOpened = false;
                angle = 0;
                Timer(Duration(milliseconds: 500), () {
                  setState(() {
                    bytes = biLateral;
                  });
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 80,
                    margin: EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: isBiLateral
                        ? Image.memory(
                            biLateral!,
                            fit: BoxFit.fill,
                            height: 120,
                          )
                        : Container(
                            height: 120,
                            child: Center(
                              child: Container(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.black),
                                  )),
                            ),
                          ),
                  ),
                  Text("Bilateral"),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                print("Dilate");
                Navigator.of(context).pop();
                isBottomOpened = false;
                angle = 0;
                Timer(Duration(milliseconds: 500), () {
                  setState(() {
                    bytes = dilate;
                  });
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 80,
                    margin: EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: isDilate
                        ? Image.memory(
                            dilate!,
                            fit: BoxFit.fill,
                            height: 120,
                          )
                        : Container(
                            height: 120,
                            child: Center(
                              child: Container(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.black),
                                  )),
                            ),
                          ),
                  ),
                  Text("Dilatación"),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                print("Filer2d");
                Navigator.of(context).pop();
                isBottomOpened = false;
                angle = 0;
                Timer(Duration(milliseconds: 500), () {
                  setState(() {
                    bytes = filter2D;
                  });
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 80,
                    margin: EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: isfilter2D
                        ? Image.memory(
                            filter2D!,
                            fit: BoxFit.fill,
                            height: 120,
                          )
                        : Container(
                            height: 120,
                            child: Center(
                              child: Container(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.black),
                                  )),
                            ),
                          ),
                  ),
                  Text("Filtro 2D"),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                print("MedianBlur");
                Navigator.of(context).pop();
                isBottomOpened = false;
                angle = 0;
                Timer(Duration(milliseconds: 500), () {
                  setState(() {
                    bytes = medianBlur;
                  });
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 80,
                    margin: EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: isMedianBlur
                        ? Image.memory(
                            medianBlur!,
                            fit: BoxFit.fill,
                            height: 120,
                          )
                        : Container(
                            height: 120,
                            child: Center(
                              child: Container(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.black),
                                  )),
                            ),
                          ),
                  ),
                  Text("Mediana"),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                print("Morphology");
                Navigator.of(context).pop();
                isBottomOpened = false;
                angle = 0;
                Timer(Duration(milliseconds: 500), () {
                  setState(() {
                    bytes = morphology;
                  });
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 80,
                    margin: EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: isMorphology
                        ? Image.memory(
                            morphology!,
                            fit: BoxFit.fill,
                            height: 120,
                          )
                        : Container(
                            height: 120,
                            child: Center(
                              child: Container(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.black),
                                  )),
                            ),
                          ),
                  ),
                  Text("Morfologia Ex"),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                print("Scharr");
                Navigator.of(context).pop();
                isBottomOpened = false;
                angle = 0;
                Timer(Duration(milliseconds: 500), () {
                  setState(() {
                    bytes = schar;
                  });
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 80,
                    margin: EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: isSchar
                        ? Image.memory(
                            schar!,
                            fit: BoxFit.fill,
                            height: 120,
                          )
                        : Container(
                            height: 120,
                            child: Center(
                              child: Container(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.black),
                                  )),
                            ),
                          ),
                  ),
                  Text("Scharr"),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                print("ColorMap");
                Navigator.of(context).pop();
                isBottomOpened = false;
                angle = 0;
                Timer(Duration(milliseconds: 500), () {
                  setState(() {
                    bytes = colorMap;
                  });
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 80,
                    margin: EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: isColorMap
                        ? Image.memory(
                            colorMap!,
                            fit: BoxFit.fill,
                            height: 120,
                          )
                        : Container(
                            height: 120,
                            child: Center(
                              child: Container(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.black),
                                  )),
                            ),
                          ),
                  ),
                  Text("Color Map"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> grayandoriginal() async {
    // File fil = File()
    //ESCALA DE GRISES O GRAYSCALE
    grayBytes = await Cv2.cvtColor(
      pathFrom: CVPathFrom.GALLERY_CAMERA,
      pathString: widget.file.path,
      outputType: Cv2.COLOR_BGR2GRAY,
    );
    if (grayBytes != null) {
      isGrayBytes = true;
    }

    //BLANCO  Y NEGRO WHITEBOARD
    whiteboardBytes = await Cv2.threshold(
      pathFrom: CVPathFrom.GALLERY_CAMERA,
      pathString: widget.file.path,
      thresholdValue: 150,
      maxThresholdValue: 200,
      thresholdType: Cv2.THRESH_BINARY,
    );
    if (whiteboardBytes != null) {
      isWhiteBoardBytes = true;
    }

    //BILATERAL
    biLateral = await Cv2.bilateralFilter(
      pathFrom: CVPathFrom.GALLERY_CAMERA,
      pathString: widget.file.path,
      diameter: 20,
      sigmaColor: 75,
      sigmaSpace: 75,
      borderType: Cv2.BORDER_DEFAULT,
    );

    if (biLateral != null) {
      isBiLateral = true;
    }

    //DILATACIÓN
    dilate = await Cv2.dilate(
      pathFrom: CVPathFrom.GALLERY_CAMERA,
      pathString: widget.file.path,
      kernelSize: [1, 2],
    );

    if (dilate != null) {
      isDilate = true;
    }

    //FILTRO2D
    filter2D = await Cv2.filter2D(
      pathFrom: CVPathFrom.GALLERY_CAMERA,
      pathString: widget.file.path,
      outputDepth: -1,
      kernelSize: [2, 1],
    );

    if (filter2D != null) {
      isfilter2D = true;
    }

    //MEDIANA BLUR
    medianBlur = await Cv2.medianBlur(
      pathFrom: CVPathFrom.GALLERY_CAMERA,
      pathString: widget.file.path,
      kernelSize: 8,
    );
    if (medianBlur != null) {
      isMedianBlur = true;
    }

    //MORPHOLOGY
    morphology = await Cv2.morphologyEx(
      pathFrom: CVPathFrom.GALLERY_CAMERA,
      pathString: widget.file.path,
      operation: Cv2.MORPH_GRADIENT,
      kernelSize: [5, 5],
    );

    if (morphology != null) {
      isMorphology = true;
    }
    //SCHAR

    schar = await Cv2.scharr(
      pathFrom: CVPathFrom.GALLERY_CAMERA,
      pathString: widget.file.path,
      depth: Cv2.CV_SCHARR,
      dx: 0,
      dy: 1,
    );
    if (schar != null) {
      isSchar = true;
    }

    //COLORMAP
    colorMap = await Cv2.applyColorMap(
      pathFrom: CVPathFrom.GALLERY_CAMERA,
      pathString: widget.file.path,
      colorMap: Cv2.COLORMAP_BONE,
    );
    if (colorMap != null) {
      isColorMap = true;
    }

    //ORIGINAL
    originalBytes = widget.file.readAsBytesSync();
    if (originalBytes != null) {
      isOriginalBytes = true;
    }
    if (mounted) {
      setState(() {});
    }
    if (isBottomOpened) {
      Navigator.pop(context);
      BottomSheet bottomSheet = BottomSheet(
        onClosing: () {},
        builder: (context) => colorBottomSheet(),
        enableDrag: true,
      );
      controller =
          scaffoldKey.currentState!.showBottomSheet((context) => bottomSheet);
    }
  }

  Future<dynamic> convertToGray() async {
    Uint8List? bytesArray = await Cv2.cvtColor(
      pathFrom: CVPathFrom.GALLERY_CAMERA,
      pathString: widget.file.path,
      outputType: Cv2.COLOR_BGR2GRAY,
    );

    setState(() {
      bytes = bytesArray;
      // whiteboardBytes = bytesArray;
    });

    return bytesArray;
  }
}
