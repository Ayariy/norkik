import 'package:flutter/cupertino.dart';
import 'package:norkik_app/pages/autenticacion_pages/autenticacion_page.dart';
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
import 'package:norkik_app/pages/home_pages/comunidad_pages/crear_post_page.dart';
import 'package:norkik_app/pages/home_pages/navigation_bar_home_page.dart';
import 'package:norkik_app/pages/home_pages/noticias_page/noticia_page.dart';
import 'package:norkik_app/pages/home_pages/noticias_page/noticias_favoritos_page.dart';
import 'package:norkik_app/pages/home_pages/recordatorio_pages/crear_recordatorio_page.dart';
import 'package:norkik_app/pages/home_pages/recordatorio_pages/editar_recordatorio.dart';
import 'package:norkik_app/pages/home_pages/recordatorio_pages/ver_recordatorio.dart';
import 'package:norkik_app/pages/wrap_page.dart';

Map<String, WidgetBuilder> getAplicationRoutes() {
  return <String, WidgetBuilder>{
    //DRAWER BAR PAGES
    'home': (context) => NavigationBarHomePage(),
    'notas': (context) => NotasPage(),
    'tareas': (context) => TareasPage(),
    'asignaturas': (context) => AsignaturasPage(),
    'docentes': (context) => DocentesPage(),
    'configuracion': (context) => ConfiguracionPage(),
    'perfil': (context) => PerfilPage(),
    'herramientas': (context) => HerramientasPage(),
    //APP INICIO PAGES
    'loggin': (context) => (LogginPage()),
    'register': (context) => (RegisterPage()),
    'loggedout': (context) => (LoggedoutPage()),
    'wrap': (context) => (WrapPage()),
    'autentificacion': (context) => (AutenticacionPage()),
    //NOTICIA PAGES
    'noticia': (context) => NoticiaPage(),
    'noticiasFavoritos': (context) => NoticiasFavoritos(),
    //COMUNIDAD PAGES
    'crearPost': (context) => CrearPostComunidad(),
    //RECORDATORIO PAGES
    'crearRecordatorio': (context) => CrearRecordatorio(),
    'verRecordatorio': (context) => VerRecordatorio(),
    'editarRecordatorio': (context) => EditarRecordatorio()
  };
}
