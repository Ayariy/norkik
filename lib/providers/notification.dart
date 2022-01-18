import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationProvider extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin get flutterLocalNotPlugin =>
      _flutterLocalNotificationsPlugin;
  //initialize
  Future initialize(BuildContext context) async {
    // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    //     FlutterLocalNotificationsPlugin();

    AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('norkik');

    IOSInitializationSettings iosInitializationSettings =
        IOSInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: androidInitializationSettings,
            iOS: iosInitializationSettings);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (valuePayload) {
      onSelectNotification(valuePayload, context);
    });
  }

  onSelectNotification(String? payload, BuildContext context) {
    // this.build(context);
    // getAlert(context, payload2.toString(), payload.toString());
    if (payload == 'tareas') {
      Navigator.pushNamed(context, 'tareas');
      getAlert(context, 'Tareas', 'Tienes tareas pendientes');
    } else {
      getAlert(context, 'Recordatorio', 'Tienes recordatorios pendientes');
    }
    // print(payload);
  }

  removeAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  removeIdNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future instantNotificaction() async {
    var android = AndroidNotificationDetails('id', 'channel',
        channelDescription: 'descripcion');

    var platform = new NotificationDetails(android: android);
    await _flutterLocalNotificationsPlugin
        .show(0, 'Demo', 'Description', platform, payload: 'Bienvenido');
  }

  Future<bool> timeNotification(int id, String title, String body,
      DateTime dateTime, String payload) async {
    var fechaRecordatorio =
        tz.TZDateTime.from(dateTime, tz.getLocation('America/Guayaquil'));
    // var fechaRecordatorio = tz.TZDateTime.from(DateTime.now().add(Duration(seconds: 10)),
    //     tz.getLocation('America/Guayaquil'));

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          fechaRecordatorio,
          const NotificationDetails(
              android: AndroidNotificationDetails(
                  'main_chanelID', 'MAIN_CHANEL',
                  largeIcon: DrawableResourceAndroidBitmap('norkik'),
                  channelDescription: 'chanel description',
                  importance: Importance.max,
                  priority: Priority.max,
                  styleInformation: MediaStyleInformation(
                      htmlFormatContent: true, htmlFormatTitle: true))),
          payload: payload,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidAllowWhileIdle: true);
      return true;
    } on Exception catch (e) {
      return false;
    }
  }
}
