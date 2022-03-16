class DocenteModel {
  String idDocente;
  String nombre;
  String apellido;
  String email;

  static const String collectionId = 'Docentes';

  DocenteModel({
    required this.idDocente,
    required this.nombre,
    required this.apellido,
    required this.email,
  });

  factory DocenteModel.fromFireStore(Map<String, dynamic> mapDocente) {
    return DocenteModel(
      idDocente: mapDocente['idDocente'],
      nombre: mapDocente['Nombre'],
      apellido: mapDocente['Apellido'],
      email: mapDocente['Email'],
    );
  }

  Map<String, dynamic> toMap() =>
      {'Nombre': nombre, 'Apellido': apellido, 'Email': email};

  factory DocenteModel.docenteModelNoData() {
    return DocenteModel(
      idDocente: 'no-id',
      nombre: 'no-nombre',
      apellido: 'no-apellido',
      email: 'no-email',
    );
  }

  @override
  String toString() {
    return 'DocenteModel{idDocente: $idDocente, nombre: $idDocente, apellido: $apellido, email: $email}';
  }
}
