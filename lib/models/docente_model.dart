class DocenteModel {
  String idDocente;
  String nombre;
  String apellido;
  String email;
  String foto;

  static const String collectionId = 'Docentes';

  DocenteModel(
      {required this.idDocente,
      required this.nombre,
      required this.apellido,
      required this.email,
      required this.foto});

  factory DocenteModel.fromFireStore(Map<String, dynamic> mapDocente) {
    return DocenteModel(
        idDocente: mapDocente['idDocente'],
        nombre: mapDocente['Nombre'],
        apellido: mapDocente['Apellido'],
        email: mapDocente['Email'],
        foto: mapDocente['Foto']);
  }

  Map<String, dynamic> toMap() =>
      {'Nombre': nombre, 'Apellido': apellido, 'Email': email, 'Foto': foto};

  factory DocenteModel.docenteModelNoData() {
    return DocenteModel(
        idDocente: 'no-id',
        nombre: 'no-nombre',
        apellido: 'no-apellido',
        email: 'no-email',
        foto: 'no-foto');
  }

  @override
  String toString() {
    return 'DocenteModel{idDocente: $idDocente, nombre: $idDocente, apellido: $apellido, email: $email, foto: $foto}';
  }
}
