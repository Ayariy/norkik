import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:norkik_app/models/apariencia_model.dart';
import 'package:norkik_app/models/privacidad_model.dart';
import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/providers/autenticacion.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/widget/logo_theme_util.dart';
import 'package:provider/provider.dart';

class LogginPage extends StatefulWidget {
  LogginPage({
    Key? key,
  }) : super(key: key);

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
    final loginProvider = Provider.of<AuthProvider>(context);
    final usuarioProvider = Provider.of<UserProvider>(context);
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
                  getLogoNorkikWithTheme(context, 200),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Divider()),
                  Text(
                    'Hola, ¡Has vuelto!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Llena los siguientes campos para inciar sesión',
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value!.isNotEmpty ? null : 'Ingresa tu correo',
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        hintText: 'Correo',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    validator: (value) => value!.isNotEmpty
                        ? null
                        : 'Ingresa correctamente tu contraseña',
                    obscureText: true,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.vpn_key),
                        hintText: 'Contraseña',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  if (loginProvider.errorMessage != "")
                    Container(
                      margin: EdgeInsets.only(bottom: 25),
                      // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      color: Colors.amberAccent,
                      child: ListTile(
                        title: Text(loginProvider.errorMessage),
                        leading: Icon(Icons.error),
                        trailing: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            loginProvider.setMessage("");
                          },
                        ),
                      ),
                    ),
                  MaterialButton(
                    disabledColor: Theme.of(context).primaryColor,
                    onPressed:
                        loginProvider.isLoading || usuarioProvider.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  User? user = await loginProvider.loginUser(
                                      _emailController.text,
                                      _passwordController.text);
                                  if (user != null) {
                                    Navigator.of(context).pop();
                                  }
                                }
                              },
                    height: 60,
                    minWidth: double.infinity,
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).appBarTheme.foregroundColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: loginProvider.isLoading || usuarioProvider.isLoading
                        ? CircularProgressIndicator(
                            color:
                                Theme.of(context).appBarTheme.foregroundColor,
                          )
                        : Text('INICIAR SESIÓN'),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider()),
                  MaterialButton(
                    disabledColor: Colors.red.shade900,
                    onPressed: loginProvider.isLoading ||
                            usuarioProvider.isLoading
                        ? null
                        : () async {
                            User? user = await loginProvider.logginGoogle();
                            if (user != null) {
                              final UserModel userLoggin =
                                  await usuarioProvider.getUserById(user.uid);
                              if (userLoggin.idUsuario == 'no-user') {
                                String userName =
                                    user.displayName ?? 'Nombre desconocido';
                                UserModel userModel = UserModel(
                                    idUsuario: user.uid,
                                    nombre: userName.split(' ').first,
                                    apellido: userName.split(' ').last,
                                    apodo: userName.split(' ').first,
                                    whatsapp: user.phoneNumber ??
                                        'Celular desconocido',
                                    email: user.email ?? 'Email desconocido',
                                    password: '******',
                                    imgUrl: user.photoURL ?? '',
                                    apariencia:
                                        AparienciaModel.aparienciaNoData(),
                                    privacidad:
                                        PrivacidadModel.privacidadNoData());

                                await usuarioProvider.createUser(userModel);
                                // usuarioProvider.setUserGlobal(userModel);
                                Navigator.of(context).pop();
                              } else {
                                // usuarioProvider.setUserGlobal(userLoggin);

                                Navigator.of(context).pop();
                              }
                            }
                          },
                    height: 60,
                    minWidth: double.infinity,
                    color: Colors.red.shade900,
                    textColor: Theme.of(context).appBarTheme.foregroundColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: ListTileTheme(
                      iconColor: Theme.of(context).appBarTheme.foregroundColor,
                      textColor: Theme.of(context).appBarTheme.foregroundColor,
                      child: loginProvider.isLoading ||
                              usuarioProvider.isLoading
                          ? CircularProgressIndicator(
                              color:
                                  Theme.of(context).appBarTheme.foregroundColor,
                            )
                          : ListTile(
                              leading: Icon(FontAwesomeIcons.google),
                              title: Text('INICIAR SESIÓN CON GOOGLE'),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
