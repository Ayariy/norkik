import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:norkik_app/pages/drawer_pages/herramientas_pages/scan_pages/show_image_page.dart';

import 'crop_painter.dart';

class NewImagePage extends StatefulWidget {
  XFile file;
  bool isFirst;
  bool isEdit;
  Function? funtionListPdf;
  NewImagePage(
      {Key? key,
      required this.file,
      required this.isFirst,
      required this.isEdit,
      this.funtionListPdf})
      : super(key: key);

  @override
  State<NewImagePage> createState() => _NewImagePageState();
}

class _NewImagePageState extends State<NewImagePage> {
  final GlobalKey key = GlobalKey();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  double width = 0, height = 0;
  Size imagePixelSize = Size.zero;
  bool isFile = false;
  Offset tl = Offset(0, 0),
      tr = Offset(0, 0),
      bl = Offset(0, 0),
      br = Offset(0, 0);
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      Timer(Duration(milliseconds: 2000), getImageSize);
    }
  }

  void getImageSize() {
    if (mounted) {
      RenderBox imageBox = key.currentContext!.findRenderObject() as RenderBox;
      width = imageBox.size.width;
      height = imageBox.size.height;
      imagePixelSize =
          ImageSizeGetter.getSize(FileInput(File(widget.file.path)));
      tl = new Offset(20, 20);
      tr = new Offset(width - 20, 20);
      bl = new Offset(20, height - 20);
      br = new Offset(width - 20, height - 20);
      setState(() {
        isFile = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !isLoading && isFile ? true : false;
      },
      child: Scaffold(
          backgroundColor: ThemeData.dark().canvasColor,
          key: _scaffoldKey,
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    GestureDetector(
                      onPanDown: (details) {
                        double x1 = details.localPosition.dx;
                        double y1 = details.localPosition.dy;
                        double x2 = tl.dx;
                        double y2 = tl.dy;
                        double x3 = tr.dx;
                        double y3 = tr.dy;
                        double x4 = bl.dx;
                        double y4 = bl.dy;
                        double x5 = br.dx;
                        double y5 = br.dy;

                        if (sqrt((x2 - x1) * (x2 - x1) +
                                    (y2 - y1) * (y2 - y1)) <
                                30 &&
                            x1 >= 0 &&
                            y1 >= 0 &&
                            x1 < width / 2 &&
                            y1 < height / 2) {
                          setState(() {
                            tl = details.localPosition;
                          });
                        } else if (sqrt((x3 - x1) * (x3 - x1) +
                                    (y3 - y1) * (y3 - y1)) <
                                30 &&
                            x1 >= width / 2 &&
                            y1 >= 0 &&
                            x1 < width &&
                            y1 < height / 2) {
                          setState(() {
                            tr = details.localPosition;
                          });
                        } else if (sqrt((x4 - x1) * (x4 - x1) +
                                    (y4 - y1) * (y4 - y1)) <
                                30 &&
                            x1 >= 0 &&
                            y1 >= height / 2 &&
                            x1 < width / 2 &&
                            y1 < height) {
                          setState(() {
                            bl = details.localPosition;
                          });
                        } else if (sqrt((x5 - x1) * (x5 - x1) +
                                    (y5 - y1) * (y5 - y1)) <
                                30 &&
                            x1 >= width / 2 &&
                            y1 >= height / 2 &&
                            x1 < width &&
                            y1 < height) {
                          setState(() {
                            br = details.localPosition;
                          });
                        }
                        print(details.localPosition);
                      },
                      onPanUpdate: (details) {
                        double x1 = details.localPosition.dx;
                        double y1 = details.localPosition.dy;
                        double x2 = tl.dx;
                        double y2 = tl.dy;
                        double x3 = tr.dx;
                        double y3 = tr.dy;
                        double x4 = bl.dx;
                        double y4 = bl.dy;
                        double x5 = br.dx;
                        double y5 = br.dy;
                        if (sqrt((x2 - x1) * (x2 - x1) +
                                    (y2 - y1) * (y2 - y1)) <
                                30 &&
                            x1 >= 0 &&
                            y1 >= 0 &&
                            x1 < width / 2 &&
                            y1 < height / 2) {
                          setState(() {
                            tl = details.localPosition;
                          });
                        } else if (sqrt((x3 - x1) * (x3 - x1) +
                                    (y3 - y1) * (y3 - y1)) <
                                30 &&
                            x1 >= width / 2 &&
                            y1 >= 0 &&
                            x1 < width &&
                            y1 < height / 2) {
                          setState(() {
                            tr = details.localPosition;
                          });
                        } else if (sqrt((x4 - x1) * (x4 - x1) +
                                    (y4 - y1) * (y4 - y1)) <
                                30 &&
                            x1 >= 0 &&
                            y1 >= height / 2 &&
                            x1 < width / 2 &&
                            y1 < height) {
                          setState(() {
                            bl = details.localPosition;
                          });
                        } else if (sqrt((x5 - x1) * (x5 - x1) +
                                    (y5 - y1) * (y5 - y1)) <
                                30 &&
                            x1 >= width / 2 &&
                            y1 >= height / 2 &&
                            x1 < width &&
                            y1 < height) {
                          setState(() {
                            br = details.localPosition;
                          });
                        }
                        print(details.localPosition.toString() + "----------");
                      },
                      child: SafeArea(
                        child: Container(
                          color: ThemeData.dark().canvasColor,
                          constraints: BoxConstraints(maxHeight: 450),
                          child: Image.file(
                            File(widget.file.path),
                            key: key,
                          ),
                        ),
                      ),
                    ),
                    isFile
                        ? SafeArea(
                            child: CustomPaint(
                              painter: CropPainter(tl, tr, bl, br),
                            ),
                          )
                        : SizedBox()
                  ],
                ),
                bottomSheet()
              ],
            ),
          )),
    );
  }

  Widget bottomSheet() {
    return Container(
      color: ThemeData.dark().canvasColor,
      width: MediaQuery.of(context).size.width,
      // height: 120,
      child: Center(
        child: Column(
          children: <Widget>[
            const Text(
              "Arrastre las manijas para ajustar los bordes. También, puede hacer esto más tarde, usando la herramienta recorte ",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const Icon(
              Icons.crop,
              color: Colors.white,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: Text(
                    "Cancelar",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.pop(context);

                    // RenderBox imageBox =
                    //     key.currentContext!.findRenderObject() as RenderBox;
                    // print(imageBox.size);
                    // print(imagePixelSize);
                    // Offset tlAux = Offset(
                    //     (tl.dx - bl.dx) < 0
                    //         ? (((tl.dx - bl.dx) * -1) / 2) + tl.dx
                    //         : ((tl.dx - bl.dx) / 2) + bl.dx,
                    //     (tl.dy - tr.dy) < 0
                    //         ? (((tl.dy - tr.dy) * -1) / 2) + tl.dy
                    //         : ((tl.dy - tr.dy) / 2) + tr.dy);

                    // Offset trAux = Offset(
                    //     (tr.dx - br.dx) < 0
                    //         ? (((tr.dx - br.dx) * -1) / 2) + tr.dx
                    //         : ((tr.dx - br.dx) / 2) + br.dx,
                    //     (tr.dy - tl.dy) < 0
                    //         ? (((tr.dy - tl.dy) * -1) / 2) + tr.dy
                    //         : ((tr.dy - tl.dy) / 2) + tl.dy);

                    // Offset blAux = Offset(
                    //     (bl.dx - tl.dx) < 0
                    //         ? (((bl.dx - tl.dx) * -1) / 2) + bl.dx
                    //         : ((bl.dx - tl.dx) / 2) + tl.dx,
                    //     (bl.dy - br.dy) < 0
                    //         ? (((bl.dy - br.dy) * -1) / 2) + bl.dy
                    //         : ((bl.dy - br.dy) / 2) + br.dy);

                    // Offset brAux = Offset(
                    //     (br.dx - tr.dx) < 0
                    //         ? (((br.dx - tr.dx) * -1) / 2) + br.dx
                    //         : ((br.dx - tr.dx) / 2) + tr.dx,
                    //     (br.dy - bl.dy) < 0
                    //         ? (((br.dy - bl.dy) * -1) / 2) + br.dy
                    //         : ((br.dy - bl.dy) / 2) + bl.dy);
                    // tl = tlAux;
                    // tr = trAux;
                    // bl = blAux;
                    // br = brAux;

                    // setState(() {});
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.blue,
                    ),
                    child: isLoading
                        ? Container(
                            width: 60.0,
                            height: 20.0,
                            child: Center(
                              child: Container(
                                width: 20,
                                height: 20,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              ),
                            ),
                          )
                        : isFile
                            ? MaterialButton(
                                child: const Text(
                                  "Continuar",
                                  softWrap: true,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  Timer(const Duration(seconds: 1), () {
                                    Navigator.of(context)
                                        .pushReplacement(MaterialPageRoute(
                                            builder: (context) => ShowImagePage(
                                                  tl: tl,
                                                  tr: tr,
                                                  bl: bl,
                                                  br: br,
                                                  functionPdfList:
                                                      widget.funtionListPdf,
                                                  width: width,
                                                  height: height,
                                                  file: File(widget.file.path),
                                                  isFirst: widget.isFirst,
                                                  isEdit: widget.isEdit,
                                                  imagePixelSize:
                                                      imagePixelSize,
                                                  // animatedListKey:
                                                  //     widget.animatedListKey,
                                                )));
                                  });
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                              )
                            : Container(
                                width: 60,
                                height: 20.0,
                                child: Center(
                                    child: Container(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.white),
                                        ))),
                              ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
