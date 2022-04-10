import 'package:flutter/material.dart';
import 'package:norkik_app/providers/storage_shared.dart';

class GeneralSettingPage extends StatefulWidget {
  GeneralSettingPage({Key? key}) : super(key: key);

  @override
  State<GeneralSettingPage> createState() => _GeneralSettingPageState();
}

class _GeneralSettingPageState extends State<GeneralSettingPage> {
  IndexNamePage? enumIndexPage = IndexNamePage.resumen;

  StorageShared storageShared = StorageShared();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // if (mounted) {
    _getIndexPageStorage();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('General'),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.settings),
          )
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              'Selecciona la página de inicio',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            ),
          ),
          Divider(),
          getTilePage(
              'Resumen', IndexNamePage.resumen, Icons.view_agenda_rounded),
          getTilePage(
              'Noticias', IndexNamePage.noticia, Icons.backup_table_rounded),
          getTilePage('Comunidad', IndexNamePage.comunidad, Icons.group),
          getTilePage('Recordatorio', IndexNamePage.recordatorio,
              Icons.notifications_rounded),
          getTilePage('Horario de clases', IndexNamePage.horario,
              Icons.calendar_view_week),
          getTilePage('Calendario', IndexNamePage.calendario,
              Icons.calendar_today_rounded),
          Divider(),
        ],
      ),
    );
  }

  ListTile getTilePage(
      String title, IndexNamePage indexNamePage, IconData iconData) {
    return ListTile(
      title: Text(title),
      leading: Radio<IndexNamePage>(
        autofocus: true,
        value: indexNamePage,
        groupValue: enumIndexPage,
        onChanged: (value) async {
          await storageShared
              .agregarIndexPageNavigator(value != null ? value.index : 0);

          setState(() {
            enumIndexPage = value;
          });
        },
      ),
      trailing: Icon(iconData),
    );
  }

  void _getIndexPageStorage() async {
    int indexPage = await storageShared.obtenerIndexPageNavigator();
    switch (indexPage) {
      case 0:
        enumIndexPage = IndexNamePage.resumen;
        break;
      case 1:
        enumIndexPage = IndexNamePage.noticia;
        break;
      case 2:
        enumIndexPage = IndexNamePage.comunidad;
        break;
      case 3:
        enumIndexPage = IndexNamePage.recordatorio;
        break;
      case 4:
        enumIndexPage = IndexNamePage.horario;
        break;
      case 5:
        enumIndexPage = IndexNamePage.calendario;
        break;
      default:
        enumIndexPage = IndexNamePage.resumen;
    }

    setState(() {});
  }
}

enum IndexNamePage {
  resumen,
  noticia,
  comunidad,
  recordatorio,
  horario,
  calendario
}
