import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/pages/autenticacion_pages/loggedout_page.dart';

import 'package:norkik_app/pages/home_pages/navigation_bar_home_page.dart';
import 'package:norkik_app/providers/conectividad.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/providers/notification.dart';
import 'package:norkik_app/providers/theme.dart';
import 'package:norkik_app/utils/theme_data.dart';
import 'package:norkik_app/widget/cargando_widget.dart';
import 'package:norkik_app/widget/error_widget.dart';
import 'package:norkik_app/widget/nointernet_widget.dart';

import 'package:provider/provider.dart';

class WrapPage extends StatefulWidget {
  const WrapPage({Key? key}) : super(key: key);

  @override
  State<WrapPage> createState() => _WrapPageState();
}

class _WrapPageState extends State<WrapPage> {
  final Map<String, Color> _opcionesTemaColor = {
    'NorkikTheme': const Color.fromRGBO(42, 74, 77, 1),
    'OscuroTheme': Colors.grey.shade900,
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
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final usuarioProvider = Provider.of<UserProvider>(context);
    ConnectionStatusModel conection =
        Provider.of<ConnectionStatusModel>(context);
    if (user != null) {
      // _getUserGlobal(usuarioProvider, user.uid);
      return WillPopScope(
          onWillPop: _onWillPopScope,
          child: FutureBuilder(
            future: usuarioProvider.getUserByIdWithoutNotify(user.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                UserModel userModel = snapshot.data as UserModel;
                usuarioProvider.setUserGlobalWithoutNotify(userModel);

                Provider.of<NotificationProvider>(context, listen: false)
                    .initialize(context);

                //setTheme
                // _setTheme(userModel);
                return conection.isOnline
                    ? NavigationBarHomePage()
                    : NoInternetWidget();
              } else if (snapshot.hasError)
                return ErrorWidgetNorkik();
              else if (ConnectionState.none == snapshot.connectionState) {
                return NoInternetWidget();
              } else {
                return conection.isOnline
                    ? CargandoWidget()
                    : NoInternetWidget();
              }
            },
          ));
    } else {
      return WillPopScope(onWillPop: _onWillPopScope, child: LoggedoutPage());
    }
  }

  Future<bool> _onWillPopScope() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
            title: Text(
              'Selecione alguna opci??n',
            ),
            content: Text('??Est??s seguro que quieres salir de la app?'),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('CANCELAR')),
              TextButton(
                  onPressed: () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                  child: Text('SALIR'))
            ],
          );
        }) as Future<bool>;
  }

  void _setTheme(UserModel userModel) {
    if (mounted) {
      Future.delayed(Duration.zero, () {
        ThemeChanger themeChanger =
            Provider.of<ThemeChanger>(context, listen: false);
        themeChanger.setTheme(getColorTheme(
            _opcionesTemaColor[userModel.apariencia.tema]!,
            userModel.apariencia.font == 'Defecto'
                ? null
                : GoogleFonts.getTextTheme(userModel.apariencia.font)));
      });
    }
  }
}
