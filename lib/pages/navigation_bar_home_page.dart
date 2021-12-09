import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:norkik_app/pages/calendario_page.dart';
import 'package:norkik_app/pages/comunidad_page.dart';
import 'package:norkik_app/pages/horario_page.dart';
import 'package:norkik_app/pages/noticias_page.dart';
import 'package:norkik_app/pages/recordatorio_page.dart';
import 'package:norkik_app/pages/resumen_page.dart';
import 'package:norkik_app/utils/color_util.dart';
import 'package:norkik_app/widget/navigation_drawer.dart';

class NavigationBarHomePage extends StatefulWidget {
  NavigationBarHomePage({Key? key}) : super(key: key);

  @override
  _NavigationBarHomePageState createState() => _NavigationBarHomePageState();
}

class _NavigationBarHomePageState extends State<NavigationBarHomePage> {
  int _pageIndex = 0;
  String pageName = '';

  @override
  void initState() {
    super.initState();
    metodoAppBarName();
  }

  @override
  void metodoAppBarName() {
    switch (_pageIndex) {
      case 0:
        pageName = 'Resumen';
        break;
      case 1:
        pageName = 'Noticias';
        break;
      case 2:
        pageName = 'Comunidad';
        break;
      case 3:
        pageName = 'Recordatorio';
        break;
      case 4:
        pageName = 'Horario de clases';
        break;
      case 5:
        pageName = 'Calendario';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageName),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: 0,
        height: 60.0,
        items: <Widget>[
          _iconoItem(Icons.view_agenda_rounded),
          _iconoItem(Icons.backup_table_rounded),
          _iconoItem(Icons.auto_awesome_motion),
          _iconoItem(Icons.notifications_rounded),
          _iconoItem(Icons.calendar_view_week),
          _iconoItem(Icons.calendar_today_rounded),
        ],
        color: getPrimaryColor(),
        buttonBackgroundColor: getPrimaryColor(),
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _pageIndex = index;
            metodoAppBarName();
            // _widgetPageGoTo(context);
          });
        },
      ),
      body: _getPageIndex(),
      drawer: NavigationDrawer(),
    );
  }

  Widget _iconoItem(IconData icon) {
    return Icon(icon, size: 35, color: Colors.white);
  }

  Widget _getPageIndex() {
    switch (_pageIndex) {
      case 0:
        return ResumenPage(pageName: 'Resumen');
      case 1:
        return NoticiasPage();
      case 2:
        return ComunidadPage();
      case 3:
        return RecordatorioPage();
      case 4:
        return HorarioPage();
      case 5:
        return CalendarioPage();
      default:
        return ResumenPage();
    }
  }
}
