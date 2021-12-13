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
    final axisDomainString = charts.OrdinalAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
      labelStyle: charts.TextStyleSpec(
          fontSize: 13,
          color: charts.ColorUtil.fromDartColor(Theme.of(context)
              .textTheme
              .bodyText2!
              .color!)), //chnage white color as per your requirement.
    ));
    final axisMeasureInt = charts.NumericAxisSpec(
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
