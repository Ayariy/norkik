class AparienciaModel {
  String idApariencia;
  String tema;
  int tamanioFuente;
  static const String collectionId = 'Apariencia';
  AparienciaModel(
      {required this.idApariencia,
      required this.tema,
      required this.tamanioFuente});

  factory AparienciaModel.fromFireStore(Map<String, dynamic> apariencia) {
    return AparienciaModel(
        idApariencia: apariencia['idApariencia'],
        tema: apariencia['Tema'],
        tamanioFuente: apariencia['TamañoFuente']);
  }

  Map<String, dynamic> toMap() => {
        'TamañoFuente': tamanioFuente,
        'Tema': tema,
      };

  factory AparienciaModel.aparienciaNoData() {
    return AparienciaModel(
        idApariencia: 'no-id', tema: 'NorkikTheme', tamanioFuente: 14);
  }
}
