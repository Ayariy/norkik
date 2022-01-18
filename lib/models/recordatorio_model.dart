class RecordatorioModel {
  String id;
  String nombre;
  String descripcion;
  DateTime fecha;

  RecordatorioModel(
      {required this.id,
      required this.nombre,
      required this.descripcion,
      required this.fecha});
  factory RecordatorioModel.fromStorage(Map<String, dynamic> mapRecordatorio) {
    return RecordatorioModel(
        id: mapRecordatorio['id'],
        nombre: mapRecordatorio['nombre'],
        descripcion: mapRecordatorio['descripcion'],
        fecha: mapRecordatorio['fecha']);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'fecha': fecha.toString()
      };

  RecordatorioModel get getRecordatorioModel => RecordatorioModel(
      id: id, nombre: nombre, descripcion: descripcion, fecha: fecha);

  @override
  String toString() {
    return 'RecordatorioMode{id: $id, nombre: $nombre, descripción: $descripcion, fecha: $fecha}';
  }
}
