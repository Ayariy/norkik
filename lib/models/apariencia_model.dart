class AparienciaModel {
  String idApariencia;
  String tema;
  String font;
  static const String collectionId = 'Apariencia';
  AparienciaModel(
      {required this.idApariencia, required this.tema, required this.font});

  factory AparienciaModel.fromFireStore(Map<String, dynamic> apariencia) {
    return AparienciaModel(
        idApariencia: apariencia['idApariencia'],
        tema: apariencia['Tema'],
        font: apariencia['Font']);
  }

  Map<String, dynamic> toMap() => {
        'Font': font,
        'Tema': tema,
      };

  factory AparienciaModel.aparienciaNoData() {
    return AparienciaModel(
        idApariencia: 'no-id', tema: 'NorkikTheme', font: '');
  }
}
