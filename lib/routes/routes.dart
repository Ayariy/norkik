import 'package:flutter/cupertino.dart';
import 'package:norkik_app/pages/autenticacion_pages/loggedout_page.dart';
import 'package:norkik_app/pages/autenticacion_pages/loggin_page.dart';
import 'package:norkik_app/pages/autenticacion_pages/register_page.dart';
import 'package:norkik_app/pages/drawer_pages/asignaturas_page.dart';
import 'package:norkik_app/pages/drawer_pages/configuracion_page.dart';
import 'package:norkik_app/pages/drawer_pages/docentes_page.dart';
import 'package:norkik_app/pages/drawer_pages/herramientas_page.dart';
import 'package:norkik_app/pages/drawer_pages/notas_page.dart';
import 'package:norkik_app/pages/drawer_pages/perfil_page.dart';
import 'package:norkik_app/pages/drawer_pages/tareas_page.dart';
import 'package:norkik_app/pages/home_pages/navigation_bar_home_page.dart';

Map<String, WidgetBuilder> getAplicationRoutes() {
  return <String, WidgetBuilder>{
    'home': (context) => NavigationBarHomePage(),
    'notas': (context) => NotasPage(),
    'tareas': (context) => TareasPage(),
    'asignaturas': (context) => AsignaturasPage(),
    'docentes': (context) => DocentesPage(),
    'configuracion': (context) => ConfiguracionPage(),
    'perfil': (context) => PerfilPage(),
    'herramientas': (context) => HerramientasPage(),
    'loggin': (context) => (LogginPage()),
    'register': (context) => (RegisterPage()),
    'loggedout': (context) => (LoggedoutPage()),
  };
}
