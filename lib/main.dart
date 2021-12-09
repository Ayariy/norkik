import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:norkik_app/pages/navigation_bar_home_page.dart';
import 'package:norkik_app/routes/routes.dart';
import 'package:norkik_app/utils/color_util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  return runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Norkik',
      debugShowCheckedModeBanner: false,
      routes: getAplicationRoutes(),
      theme: ThemeData.light().copyWith(
        canvasColor: getPrimaryColor(),
        appBarTheme: AppBarTheme(
          color: getPrimaryColor(),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (BuildContext context) {
          return NavigationBarHomePage();
        });
      },
    );
  }
}
