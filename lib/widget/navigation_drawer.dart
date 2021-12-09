import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _getDrawerHeader(context),
          _getDrawerListView(context),
        ],
      ),
    );
  }

  Expanded _getDrawerListView(BuildContext context) {
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
          const Divider(
            color: Colors.white30,
          ),
          _getItemTile(
              Icons.settings, 'Configuración', 'configuracion', context),
          _getItemTile(Icons.person_pin, 'Perfil', 'perfil', context),
          const Divider(
            color: Colors.white30,
          ),
          _getItemTile(
              Icons.camera_rounded, 'Herramientas', 'herramientas', context),
          const Divider(color: Colors.white30),
          ListTile(
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
                  child: const Text(
                    '"Tu agenda inteligente"',
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          )
        ],
      ),
    ));
  }

  SizedBox _getDrawerHeader(context) {
    return SizedBox(
      height: 220,
      child: FadeInDown(
        child: DrawerHeader(
          child: UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.transparent),
            currentAccountPicture: ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: const FadeInImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                    'https://dthezntil550i.cloudfront.net/f4/latest/f41908291942413280009640715/1280_960/1b2d9510-d66d-43a2-971a-cfcbb600e7fe.png'),
                placeholder: AssetImage('assets/loadingDos.gif'),
              ),
            ),
            accountName: Text('Malkik Anrango'),
            accountEmail: Text('salvadormalkik@gmail.com'),
            onDetailsPressed: () {
              Navigator.pushNamed(context, 'perfil');
            },
          ),
          // FadeInImage(
          //     fit: BoxFit.fill,
          //     placeholder: AssetImage('assets/loadingUno.gif'),
          //     image: NetworkImage(
          //         'https://dthezntil550i.cloudfront.net/f4/latest/f41908291942413280009640715/1280_960/1b2d9510-d66d-43a2-971a-cfcbb600e7fe.png')),

          //     CircleAvatar(
          //   backgroundImage: NetworkImage(
          //       'https://dthezntil550i.cloudfront.net/f4/latest/f41908291942413280009640715/1280_960/1b2d9510-d66d-43a2-971a-cfcbb600e7fe.png'),
          // ),
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
        color: Colors.white,
      ),
      title: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {
        Navigator.pushNamed(context, ruta);
      },
    );
  }
}
