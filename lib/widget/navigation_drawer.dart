import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import 'package:norkik_app/providers/autenticacion.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/providers/theme.dart';
import 'package:norkik_app/utils/theme_data.dart';
import 'package:provider/provider.dart';

class NavigationDrawer extends StatelessWidget {
  NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _getDrawerHeader(context),
            _getDrawerListView(context),
          ],
        ),
      ),
    );
  }

  Widget _getDrawerListView(BuildContext context) {
    final themeChanger = Provider.of<ThemeChanger>(context);
    final loginProvider = Provider.of<AuthProvider>(context);

    return Expanded(
        child: FadeInLeft(
      child: ListView(
        children: [
          _getItemTile(Icons.menu_book_sharp, 'Notas - Cuaderno digital',
              'notas', context),
          _getItemTile(Icons.home_work_outlined, 'Tareas', 'tareas', context),
          _getItemTile(
              Icons.note_alt_outlined, 'Asignaturas', 'asignaturas', context),
          _getItemTile(
              Icons.people_alt_outlined, 'Docentes', 'docentes', context),
          Divider(
            color:
                Theme.of(context).appBarTheme.foregroundColor!.withOpacity(0.5),
          ),
          _getItemTile(
              Icons.settings, 'Configuración', 'configuracion', context),
          _getItemTile(Icons.person_pin, 'Perfil', 'perfil', context),
          Divider(
            color:
                Theme.of(context).appBarTheme.foregroundColor!.withOpacity(0.5),
          ),
          _getItemTile(
              Icons.camera_rounded, 'Herramientas', 'herramientas', context),
          Divider(
            color:
                Theme.of(context).appBarTheme.foregroundColor!.withOpacity(0.5),
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            title: Text(
              "Cerrar sesión",
              style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor),
            ),
            onTap: () {
              loginProvider.logout();
            },
          ),
          Divider(
              color: Theme.of(context)
                  .appBarTheme
                  .foregroundColor!
                  .withOpacity(0.5)),
          GestureDetector(
            onTap: () {
              if (Brightness.light == Theme.of(context).brightness) {
                themeChanger.setTheme(getDarkTheme());
              } else {
                themeChanger.setTheme(getNorkikTheme());
              }
            },
            child: ListTile(
              title: Column(
                children: const [
                  FadeInImage(
                      fit: BoxFit.cover,
                      width: 200,
                      placeholder: AssetImage('assets/loadingDos.gif'),
                      image: AssetImage('assets/NorkikBlanco.png')),
                ],
              ),
              subtitle: Center(
                child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      '"Tu agenda inteligente"',
                      style: TextStyle(
                          color: Theme.of(context).appBarTheme.foregroundColor),
                    )),
              ),
            ),
          )
        ],
      ),
    ));
  }

  SizedBox _getDrawerHeader(context) {
    final usuarioProvider = Provider.of<UserProvider>(context);
    return SizedBox(
      height: 220,
      child: FadeInDown(
        child: DrawerHeader(
          child: UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.transparent),
            currentAccountPicture: ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: FadeInImage(
                fit: BoxFit.cover,
                image: _getUserImg(usuarioProvider),
                placeholder: AssetImage('assets/loadingDos.gif'),
              ),
            ),
            accountName: Text(usuarioProvider.userGlobal.nombre +
                ' ' +
                usuarioProvider.userGlobal.apellido),
            accountEmail: Text(usuarioProvider.userGlobal.email),
            onDetailsPressed: () {
              // usuarioProvider.setUserGlobal(UserModel.userModelNoData());
              Navigator.pushNamed(context, 'perfil');
            },
          ),
          decoration: const BoxDecoration(
            image: DecorationImage(
                colorFilter:
                    ColorFilter.mode(Colors.black45, BlendMode.colorBurn),
                scale: 20.0,
                image: AssetImage('assets/UPEC.jpg'),
                fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _getItemTile(
      IconData icon, String text, String ruta, BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).appBarTheme.foregroundColor,
      ),
      title: Text(
        text,
        style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor),
      ),
      onTap: () {
        Navigator.pushNamed(context, ruta);
      },
    );
  }

  ImageProvider<Object> _getUserImg(UserProvider usuarioProvider) {
    if (usuarioProvider.userGlobal.imgUrl == '' ||
        usuarioProvider.userGlobal.imgUrl == 'no-img') {
      return AssetImage('assets/user.png');
    } else {
      return CachedNetworkImageProvider(usuarioProvider.userGlobal.imgUrl);
    }
  }
}
