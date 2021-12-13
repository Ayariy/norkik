import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:norkik_app/utils/color_util.dart';

class RecordatorioPage extends StatefulWidget {
  const RecordatorioPage({Key? key}) : super(key: key);

  @override
  State<RecordatorioPage> createState() => _RecordatorioPageState();
}

class _RecordatorioPageState extends State<RecordatorioPage> {
  String _opcionSeleccionada = 'Esta semana';
  List<String> _opcionesTiempo = [
    'Ayer',
    'Hoy',
    'Esta semana',
    'Próxima semana',
    'Este mes',
    'Próximo mes',
    'Todo'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _crearDropdown(),
          Expanded(
            child: _listRecordatorio(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }

  ListView _listRecordatorio() {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        _textoTiempoFecha('HOY', '06 dic. 2021'),
        ListTile(
          title: Text('Exámen'),
          leading: Icon(Icons.share_arrival_time),
          subtitle: Text('Estudiar para el exámen de mate'),
          trailing: Icon(FontAwesomeIcons.ellipsisV),
        ),
        _textoTiempoFecha('MAÑANA', '07 dic. 2021'),
        ListTile(
          title: Text('Exámen'),
          leading: Icon(Icons.share_arrival_time),
          subtitle: Text('Estudiar para el exámen de mate'),
          trailing: Icon(FontAwesomeIcons.ellipsisV),
        ),
        _textoTiempoFecha('PRÓXIMOS 2 DÍAS', '06 dic. 2021'),
        ListTile(
          title: Text('Exámen'),
          leading: Icon(Icons.share_arrival_time),
          subtitle: Text('Estudiar para el exámen de mate'),
          trailing: Icon(FontAwesomeIcons.ellipsisV),
        ),
        _textoTiempoFecha('PRÓXIMOS 3 DÍAS', '06 dic. 2021'),
        ListTile(
          title: Text('Exámen'),
          leading: Icon(Icons.share_arrival_time),
          subtitle: Text('Estudiar para el exámen de mate'),
          trailing: Icon(FontAwesomeIcons.ellipsisV),
        ),
        _textoTiempoFecha('PRÓXIMOS 3 DÍAS', '06 dic. 2021'),
        ListTile(
          title: Text('Exámen'),
          leading: Icon(Icons.share_arrival_time),
          subtitle: Text('Estudiar para el exámen de mate'),
          trailing: Icon(FontAwesomeIcons.ellipsisV),
        ),
        _textoTiempoFecha('PRÓXIMOS 3 DÍAS', '06 dic. 2021'),
        ListTile(
          title: Text('Exámen'),
          leading: Icon(Icons.share_arrival_time),
          subtitle: Text('Estudiar para el exámen de mate'),
          trailing: Icon(FontAwesomeIcons.ellipsisV),
        ),
        _textoTiempoFecha('PRÓXIMOS 3 DÍAS', '06 dic. 2021'),
        ListTile(
          title: Text('Exámen'),
          leading: Icon(Icons.share_arrival_time),
          subtitle: Text('Estudiar para el exámen de mate'),
          trailing: Icon(FontAwesomeIcons.ellipsisV),
        ),
      ],
    );
  }

  Widget _crearDropdown() {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            spreadRadius: 2.0,
            offset: Offset(2.0, 4.0))
      ], color: Theme.of(context).cardColor),
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton(
              isDense: true,
              isExpanded: true,
              // dropdownColor: Colors.white,
              value: _opcionSeleccionada,
              items: getOpcionesDropdown(),
              onChanged: (String? op) {
                setState(() {
                  _opcionSeleccionada = op ?? "sin seleccionar";
                });
              },
            ),
          ),
          Icon(Icons.calendar_today_outlined),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> getOpcionesDropdown() {
    List<DropdownMenuItem<String>> lista = [];

    // ignore: avoid_function_literals_in_foreach_calls
    _opcionesTiempo.forEach((opcion) {
      lista.add(DropdownMenuItem(
        child: Text(opcion),
        value: opcion,
      ));
    });

    return lista;
  }

  Widget _textoTiempoFecha(String tiempo, String fecha) {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            tiempo,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
          ),
          Text(fecha)
        ],
      ),
    );
  }
}
