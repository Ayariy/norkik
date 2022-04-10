class PDFModel {
  String idPdf;
  String nombre;
  String path;
  DateTime date;

  PDFModel(
      {required this.idPdf,
      required this.nombre,
      required this.date,
      required this.path});

  factory PDFModel.fromStorage(Map<String, dynamic> mapPDF) {
    return PDFModel(
      idPdf: mapPDF['idPdf'],
      nombre: mapPDF['nombre'],
      path: mapPDF['path'],
      date: mapPDF['date'],
    );
  }

  Map<String, dynamic> toMap() =>
      {'idPdf': idPdf, 'nombre': nombre, 'path': path, 'date': date.toString()};
}
