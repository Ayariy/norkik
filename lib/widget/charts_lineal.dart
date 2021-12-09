import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:norkik_app/utils/color_util.dart';

class ChartsLineal extends StatelessWidget {
  ChartsLineal({Key? key}) : super(key: key);

  final List<EventoDia> eventoDiaData = [
    EventoDia(dia: 'L', eventos: 1),
    EventoDia(dia: 'Ma', eventos: 2),
    EventoDia(dia: 'Mi', eventos: 3),
    EventoDia(dia: 'J', eventos: 1),
    EventoDia(dia: 'V', eventos: 1),
    EventoDia(dia: 'S', eventos: 1),
    EventoDia(dia: 'D', eventos: 1),
  ];

  @override
  Widget build(BuildContext context) {
    List<charts.Series<EventoDia, String>> series = [
      charts.Series<EventoDia, String>(
        id: 'DataLineal',
        domainFn: (eventoDia, entero) => eventoDia.dia,
        measureFn: (eventoDia, entero) => eventoDia.eventos,
        data: eventoDiaData,
        colorFn: (eventoDia, entero) =>
            charts.ColorUtil.fromDartColor(getPrimaryColor()),
      )
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            height: 150,
            width: 220,
            child: charts.BarChart(series),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 2),
            child: Column(
              children: [
                Text(
                  '3 eventos',
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
}

class EventoDia {
  String dia;
  int eventos;
  EventoDia({required this.dia, required this.eventos});
}
