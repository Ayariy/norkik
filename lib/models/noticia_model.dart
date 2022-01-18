class NoticiaModel {
  String idNoticia;
  String titulo;
  String descripcion;
  String imagen;
  DateTime fecha;
  bool isFavorite = false;
  static const String collectionId = 'Noticia';

  NoticiaModel(
      {required this.idNoticia,
      required this.titulo,
      required this.descripcion,
      required this.imagen,
      required this.fecha});

  factory NoticiaModel.fromFireStore(Map<String, dynamic> noticia) {
    return NoticiaModel(
        idNoticia: noticia['idNoticia'],
        titulo: noticia['Titulo'],
        descripcion: noticia['Descripcion'],
        imagen: noticia['Imagen'],
        fecha: noticia['Fecha'].toDate());
  }

  Map<String, dynamic> toMap() => {
        'Titulo': this.titulo,
        'Descripcion': this.descripcion,
        'Imagen': this.imagen,
        'Fecha': this.fecha
      };

  factory NoticiaModel.noticiaNoData() {
    DateTime now = DateTime.now();
    return NoticiaModel(
        idNoticia: 'no-id',
        titulo: 'no-titulo',
        descripcion: 'no-descripcion',
        imagen: 'no-img',
        fecha: DateTime.now());
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'Noticia{idNoticia: $idNoticia, titulo: $titulo, descripcion: $descripcion, imagen: $imagen, fecha: $fecha, Favorite: $isFavorite}';
  }
}
