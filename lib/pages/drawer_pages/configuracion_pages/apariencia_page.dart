import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:norkik_app/models/apariencia_model.dart';
import 'package:norkik_app/models/user_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/apariencia_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/providers/theme.dart';
import 'package:norkik_app/utils/theme_data.dart';
import 'package:provider/provider.dart';

class AparienciaSettingPage extends StatefulWidget {
  const AparienciaSettingPage({Key? key}) : super(key: key);

  @override
  State<AparienciaSettingPage> createState() => _AparienciaSettingPageState();
}

class _AparienciaSettingPageState extends State<AparienciaSettingPage> {
  int indexPage = 0;

  String _fontSelected = 'OscuroTheme';
  String _temaSelected = 'NorkikTheme';

  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff2a4a4d);

  // final List<String> _opcionesFonts = [
  //   'Defecto',
  //   'Roboto',
  //   'Smooch',
  //   'League Script',
  //   'Abhaya Libre',
  //   'Aclonica',
  //   'Acme',
  //   'Akronim',
  //   'Aladin',
  //   'Alata',
  //   'Almendra',
  //   'Allison',
  //   'Megrim',
  //   'Oxanium',
  //   'Russo One',
  //   'Outfit',
  //   'Langar',
  //   'Atma',
  //   'Merienda',
  //   'Comic Neue'
  // ];

  final List<String> _opcionesFonts = [
    'Defecto',
  ];

  final List<String> _opcionesTema = [
    'NorkikTheme',
    'DarkTheme',
    'Personalizado',
    'OscuroTheme',
    'VerdeTheme',
    'RosadoTheme',
    'GrisTheme',
    'AzulTheme',
    'AmarilloTheme',
    'RojoTheme',
    'CafeTheme',
    'NaranjaTheme',
  ];
  final Map<String, Color> _opcionesTemaColor = {
    'NorkikTheme': Color.fromRGBO(42, 74, 77, 1),
    'DarkTheme': Colors.grey.shade900,
    'OscuroTheme': Colors.black,
    'VerdeTheme': Colors.teal.shade900,
    'RosadoTheme': Colors.pink.shade700,
    'GrisTheme': Colors.grey.shade700,
    'AzulTheme': Colors.indigo.shade900,
    'AmarilloTheme': Colors.lime.shade900,
    'RojoTheme': Colors.red.shade900,
    'CafeTheme': Colors.brown.shade800,
    'NaranjaTheme': Colors.amber.shade900,
  };

  bool isLoadingPerfil = false;
  UserModel userGet = UserModel.userModelNoData();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      GoogleFonts.asMap().keys.toList().forEach((value) {
        _opcionesFonts.add(value);
      });
      _getUserGlobal();

      // print(GoogleFonts.asMap().keys);
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (mounted) {
      currentColor = Theme.of(context).primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeChanger themeChanger = Provider.of<ThemeChanger>(context);

    return WillPopScope(
      onWillPop: () async {
        return isLoadingPerfil ? false : true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Apariencia'),
        ),
        body: isLoadingPerfil
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : indexPage == 0
                ? _getListSettingAparienciaTema()
                : _getListSettingAparienciaFuente(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: indexPage,
          onTap: (valuePage) {
            setState(() {
              indexPage = valuePage;
            });
          },
          elevation: 0,
          items: [
            BottomNavigationBarItem(
                label: 'Tema', icon: Icon(Icons.format_color_fill_rounded)),
            BottomNavigationBarItem(
                label: 'Tipo de fuente',
                icon: Icon(Icons.font_download_rounded))
          ],
        ),
        floatingActionButton: isLoadingPerfil
            ? const SizedBox()
            : FloatingActionButton(
                onPressed: () {
                  setState(() {
                    isLoadingPerfil = true;
                  });

                  if (_temaSelected == 'DarkTheme') {
                    themeChanger.setTheme(getDarkTheme(
                        _fontSelected == 'Defecto'
                            ? null
                            : GoogleFonts.getTextTheme(
                                _fontSelected, ThemeData.dark().textTheme)));
                  } else if (_temaSelected == 'Personalizado') {
                    themeChanger.setTheme(getColorTheme(
                        currentColor,
                        _fontSelected == 'Defecto'
                            ? null
                            : GoogleFonts.getTextTheme(_fontSelected)));
                  } else {
                    themeChanger.setTheme(getColorTheme(
                        _opcionesTemaColor[_temaSelected]!,
                        _fontSelected == 'Defecto'
                            ? null
                            : GoogleFonts.getTextTheme(_fontSelected)));
                  }

                  AparienciaProvider aparienciaProvider = AparienciaProvider();
                  AparienciaModel aparienciaModel = userGet.apariencia;
                  aparienciaModel.font = _fontSelected;
                  aparienciaModel.tema = _temaSelected == 'Personalizado'
                      ? 'Personalizado${currentColor.value}'
                      : _temaSelected;
                  aparienciaProvider.updateAparienciaById(aparienciaModel);
                  setState(() {
                    isLoadingPerfil = false;
                  });
                },
                child: Icon(Icons.color_lens),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  _getListSettingAparienciaTema() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Text(
            'Tema de la app',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
          ),
        ),
        const Divider(),
        Expanded(
            child: ListView.builder(
          itemCount: _opcionesTema.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: _opcionesTema[index] == 'Personalizado'
                  ? () {
                      _showSelectColor();
                    }
                  : null,
              subtitle: _opcionesTema[index] == 'Personalizado'
                  ? const Text('¡Elije tu color favorito!')
                  : _opcionesTema[index] == 'NorkikTheme'
                      ? const Text('Tema por defecto')
                      : _opcionesTema[index] == 'DarkTheme'
                          ? const Text('Tema oscuro o nocturno')
                          : null,
              leading: Radio(
                value: _opcionesTema[index],
                groupValue: _temaSelected,
                onChanged: (value) {
                  setState(() {
                    _temaSelected = value as String;
                  });
                },
              ),
              title: Text(_opcionesTema[index]),
              trailing: _opcionesTema[index] == 'Personalizado'
                  ? Icon(Icons.format_color_fill, color: currentColor)
                  : Icon(
                      Icons.format_color_fill,
                      color: _opcionesTemaColor[_opcionesTema[index]],
                    ),
            );
          },
        )),
      ],
    );
  }

  _getListSettingAparienciaFuente() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Text(
            'Tipo de fuente',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
          ),
        ),
        const Divider(),
        Expanded(
            child: ListView.builder(
          itemCount: _opcionesFonts.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Radio(
                value: _opcionesFonts[index],
                groupValue: _fontSelected,
                onChanged: (value) {
                  setState(() {
                    _fontSelected = value as String;
                  });
                },
              ),
              title: Text(
                _opcionesFonts[index],
                style: _opcionesFonts[index] == 'Defecto'
                    ? null
                    : GoogleFonts.getFont(_opcionesFonts[index]),
              ),
              trailing: Icon(Icons.font_download),
            );
          },
        ))
      ],
    );
  }

  void _getUserGlobal() async {
    isLoadingPerfil = true;

    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    userGet = await userProvider
        .getUserByIdWithoutNotify(userProvider.userGlobal.idUsuario);

    _fontSelected = userGet.apariencia.font;
    _temaSelected = userGet.apariencia.tema.contains('Personalizado')
        ? 'Personalizado'
        : userGet.apariencia.tema;
    setState(() {
      isLoadingPerfil = false;
    });
  }

  void _showSelectColor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: SlidePicker(
              pickerColor: pickerColor,
              colorModel: ColorModel.rgb,
              enableAlpha: false,
              indicatorBorderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25)),
              onColorChanged: (value) {
                setState(() {
                  pickerColor = value;
                });
              },
              // enableLabel: true, // only on portrait mode
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Seleccionar'),
              onPressed: () {
                setState(() => currentColor = pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
