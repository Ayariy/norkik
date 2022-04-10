import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:norkik_app/models/nota_model.dart';
import 'package:norkik_app/models/recordatorio_model.dart';
import 'package:norkik_app/models/tarea_model.dart';
import 'package:norkik_app/pages/home_pages/recordatorio_page.dart';
import 'package:norkik_app/pages/home_pages/resumen_page.dart';
import 'package:norkik_app/pages/home_pages/rn_page.dart';
import 'package:norkik_app/providers/conectividad.dart';
import 'package:norkik_app/providers/norkikdb_providers/nota_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/tarea_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/providers/notification.dart';
import 'package:norkik_app/providers/storage_shared.dart';
import 'package:norkik_app/providers/theme.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:norkik_app/utils/theme_data.dart';
import 'package:norkik_app/widget/navigation_drawer.dart';
import 'package:provider/provider.dart';
import 'calendario_page.dart';
import 'comunidad_page.dart';
import 'horario_page.dart';
import 'noticias_page.dart';
import 'package:badges/badges.dart';

class NavigationBarHomePage extends StatefulWidget {
  NavigationBarHomePage({Key? key}) : super(key: key);

  @override
  _NavigationBarHomePageState createState() => _NavigationBarHomePageState();
}

class _NavigationBarHomePageState extends State<NavigationBarHomePage> {
  Dio dio = Dio();
  int _pageIndex = 0;
  String pageName = '';
  bool isLoadingRn = false;
  bool isClickRn = false;

  NotaProvider notaProvider = NotaProvider();
  TareaProvider tareaProvider = TareaProvider();
  StorageShared storageShared = StorageShared();

  List<TareaModel> listTareas = [];
  List<NotaModel> listNotas = [];
  List<RecordatorioModel> listRecordatorios = [];
  List<NorkikDataRn> listNorkikDataRn = [];

  List<double> listResponseRN = [];

  final Map<String, Color> _opcionesTemaColor = {
    'NorkikTheme': const Color.fromRGBO(42, 74, 77, 1),
    'DarkTheme': Colors.grey.shade900,
    'OscuroTheme': Colors.black,
    'VerdeTheme': Colors.teal.shade900,
    'RosadoTheme': Colors.pink.shade700,
    'GrisTheme': Colors.grey.shade700,
    'AzulTheme': Colors.indigo.shade900,
    'AmarilloTheme': Colors.lime.shade900,
    'RojoTheme': Colors.red.shade900,
    'CafeTheme': Colors.brown.shade800,
    'NaranjaTheme': Colors.amber.shade900,
  };

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    metodoAppBarName();
    // if (mounted) {
    urlPage();
    // }
    if (mounted) {
      _getIndexPageSetting();
      _setTheme();
      getRnResult();
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    // _setTheme();
  }

  void metodoAppBarName() {
    switch (_pageIndex) {
      case 0:
        pageName = 'Resumen';
        break;
      case 1:
        pageName = 'Noticias UPEC';
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

  urlPage() async {
    NotificationProvider notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await notificationProvider.flutterLocalNotPlugin
            .getNotificationAppLaunchDetails();
    final didNotificationLaunchApp =
        notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
    if (didNotificationLaunchApp) {
      if (notificationAppLaunchDetails!.payload != null) {
        String payLoadRute = notificationAppLaunchDetails.payload!;
        if (payLoadRute == 'recordatorios') {
          _pageIndex = 3;
          getAlert(context, 'Recordatorio', 'Tienes recordatorios pendientes');
        } else {
          Navigator.pushNamed(context, 'tareas');
          getAlert(context, 'Tareas', 'Tienes tareas pendientes');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // getRnResult();
    UserProvider userProvider = Provider.of<UserProvider>(context);
    // print(userProvider.userGlobal.email);
    return Scaffold(
      appBar: AppBar(
        title: Text(pageName),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: isLoadingRn || listResponseRN.isEmpty
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                    child: const CircularProgressIndicator())
                : Badge(
                    badgeContent: Text(listResponseRN
                        .where((element) => element > 0.4)
                        .toList()
                        .length
                        .toString()),
                    // elevation: 0,
                    position: BadgePosition.bottomStart(),
                    showBadge: !isClickRn,
                    child: IconButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => RnPage(
                                        listResponseRN: listResponseRN,
                                      )))
                              .then((value) {
                            setState(() {
                              isClickRn = true;
                            });
                          });
                        },
                        icon: Icon(FontAwesomeIcons.robot))),
          )
          // Container(
          //   padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          //   child: FadeInImage(
          //       placeholder: AssetImage('assets/loadingDos.gif'),
          //       image: AssetImage('assets/NorkikBlanco.png')),
          // )
        ],
      ),
      bottomSheet: _getBottomSheetInternet(),
      bottomNavigationBar: CurvedNavigationBar(
        index: _pageIndex,
        height: 60.0,
        items: <Widget>[
          _iconoItem(Icons.view_agenda_rounded, context),
          _iconoItem(Icons.backup_table_rounded, context),
          _iconoItem(Icons.group, context),
          _iconoItem(Icons.notifications_rounded, context),
          _iconoItem(Icons.calendar_view_week, context),
          _iconoItem(Icons.calendar_today_rounded, context),
        ],
        color: Theme.of(context).primaryColor,
        buttonBackgroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.transparent
        //  Theme.of(context).scaffoldBackgroundColor
        ,
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

  showPageNavigator(int indexPage) {
    setState(() {
      _pageIndex = indexPage;
      metodoAppBarName();
    });
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
        return ResumenPage(
          pageName: 'Resumen',
          setIndexPageNavigator: showPageNavigator,
        );
      case 1:
        return NoticiasPage();
      case 2:
        return ComunidadPage();
      case 3:
        return RecordatorioPage();
      case 4:
        return HorarioPage();
      case 5:
        return CalendarioPage(
          funtionIndexPage: showPageNavigator,
        );
      default:
        return ResumenPage(
          setIndexPageNavigator: showPageNavigator,
        );
    }
  }

  _getBottomSheetInternet() {
    ConnectionStatusModel conection =
        Provider.of<ConnectionStatusModel>(context);

    if (conection.isOnline) {
      return SizedBox();
    } else {
      return Container(
        color: Theme.of(context).errorColor,
        padding: EdgeInsets.all(5),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.signal_wifi_statusbar_connected_no_internet_4,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Por favor revisa tu conexión a internet',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor),
            ),
          ],
        ),
      );
    }
  }

  void _getIndexPageSetting() async {
    int indexPage = await storageShared.obtenerIndexPageNavigator();
    showPageNavigator(indexPage);
  }

  void _setTheme() {
    if (mounted) {
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      Future.delayed(Duration.zero, () {
        ThemeChanger themeChanger =
            Provider.of<ThemeChanger>(context, listen: false);
        if (userProvider.userGlobal.apariencia.tema == 'DarkTheme') {
          themeChanger.setTheme(getDarkTheme(
              userProvider.userGlobal.apariencia.font == 'Defecto'
                  ? null
                  : GoogleFonts.getTextTheme(
                      userProvider.userGlobal.apariencia.font,
                      ThemeData.dark().textTheme)));
        } else if (userProvider.userGlobal.apariencia.tema
            .contains('Personalizado')) {
          String colorString = userProvider.userGlobal.apariencia.tema
              .replaceAll('Personalizado', '');
          themeChanger.setTheme(getColorTheme(
              Color(int.parse(colorString)),
              userProvider.userGlobal.apariencia.font == 'Defecto'
                  ? null
                  : GoogleFonts.getTextTheme(
                      userProvider.userGlobal.apariencia.font)));
        } else {
          themeChanger.setTheme(getColorTheme(
              _opcionesTemaColor[userProvider.userGlobal.apariencia.tema]!,
              userProvider.userGlobal.apariencia.font == 'Defecto'
                  ? null
                  : GoogleFonts.getTextTheme(
                      userProvider.userGlobal.apariencia.font)));
        }
        // themeChanger.setTheme(getNorkikTheme());
      });
    }
  }

  void getRnResult() async {
    isLoadingRn = true;
    // DateTime hoy = DateTime(2022, 04, 14);
    DateTime hoy = DateTime.now();
    DateTime lunesAnteriorSemana =
        hoy.subtract(Duration(days: hoy.weekday + 6));
    DateTime domingoAnteriorSemana = hoy.subtract(Duration(days: hoy.weekday));
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    DocumentReference<Map<String, dynamic>> userRef = (await userProvider
        .getUserReferenceById(userProvider.userGlobal.idUsuario))!;

    //NOTAS GET LISTA
    List<Future<NotaModel>> listFutureNotas = await notaProvider.getNotasByDate(
        userRef, lunesAnteriorSemana, domingoAnteriorSemana);
    for (var nota in listFutureNotas) {
      NotaModel notaModel = await nota;
      listNotas.add(notaModel);
    }

    //TAREAS GET LISTA
    List<Future<TareaModel>> listFutureTareas = await tareaProvider
        .getTareasByDate(userRef, lunesAnteriorSemana, domingoAnteriorSemana);
    for (var tarea in listFutureTareas) {
      TareaModel tareaModel = await tarea;
      listTareas.add(tareaModel);
    }

    //RECORDATORIO GET LISTA
    listRecordatorios = await storageShared.obtenerRecordatoriosStorageList();
    listRecordatorios = listRecordatorios.where((recordItem) {
      return recordItem.fecha.compareTo(lunesAnteriorSemana) >= 0 &&
          recordItem.fecha.compareTo(domingoAnteriorSemana) < 1;
    }).toList();

    print(listNotas.length.toString() + "N----------------------------");
    print(listTareas.length.toString() + "T----------------------------");
    print(
        listRecordatorios.length.toString() + "R----------------------------");

    List<NorkikDataRn> listNotaNorkik = [];
    List<NorkikDataRn> listTareaNorkik = [];
    List<NorkikDataRn> listRecordNorkik = [];
    for (var i = 0; i < 7; i++) {
      listNotaNorkik.add(NorkikDataRn(1, i + 1,
          listNotas.any((element) => element.fecha.weekday == i + 1) ? 1 : 0));
    }
    for (var i = 0; i < 7; i++) {
      listTareaNorkik.add(NorkikDataRn(2, i + 1,
          listTareas.any((element) => element.fecha.weekday == i + 1) ? 1 : 0));
    }
    for (var i = 0; i < 7; i++) {
      listRecordNorkik.add(NorkikDataRn(
          3,
          i + 1,
          listRecordatorios.any((element) => element.fecha.weekday == i + 1)
              ? 1
              : 0));
    }

    print(listNotaNorkik);
    print('---------------------------');
    print(listTareaNorkik);
    print('---------------------------');
    print(listRecordNorkik);
    print('------------------------------');
    listNorkikDataRn.addAll(listNotaNorkik);
    listNorkikDataRn.addAll(listTareaNorkik);
    listNorkikDataRn.addAll(listRecordNorkik);
    listNorkikDataRn.add(NorkikDataRn(1, DateTime.now().weekday, 0));

    List<Map<String, dynamic>> listMapNorkikData = [];
    listNorkikDataRn.forEach((element) {
      listMapNorkikData.add(element.toMap());
    });
    try {
      final response = await dio.post('https://rnnorkik.herokuapp.com/api/rn',
          data: listMapNorkikData);

      listResponseRN.add(double.parse(response.data['Nota']));
      listResponseRN.add(double.parse(response.data['Tarea']));
      listResponseRN.add(double.parse(response.data['Recordatorio']));
      isClickRn =
          listResponseRN.where((element) => element > 0.4).toList().length > 0
              ? false
              : true;

      if (!isClickRn) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text('¡Hola ${userProvider.userGlobal.nombre}!'),
              content: Text("¿Te gustaría crear un evento para hoy día?"),
              actions: <Widget>[
                TextButton(
                  child: Text("Si"),
                  onPressed: () {
                    //Put your code here which you want to execute on Yes button click.
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => RnPage(
                                  listResponseRN: listResponseRN,
                                )))
                        .then((value) {
                      setState(() {
                        isClickRn = true;
                      });
                      Navigator.pop(context);
                    });
                  },
                ),
                TextButton(
                  child: Text("No"),
                  onPressed: () {
                    //Put your code here which you want to execute on No button click.
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      isLoadingRn = false;
    });
  }
}

class NorkikDataRn {
  int tipo;
  int dia;
  int respuesta;

  NorkikDataRn(this.tipo, this.dia, this.respuesta);

  Map<String, dynamic> toMap() =>
      {'tipo': tipo, 'dia': dia, 'respuesta': respuesta};
  @override
  String toString() {
    // TODO: implement toString
    return '[$tipo, $dia, $respuesta]';
  }
}
