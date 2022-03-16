import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:norkik_app/models/asignatura_model.dart';
import 'package:norkik_app/models/horario_model.dart';

class ClasesModel {
  String idClase;
  // List<Map<String, dynamic>> fechaInicioFin;
  List<dynamic> fechaInicioFin;
  HorarioModel horario;
  AsignaturaModel asignatura;

  static const String collectionId = 'Clases';

  ClasesModel(
      {required this.idClase,
      required this.fechaInicioFin,
      required this.horario,
      required this.asignatura});

  factory ClasesModel.fromFireStore(Map<String, dynamic> mapClase) {
    return ClasesModel(
        idClase: mapClase['idClase'],
        fechaInicioFin: mapClase['FechaInicioFin'],
        asignatura: AsignaturaModel.fromFireStore(mapClase['Asignatura']),
        horario: HorarioModel.fromFireStore(mapClase['Horario']));
  }

  Map<String, dynamic> toMap(
          DocumentReference<Map<String, dynamic>> docRefAsignatura,
          DocumentReference<Map<String, dynamic>> docRefHorario) =>
      {
        'FechaInicioFin': fechaInicioFin,
        'Asignatura': docRefAsignatura,
        'Horario': docRefHorario
      };
  factory ClasesModel.clasesModelNoData() {
    return ClasesModel(
        idClase: 'no-id',
        fechaInicioFin: [],
        horario: HorarioModel.horarioModelNoData(),
        asignatura: AsignaturaModel.asignaturaModelNoData());
  }
  @override
  String toString() {
    return 'Clases{idClase: $idClase, FechaInicioFin: $fechaInicioFin, asignatura: $asignatura, Horario:$horario}';
  }
}
