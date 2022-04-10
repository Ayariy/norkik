import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:norkik_app/models/pdf_model.dart';
import 'package:norkik_app/pages/drawer_pages/herramientas_pages/scan_pages/new_image_page.dart';
import 'package:norkik_app/pages/drawer_pages/herramientas_pages/scan_pages/view_pdf_page.dart';
import 'package:norkik_app/providers/pdf_docs_provider.dart';
import 'package:norkik_app/providers/storage_shared.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({Key? key}) : super(key: key);

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  TextEditingController textEditingController = TextEditingController();
  String imgPath = '';
  // Uint8List? _byte;
  List<PDFModel> listPdf = [];
  List<PDFModel> listPdfAux = [];
  StorageShared storageShared = StorageShared();
  bool isLoading = false;

  bool isSearch = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      getListPdf();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isSearch
          ? AppBar(
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    isSearch = false;
                    listPdf = listPdfAux;
                  });
                },
              ),
              title: TextField(
                controller: textEditingController,
                autofocus: true,
                decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    hintText: 'Buscar',
                    hintStyle: TextStyle(
                        color: Theme.of(context).appBarTheme.foregroundColor)),
                style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor),
                onChanged: (text) {
                  buscarListPdf(text);
                  // setState(() {
                  //   listNoticias.clear();
                  // });
                  // _buscarListaNoticiasFavoritos(text);
                },
              ),
            )
          : AppBar(
              title: const Text('Escáner'),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        isSearch = true;
                      });
                    },
                    icon: Icon(Icons.search))
              ],
            ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : listPdf.isEmpty
              ? const Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Por el momento no hay documentos escaneados'),
                  ),
                )
              : ListView.builder(
                  itemCount: listPdf.length,
                  itemBuilder: (_, index) {
                    return _getDocCardPdf(listPdf[index]);
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
    );
  }

  void chooseImage(ImageSource source) async {
    XFile? fileGallery = await ImagePicker().pickImage(source: source);
    if (fileGallery != null) {
      Navigator.of(context)
          .push(MaterialPageRoute(
              builder: (context) => NewImagePage(
                    file: fileGallery,
                    isFirst: true,
                    isEdit: false,
                    funtionListPdf: getListPdf,
                  )))
          .then((value) {
        setState(() {
          getListPdf();
        });
      });
    }
  }

  Widget _getDocCardPdf(PDFModel pdfModel) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ViewPdfPage(pdfModel: pdfModel)));
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
            child: Row(children: [
              FadeInImage(
                image: const AssetImage('assets/pdf.png'),
                placeholder: const AssetImage('assets/loadingUno.gif'),
                fadeInDuration: const Duration(milliseconds: 200),
                width: MediaQuery.of(context).size.width * 0.30,
                height: MediaQuery.of(context).size.width * 0.35,
                fit: BoxFit.cover,
              ),
              Expanded(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        pdfModel.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle:
                          Text(DateFormat.yMMMEd('es').format(pdfModel.date)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Share.shareFiles([pdfModel.path],
                                text: 'PDF creado en NorkikApp el ' +
                                    DateFormat.yMMMEd('es')
                                        .format(pdfModel.date));
                          },
                          icon: Icon(Icons.share),
                          label: Text(''),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            listPdf = listPdfAux;
                            listPdf.removeWhere(
                                (element) => element.idPdf == pdfModel.idPdf);
                            await storageShared.agregarPdfStorageList(listPdf);
                            PDFProvider.deletePDF(File(pdfModel.path));
                            textEditingController.text = '';
                            setState(() {
                              getListPdf();
                              isLoading = false;
                            });
                          },
                          icon: Icon(Icons.delete),
                          label: Text(''),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ]),
          )),
    );
  }

  // Widget _getDocCard(PDFModel pdfModel) {
  //   return ListTile(
  //     leading: FadeInImage(
  //       image: const AssetImage('assets/pdf.png'),
  //       placeholder: const AssetImage('assets/loadingUno.gif'),
  //       fadeInDuration: const Duration(milliseconds: 200),
  //       // width: MediaQuery.of(context).size.width * 0.4,
  //       // height: MediaQuery.of(context).size.width * 0.4,
  //       fit: BoxFit.cover,
  //     ),
  //     title: Text(
  //       pdfModel.nombre,
  //       maxLines: 2,
  //       overflow: TextOverflow.ellipsis,
  //     ),
  //     subtitle: Text(
  //       DateFormat.yMMMEd('es').format(pdfModel.date),
  //     ),
  //     onTap: () {
  //       Navigator.of(context).push(MaterialPageRoute(
  //           builder: (context) => ViewPdfPage(filePdf: File(pdfModel.path))));
  //     },
  //   );
  // }

  void getListPdf() async {
    isLoading = true;
    listPdf = await storageShared.obtenerPdfStorageList();
    listPdf.sort(
      (a, b) {
        return b.date.compareTo(a.date);
      },
    );
    listPdfAux = listPdf;
    setState(() {
      isLoading = false;
    });
  }

  void buscarListPdf(String inputSearch) {
    setState(() {
      isLoading = true;
    });
    inputSearch = inputSearch.toLowerCase();
    listPdf = listPdfAux
        .where((element) => element.nombre.toLowerCase().contains(inputSearch))
        .toList();

    setState(() {
      isLoading = false;
    });
  }
}

// class MySearchDelegate extends SearchDelegate {
//   List<PDFModel> listSearch = [];

//   MySearchDelegate(List<PDFModel> list) {
//     listSearch = list;
//   }

//   void getListPdf() async {}
//   @override
//   Widget? buildLeading(BuildContext context) {
//     // TODO: implement buildLeading
//     return IconButton(
//         onPressed: () {
//           close(context, null);
//         },
//         icon: const Icon(Icons.arrow_back));
//   }

//   @override
//   List<Widget>? buildActions(BuildContext context) {
//     // TODO: implement buildActions
//     return [
//       IconButton(
//           onPressed: () {
//             if (query.isEmpty) {
//               close(context, null);
//             }
//             query = '';
//           },
//           icon: const Icon(Icons.clear))
//     ];
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     // TODO: implement buildResults
//     return ListTile(
//       title: Text(query),
//     );
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     // TODO: implement buildSuggestions
//     List<PDFModel> sugerencias = listSearch.where((elementSearch) {
//       final result = elementSearch.nombre. toLowerCase();
//       final input = query.toLowerCase();
//       return result.contains(input);
//     }).toList();
//     return ListView.builder(
//       itemCount: sugerencias.length,
//       itemBuilder: (context, index) {
//         return ListTile(
//           title: Text(sugerencias[index].),
//           onTap: () {
//             query = sugerencias[index];
//             showResults(context);
//           },
//         );
//       },
//     );
//   }
// }
