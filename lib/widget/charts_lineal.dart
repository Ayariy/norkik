import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:norkik_app/models/clases_model.dart';
import 'package:norkik_app/models/recordatorio_model.dart';
import 'package:norkik_app/models/tarea_model.dart';
import 'package:norkik_app/utils/color_util.dart';

class ChartsLineal extends StatefulWidget {
  Map<int, List<ClasesModel>> listClases;
  Map<int, List<TareaModel>> listTarea;
  Map<int, List<RecordatorioModel>> listRecordatorio;

  ChartsLineal(
      {Key? key,
      required this.listClases,
      required this.listTarea,
      required this.listRecordatorio})
      : super(key: key);

  @override
  State<ChartsLineal> createState() => _ChartsLinealState();
}

class _ChartsLinealState extends State<ChartsLineal> {
  DateTime fechaHoy = DateTime.now();
  int totalEvents = 0;
  final List<EventoDia> eventoDiaData = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDayEventsCharts();
    _getTotalEvents();
  }

  @override
  Widget build(BuildContext context) {
    // print('Dark');
    // print(ThemeData.dark().textTheme.toString() + "DARK");
    // print('Light');
    List<charts.Series<EventoDia, String>> series = [
      charts.Series<EventoDia, String>(
          id: 'DataLineal',
          domainFn: (eventoDia, entero) => eventoDia.dia,
          measureFn: (eventoDia, entero) => eventoDia.eventos,
          data: eventoDiaData,
          seriesColor: charts.ColorUtil.fromDartColor(Colors.yellow),
          colorFn: (eventoDia, entero) {
            if (Theme.of(context).brightness == Brightness.light) {
              return charts.ColorUtil.fromDartColor(
                  Theme.of(context).primaryColor);
            } else {
              return charts.ColorUtil.fromDartColor(
                  Theme.of(context).textTheme.bodyText2!.color!);
            }
          })
    ];

    //COLOR DE LOS LABELS DEL CHARTSBAR
    charts.OrdinalAxisSpec axisDomainString = charts.OrdinalAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
      labelStyle: charts.TextStyleSpec(
          fontSize: 13,
          color: charts.ColorUtil.fromDartColor(Theme.of(context)
              .textTheme
              .bodyText2!
              .color!)), //chnage white color as per your requirement.
    ));
    charts.NumericAxisSpec axisMeasureInt = charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
      labelStyle: charts.TextStyleSpec(
          fontSize: 10,
          color: charts.ColorUtil.fromDartColor(Theme.of(context)
              .textTheme
              .bodyText2!
              .color!)), //chnage white color as per your requirement.
    ));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            height: 150,
            width: 220,
            child: charts.BarChart(
              series,
              primaryMeasureAxis: axisMeasureInt,
              domainAxis: axisDomainString,
              defaultRenderer: charts.BarRendererConfig(
                  cornerStrategy: const charts.ConstCornerStrategy(5)),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 2),
            child: Column(
              children: [
                Text(
                  '$totalEvents eventos',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                ),
                Text('Próximos 7 días')
              ],
            ),
          )
        ],
      ),
    );
  }

  String _getNameDay(int day) {
    switch (day) {
      case 1:
        return 'L';
      case 2:
        return 'Ma';
      case 3:
        return 'Mi';
      case 4:
        return 'J';
      case 5:
        return 'V';
      case 6:
        return 'S';
      case 7:
        return 'D';
      default:
        return 'NA';
    }
  }

  void _getDayEventsCharts() {
    for (var i = 0; i < 7; i++) {
      eventoDiaData.add(EventoDia(
          dia: _getNameDay(fechaHoy.add(Duration(days: i)).weekday),
          eventos: widget.listClases[i + 1]!.length +
              widget.listTarea[i + 1]!.length +
              widget.listRecordatorio[i + 1]!.length));
    }
  }

  void _getTotalEvents() {
    widget.listClases.forEach((key, value) {
      totalEvents = totalEvents + value.length;
    });
    widget.listTarea.forEach((key, value) {
      totalEvents = totalEvents + value.length;
    });
    widget.listRecordatorio.forEach((key, value) {
      totalEvents = totalEvents + value.length;
    });
  }
}

class EventoDia {
  String dia;
  int eventos;
  EventoDia({required this.dia, required this.eventos});
}
