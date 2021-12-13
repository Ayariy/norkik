import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:norkik_app/pages/home_pages/recordatorio_page.dart';
import 'package:norkik_app/pages/home_pages/resumen_page.dart';
import 'package:norkik_app/widget/navigation_drawer.dart';
import 'calendario_page.dart';
import 'comunidad_page.dart';
import 'horario_page.dart';
import 'noticias_page.dart';

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
          _iconoItem(Icons.view_agenda_rounded, context),
          _iconoItem(Icons.backup_table_rounded, context),
          _iconoItem(Icons.auto_awesome_motion, context),
          _iconoItem(Icons.notifications_rounded, context),
          _iconoItem(Icons.calendar_view_week, context),
          _iconoItem(Icons.calendar_today_rounded, context),
        ],
        color: Theme.of(context).primaryColor,
        buttonBackgroundColor: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

  Widget _iconoItem(IconData icon, context) {
    // print(getNorkikTheme().appBarTheme.foregroundColor);
    // print(getDarkTheme().appBarTheme.foregroundColor);
    return Icon(icon,
        size: 35, color: Theme.of(context).appBarTheme.foregroundColor);
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
