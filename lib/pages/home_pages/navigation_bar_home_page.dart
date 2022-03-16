import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:norkik_app/pages/home_pages/recordatorio_page.dart';
import 'package:norkik_app/pages/home_pages/resumen_page.dart';
import 'package:norkik_app/providers/conectividad.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/providers/notification.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:norkik_app/widget/navigation_drawer.dart';
import 'package:provider/provider.dart';
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
  int _pageIndex = 5;
  String pageName = '';

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    metodoAppBarName();
    // if (mounted) {
    urlPage();
    // }
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
    UserProvider userProvider = Provider.of<UserProvider>(context);
    // print(userProvider.userGlobal.email);
    return Scaffold(
      appBar: AppBar(
        title: Text(pageName),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: FadeInImage(
                placeholder: AssetImage('assets/loadingDos.gif'),
                image: AssetImage('assets/NorkikBlanco.png')),
          )
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
              'Porfavor revisa tu conexión a internet',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor),
            ),
          ],
        ),
      );
    }
  }
}
