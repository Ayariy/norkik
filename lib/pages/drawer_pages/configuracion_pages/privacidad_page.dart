import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:norkik_app/models/apariencia_model.dart';
import 'package:norkik_app/models/privacidad_model.dart';
import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/apariencia_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/privacidad_provider.dart';
import 'package:provider/provider.dart';

import '../../../providers/norkikdb_providers/user_providers.dart';

class PrivacidadSettingPage extends StatefulWidget {
  PrivacidadSettingPage({Key? key}) : super(key: key);

  @override
  State<PrivacidadSettingPage> createState() => _PrivacidadSettingPageState();
}

class _PrivacidadSettingPageState extends State<PrivacidadSettingPage> {
  bool _apodoSwitch = true;
  bool _emailSwitch = true;
  bool _whatsAppSwitch = true;

  bool isLoading = false;
  UserModel userGet = UserModel.userModelNoData();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      _getUserGlobal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => isLoading ? false : true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Privacidad'),
          actions: [
            isLoading
                ? const SizedBox()
                : Container(
                    margin: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.privacy_tip),
                          SizedBox(
                            width: 5,
                          ),
                          Text('Aplicar'),
                        ],
                      ),
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        PrivacidadProvider privacidadProvider =
                            PrivacidadProvider();
                        privacidadProvider.updatePrivacidadById(PrivacidadModel(
                            idPrivacidad: userGet.privacidad.idPrivacidad,
                            whatsapp: _whatsAppSwitch,
                            apodo: _apodoSwitch,
                            email: _emailSwitch));
                        Navigator.pop(context);
                        setState(() {
                          isLoading = false;
                        });
                      },
                    ),
                  )
          ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: [
                  SwitchListTile(
                      secondary: Icon(Icons.person_pin_outlined),
                      title: const Text('Visualizar Apodo o nickname'),
                      value: _apodoSwitch,
                      onChanged: (valor) {
                        setState(() {
                          _apodoSwitch = valor;
                        });
                      }),
                  SwitchListTile(
                      secondary: const Icon(Icons.email),
                      title: const Text('Visualizar Email'),
                      value: _emailSwitch,
                      onChanged: (valor) {
                        setState(() {
                          _emailSwitch = valor;
                        });
                      }),
                  SwitchListTile(
                      secondary: Icon(FontAwesomeIcons.whatsapp),
                      title: const Text('Visualizar WhatsApp'),
                      value: _whatsAppSwitch,
                      onChanged: (valor) {
                        setState(() {
                          _whatsAppSwitch = valor;
                        });
                      })
                ],
              ),
      ),
    );
  }

  void _getUserGlobal() async {
    isLoading = true;

    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    userGet = await userProvider
        .getUserByIdWithoutNotify(userProvider.userGlobal.idUsuario);
    _apodoSwitch = userGet.privacidad.apodo;
    _emailSwitch = userGet.privacidad.email;
    _whatsAppSwitch = userGet.privacidad.whatsapp;
    setState(() {
      isLoading = false;
    });
  }
}
