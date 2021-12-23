import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:norkik_app/models/user_model.dart';

import 'package:norkik_app/providers/autenticacion.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';

import 'package:norkik_app/routes/routes.dart';
import 'package:norkik_app/utils/theme_data.dart';
import 'package:norkik_app/widget/error_widget.dart';
import 'package:provider/provider.dart';

import 'pages/home_pages/navigation_bar_home_page.dart';
import 'providers/theme.dart';
import 'widget/cargando_widget.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  return runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _initApp = Firebase.initializeApp();
    return FutureBuilder(
        future: _initApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorWidgetNorkik();
          } else if (snapshot.hasData) {
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                    create: (_) => ThemeChanger(getNorkikTheme())),
                ChangeNotifierProvider<AuthProvider>.value(
                    value: AuthProvider()),
                StreamProvider.value(
                    value: AuthProvider().user, initialData: null),
                ChangeNotifierProvider(
                    create: (_) => UserProvider(UserModel.userModelNoData())),
              ],
              child: NorkikApp(),
            );
          } else
            return CargandoWidget();
        });
  }
}

class NorkikApp extends StatelessWidget {
  const NorkikApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', 'US'), // English, no country code
        Locale('es', 'ES'),
      ],
      title: 'Norkik',
      theme: theme.getTheme(),
      debugShowCheckedModeBanner: false,
      routes: getAplicationRoutes(),
      // home: WrapPage(),
      initialRoute: 'wrap',
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (BuildContext context) {
          return NavigationBarHomePage();
        });
      },
    );
  }
}
