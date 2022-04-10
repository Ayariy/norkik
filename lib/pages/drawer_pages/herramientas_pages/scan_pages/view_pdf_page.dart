import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:norkik_app/models/pdf_model.dart';

class ViewPdfPage extends StatefulWidget {
  PDFModel pdfModel;
  ViewPdfPage({Key? key, required this.pdfModel}) : super(key: key);

  @override
  State<ViewPdfPage> createState() => _ViewPdfPageState();
}

class _ViewPdfPageState extends State<ViewPdfPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pdfModel.nombre)),
      body: SfPdfViewer.file(File(widget.pdfModel.path)),
    );
  }
}
