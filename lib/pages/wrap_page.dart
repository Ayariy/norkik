import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/pages/autenticacion_pages/loggedout_page.dart';

import 'package:norkik_app/pages/home_pages/navigation_bar_home_page.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/widget/cargando_widget.dart';
import 'package:norkik_app/widget/error_widget.dart';

import 'package:provider/provider.dart';

class WrapPage extends StatefulWidget {
  const WrapPage({Key? key}) : super(key: key);

  @override
  State<WrapPage> createState() => _WrapPageState();
}

class _WrapPageState extends State<WrapPage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final usuarioProvider = Provider.of<UserProvider>(context);
    // print(Theme.of(context).primaryTextTheme.bodyText1!.fontSize.toString());
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
                return NavigationBarHomePage();
              } else if (snapshot.hasError)
                return ErrorWidgetNorkik();
              else {
                return CargandoWidget();
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
              'Selecione alguna opción',
            ),
            content: Text('¿Estás seguro que quieres salir de la app?'),
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
}
