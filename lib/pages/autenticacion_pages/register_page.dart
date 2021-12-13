import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:norkik_app/widget/logo_theme_util.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _apellidoController = TextEditingController();
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _apodoController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _apellidoController.dispose();
    _nombreController.dispose();
    _apodoController.dispose();
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
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Bienvenido, ¡registrate!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Llena los siguientes campos para crear una cuenta',
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _nombreController,
                  validator: (value) =>
                      value!.isNotEmpty ? null : 'Porfavor ingrese su nombre',
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.badge),
                      hintText: 'Nombre',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _apellidoController,
                  validator: (value) =>
                      value!.isNotEmpty ? null : 'Porfavor ingrese su apellido',
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.assignment),
                      hintText: 'Apellido',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _apodoController,
                  validator: (value) => value!.isNotEmpty
                      ? null
                      : 'Porfavor ingrese su apodo o nickname',
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.assignment_ind),
                      hintText: 'Apodo',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Porfavor ingrese su contraseña';
                    } else if (value.contains('@') &&
                        value.contains('.') &&
                        value.endsWith('.com')) {
                      return null;
                    } else {
                      return 'Porfavor ingrese correctamente su correo';
                    }
                  },
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
                  validator: (value) => value!.length >= 5
                      ? null
                      : 'Su contraseña debe ser mayor a 5 dígitos',
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
                      print('Nombre: ' + _nombreController.text);
                      print('Apellido: ' + _apellidoController.text);
                      print('Apodo: ' + _apodoController.text);
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
                  child: Text('CREAR CUENTA'),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
