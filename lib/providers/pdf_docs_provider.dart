import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFProvider {
  static Future<File> saveDocument(
      {required String name, required pw.Document pdf}) async {
    final bytesPDF = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytesPDF);
    return file;
  }

  static Future<File> generatePdfImg(String name, List<File> listImgs) {
    final pdf = pw.Document();

    // pdf.addPage(pw.Page(build: (context) {
    //   return pw.FullPage(ignoreMargins: ignoreMargins)
    // },));

    pdf.addPage(pw.MultiPage(
      margin: pw.EdgeInsets.zero,
      mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      // pageFormat: PdfPageFormat.a3,
      build: (context) {
        List<pw.Widget> listPagesWidgetImg = [];
        listImgs.forEach((file) {
          listPagesWidgetImg.add(pw.Image(
              pw.MemoryImage(file.readAsBytesSync()),
              height: PdfPageFormat.a4.height,
              width: PdfPageFormat.a4.width,
              fit: pw.BoxFit.contain));
        });

        return listPagesWidgetImg;
      },
    ));
    return saveDocument(name: name, pdf: pdf);
  }

  static void deletePDF(File file) {
    if (file.existsSync()) {
      file.deleteSync();
    }
  }
}
