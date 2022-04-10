import 'package:flutter/material.dart';

class ConfiguracionPage extends StatelessWidget {
  ConfiguracionPage({Key? key}) : super(key: key);
  final List<IconSetting> listIconSetting = [
    IconSetting(
        title: 'General',
        subtitle: '',
        iconData: Icons.settings,
        rutaName: 'generalSetting'),
    IconSetting(
        title: 'Apariencia',
        subtitle: '',
        iconData: Icons.color_lens_sharp,
        rutaName: 'aparienciaSetting'),
    IconSetting(
        title: 'Horario',
        subtitle: '',
        iconData: Icons.calendar_view_month,
        rutaName: 'gestionarHorario'),
    IconSetting(
        title: 'Acerca de',
        subtitle: '',
        iconData: Icons.info,
        rutaName: 'acercaSetting'),
    IconSetting(
        title: 'Privacidad',
        subtitle: '',
        iconData: Icons.privacy_tip,
        rutaName: 'privacidadSetting'),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Configuración'),
        ),
        body: ListView.separated(
            itemBuilder: (context, index) {
              return _getTileSetting(context, listIconSetting[index]);
            },
            separatorBuilder: (context, index) => Divider(),
            itemCount: listIconSetting.length));
  }

  ListTile _getTileSetting(BuildContext context, IconSetting iconSetting) {
    return ListTile(
      title: Text(iconSetting.title),
      // subtitle: Text(subtitle),
      leading: Icon(iconSetting.iconData),
      trailing: Icon(Icons.arrow_forward_ios_rounded),
      onTap: () {
        Navigator.pushNamed(context, iconSetting.rutaName);
      },
    );
  }
}

class IconSetting {
  String title;
  String subtitle;
  IconData iconData;
  String rutaName;

  IconSetting(
      {required this.title,
      required this.subtitle,
      required this.iconData,
      required this.rutaName});
}
