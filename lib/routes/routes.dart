import 'package:flutter/cupertino.dart';
import 'package:norkik_app/pages/autenticacion_pages/autenticacion_page.dart';
import 'package:norkik_app/pages/autenticacion_pages/loggedout_page.dart';
import 'package:norkik_app/pages/autenticacion_pages/loggin_page.dart';
import 'package:norkik_app/pages/autenticacion_pages/register_page.dart';
import 'package:norkik_app/pages/drawer_pages/asignaturas_page.dart';
import 'package:norkik_app/pages/drawer_pages/configuracion_page.dart';
import 'package:norkik_app/pages/drawer_pages/cuaderno_pages/crear_imagen_page.dart';
import 'package:norkik_app/pages/drawer_pages/cuaderno_pages/crear_sonido_page.dart';
import 'package:norkik_app/pages/drawer_pages/cuaderno_pages/crear_texto_page.dart';
import 'package:norkik_app/pages/drawer_pages/docentes_page.dart';
import 'package:norkik_app/pages/drawer_pages/herramientas_page.dart';
import 'package:norkik_app/pages/drawer_pages/notas_page.dart';
import 'package:norkik_app/pages/drawer_pages/perfil_page.dart';
import 'package:norkik_app/pages/drawer_pages/perfil_pages/editar_perfil_page.dart';
import 'package:norkik_app/pages/drawer_pages/tareas_page.dart';
import 'package:norkik_app/pages/home_pages/asignatura_pages/crear_asignatura_page.dart';
import 'package:norkik_app/pages/home_pages/asignatura_pages/ver_asignatura_page.dart';
import 'package:norkik_app/pages/home_pages/comunidad_pages/crear_post_page.dart';
import 'package:norkik_app/pages/home_pages/docente_pages/crear_docente_page.dart';
import 'package:norkik_app/pages/home_pages/docente_pages/ver_docente_page.dart';
import 'package:norkik_app/pages/home_pages/horario_page.dart';
import 'package:norkik_app/pages/home_pages/horario_pages/crear_clase_page.dart';
import 'package:norkik_app/pages/home_pages/horario_pages/crear_horario_page.dart';
import 'package:norkik_app/pages/home_pages/horario_pages/editar_clase.dart';
import 'package:norkik_app/pages/home_pages/horario_pages/editar_horario_page.dart';
import 'package:norkik_app/pages/home_pages/horario_pages/gestionar_horario_page.dart';
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
    'editarRecordatorio': (context) => EditarRecordatorio(),
    //HORARIO PAGES
    'crearClase': (context) => CrearClase(),
    'editarClase': (context) => EditarClase(),
    'gestionarHorario': (context) => GestionarHorarios(),
    'crearHorario': (context) => CrearHorario(),
    'editarHorario': (context) => EditarHorario(),
    //ASIGNATURA PAGES
    'crearAsignatura': (context) => CrearAsignatura(),
    'verAsignatura': (context) => VerAsignatura(),
    //DOCENTES PAGES
    'crearDocente': (context) => CrearDocente(),
    'verDocente': (context) => VerDocente(),

    //PAGES MENUBOTTOM
    //CUADERNO DIGITAL PAGES
    'crearNotaTexto': (context) => CrearNotaTexto(),
    'crearNotaSonido': (context) => CrearNotaSonido(),
    'crearNotaImg': (context) => CrearImgPage(),
    //HORARIO
    'horario': (context) => HorarioPage(),

    //USUARIO
    'editUser': (context) => EditarUsuarioPage(),
  };
}
