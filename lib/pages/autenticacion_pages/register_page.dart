import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:norkik_app/models/apariencia_model.dart';
import 'package:norkik_app/models/privacidad_model.dart';
import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/providers/autenticacion.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/widget/logo_theme_util.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _apellidoController = TextEditingController();
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _apodoController = TextEditingController();
  TextEditingController _whatsappController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _apellidoController.dispose();
    _nombreController.dispose();
    _apodoController.dispose();
    _whatsappController.dispose();
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
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back_ios)),
                      getLogoNorkikWithTheme(context, 100),
                    ]),
                Text(
                  '¡Bienvenido a Norkik!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Llena los siguientes campos para crear una cuenta',
                ),
                SizedBox(
                  height: 25,
                ),
                TextFormField(
                  controller: _nombreController,
                  validator: (value) =>
                      value!.isNotEmpty ? null : 'Ingresa tu nombre',
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.badge),
                      hintText: 'Nombre',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: _apellidoController,
                  validator: (value) =>
                      value!.isNotEmpty ? null : 'Ingresa tu apellido',
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.assignment),
                      hintText: 'Apellido',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: _apodoController,
                  validator: (value) =>
                      value!.isNotEmpty ? null : 'Ingresa tu apodo',
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.assignment_ind),
                      hintText: 'Apodo',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  maxLength: 10,
                  controller: _whatsappController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value!.isNotEmpty) {
                      if (value.length > 9) {
                        return null;
                      } else {
                        return 'Ingrese tu número de celular';
                      }
                    } else {
                      return 'Ingresa tu número de celular';
                    }
                  },
                  decoration: InputDecoration(
                      prefixIcon: Icon(FontAwesomeIcons.whatsapp),
                      hintText: 'Número celular',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Ingresa tu correo';
                    } else if (value.contains('@') &&
                        value.contains('.') &&
                        value.endsWith('.com')) {
                      return null;
                    } else {
                      return 'Ingresa correctamente tu correo';
                    }
                  },
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      hintText: 'Correo',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: _passwordController,
                  validator: (value) => value!.length >= 5
                      ? null
                      : 'Tu contraseña debe ser mayor a 5 dígitos',
                  obscureText: true,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.vpn_key),
                      hintText: 'Contraseña',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(
                  height: 15,
                ),
                MaterialButton(
                    disabledColor: Theme.of(context).primaryColor,
                    onPressed: loginProvider.isLoading ||
                            usuarioProvider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              UserModel userModel = UserModel(
                                  idUsuario: '',
                                  nombre: _nombreController.text,
                                  apellido: _apellidoController.text,
                                  apodo: _apodoController.text,
                                  whatsapp: _whatsappController.text,
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                  imgUrl: '',
                                  apariencia:
                                      AparienciaModel.aparienciaNoData(),
                                  privacidad:
                                      PrivacidadModel.privacidadNoData());
                              User? user =
                                  await loginProvider.registerUser(userModel);
                              if (user != null) Navigator.of(context).pop();
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
                        : Text('CREAR CUENTA')),
                if (loginProvider.errorMessage != "")
                  Container(
                    margin: EdgeInsets.only(top: 25),
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
              ],
            ),
          ),
        ),
      )),
    );
  }
}
