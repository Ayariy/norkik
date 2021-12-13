import 'package:flutter/material.dart';

import 'package:norkik_app/widget/charts_lineal.dart';
import 'package:animate_do/animate_do.dart';

class ResumenPage extends StatelessWidget {
  final String? pageName;
  const ResumenPage({Key? key, @required this.pageName}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListTileTheme(
        iconColor: Theme.of(context).iconTheme.color,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            FadeInDown(child: _cardReporteChart(context)),
            _textoDiaFecha('HOY', '30 sept. 2021'),
            FadeInDown(child: _cardEventos()),
            FadeInDown(child: _cardHorario(context)),
            _textoDiaFecha('MAÑANA', '01 oct. 2021'),
            FadeInDown(child: _cardEventos()),
            FadeInDown(child: _cardHorario(context)),
            _textoDiaFecha('JUEVES', '01 oct. 2021'),
            _textoDiaFecha('VIERNES', '02 oct. 2021'),
            _textoDiaFecha('SÁBADO', '03 oct. 2021'),
            _textoDiaFecha('DOMINGO', '04 oct. 2021'),
            _textoDiaFecha('LUNES', '05 oct. 2021'),
          ],
        ),
      ),
    );
  }

  Widget _cardReporteChart(context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: Column(
        children: [
          ListTile(
            horizontalTitleGap: 5,
            minLeadingWidth: 5,
            minVerticalPadding: 18,
            leading: Icon(
              Icons.bar_chart_rounded,
            ),
            title: Text('Reporte semanal'),
          ),
          ChartsLineal(),
          SizedBox(
              height: 0.15,
              child: Container(
                color: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .color!
                    .withOpacity(0.5),
              )),
          ListTile(
            horizontalTitleGap: 11,
            minLeadingWidth: 0,
            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
            title: Text('Mostrar más'),
            leading: Icon(
              Icons.arrow_forward_rounded,
            ),
            onTap: () {},
          )
        ],
      ),
    );
  }

  Widget _cardEventos() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: Column(
        children: [
          ListTile(
            horizontalTitleGap: 5,
            minLeadingWidth: 5,
            minVerticalPadding: 18,
            leading: Icon(
              Icons.view_agenda_rounded,
            ),
            title: Text('Eventos pendientes'),
          ),
          Column(
            children: [
              ListTile(
                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                minLeadingWidth: 5,
                minVerticalPadding: 0,
                title: Text('Evento 1'),
                subtitle: Text('Tarea'),
                leading: Text('1.'),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                ),
                onTap: () {},
              ),
              ListTile(
                visualDensity: VisualDensity(horizontal: 0, vertical: 0),
                minLeadingWidth: 5,
                minVerticalPadding: 0,
                title: Text('Evento 2'),
                subtitle: Text('Recordatorio'),
                leading: Text('2.'),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                ),
                onTap: () {},
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardHorario(context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: Column(
        children: [
          ListTile(
            horizontalTitleGap: 5,
            minLeadingWidth: 5,
            minVerticalPadding: 18,
            leading: Icon(
              Icons.calendar_view_week,
            ),
            title: Text('Próximas clases'),
          ),
          Column(
            children: [
              ListTile(
                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                minLeadingWidth: 5,
                minVerticalPadding: 0,
                title: Text('Matemáticas'),
                subtitle: Text('7:00 - 9:00'),
                leading: CircleAvatar(
                  backgroundColor: Color(0xffBA1301),
                  maxRadius: 10,
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded),
                onTap: () {},
              ),
              ListTile(
                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                minLeadingWidth: 5,
                minVerticalPadding: 0,
                title: Text('Matemáticas'),
                subtitle: Text('7:00 - 9:00'),
                leading: CircleAvatar(
                  backgroundColor: Color(0xff2B7DE3),
                  maxRadius: 10,
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded),
                onTap: () {},
              ),
            ],
          ),
          SizedBox(
            height: 0.15,
            child: Container(
              color: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .color!
                  .withOpacity(0.5),
            ),
          ),
          ListTile(
            horizontalTitleGap: 11,
            minLeadingWidth: 0,
            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
            title: Text('Mostrar más'),
            leading: Icon(Icons.arrow_forward_rounded),
            onTap: () {},
          )
        ],
      ),
    );
  }

  Widget _textoDiaFecha(String dia, String fecha) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dia,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
          ),
          Text(fecha)
        ],
      ),
    );
  }
}