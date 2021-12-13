import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:norkik_app/widget/logo_theme_util.dart';

class LogginPage extends StatefulWidget {
  const LogginPage({Key? key}) : super(key: key);

  @override
  State<LogginPage> createState() => _LogginPageState();
}

class _LogginPageState extends State<LogginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios)),
                // SizedBox(
                //   height: 20,
                // ),
                getLogoNorkikWithTheme(context, 200),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Divider()),
                Text(
                  'Hola, ¡Hás vuelto!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Llena los siguientes campos para inciar sesión',
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _emailController,
                  validator: (value) =>
                      value!.isNotEmpty ? null : 'Porfavor ingrese su correo',
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      hintText: 'Email',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _passwordController,
                  validator: (value) => value!.isNotEmpty
                      ? null
                      : 'Porfavor ingrese correctamente su contraseña',
                  obscureText: true,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.vpn_key),
                      hintText: 'Contraseña',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                SizedBox(
                  height: 30,
                ),
                MaterialButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      print('Email: ' + _emailController.text);
                      print('Contraseña: ' + _passwordController.text);
                    } else {}
                  },
                  height: 60,
                  minWidth: double.infinity,
                  color: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).appBarTheme.foregroundColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('INICIAR SESIÓN'),
                ),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider()),
                MaterialButton(
                  onPressed: () {},
                  height: 60,
                  minWidth: double.infinity,
                  color: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).appBarTheme.foregroundColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: ListTileTheme(
                    iconColor: Theme.of(context).appBarTheme.foregroundColor,
                    textColor: Theme.of(context).appBarTheme.foregroundColor,
                    child: ListTile(
                      leading: Icon(FontAwesomeIcons.google),
                      title: Text('INICIAR SESIÓN CON GOOGLE'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
