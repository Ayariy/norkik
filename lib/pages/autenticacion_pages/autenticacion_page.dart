import 'package:flutter/material.dart';

import 'package:norkik_app/pages/home_pages/navigation_bar_home_page.dart';

import 'package:norkik_app/providers/theme.dart';
import 'package:norkik_app/routes/routes.dart';

import 'package:norkik_app/utils/theme_data.dart';
import 'package:provider/provider.dart';

class AutenticacionPage extends StatelessWidget {
  const AutenticacionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeChanger(getDarkTheme())),
      ],
      child: MaterialAppWithTheme(),
    );
  }
}

class MaterialAppWithTheme extends StatefulWidget {
  @override
  State<MaterialAppWithTheme> createState() => _MaterialAppWithThemeState();
}

class _MaterialAppWithThemeState extends State<MaterialAppWithTheme> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    return MaterialApp(
      title: 'Norkik',
      theme: theme.getTheme(),
      debugShowCheckedModeBanner: false,
      routes: getAplicationRoutes(),
      initialRoute: 'loggedout',
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (BuildContext context) {
          return NavigationBarHomePage();
        });
      },
      // home: LoggedoutPage()
      // NavigationBarHomePage()
    );
  }
}
