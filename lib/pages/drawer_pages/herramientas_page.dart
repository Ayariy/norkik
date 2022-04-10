import 'package:flutter/material.dart';

class HerramientasPage extends StatelessWidget {
  HerramientasPage({Key? key}) : super(key: key);

  final listItems = [
    ItemHerramientas(
        titulo: 'Conversión de imagen a texto',
        descripcion: 'OCR',
        rutaName: 'ocr',
        iconData: Icons.image_search_sharp),
    ItemHerramientas(
        titulo: 'Escáner',
        descripcion: 'Cámara escáner',
        rutaName: 'scan',
        iconData: Icons.scanner),
    ItemHerramientas(
        titulo: 'Lector QR',
        descripcion: 'Lector QR',
        rutaName: 'qr',
        iconData: Icons.qr_code_2),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Herramientas digitales'),
        ),
        body: ListView.separated(
            itemBuilder: (context, index) {
              return ListTile(
                  title: Text(listItems[index].titulo),
                  subtitle: Text(listItems[index].descripcion),
                  leading: Icon(listItems[index].iconData),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {
                    Navigator.pushNamed(context, listItems[index].rutaName);
                  });
            },
            separatorBuilder: (_, __) {
              return const Divider();
            },
            itemCount: listItems.length));
  }
}

class ItemHerramientas {
  String titulo;
  String descripcion;
  IconData iconData;
  String rutaName;

  ItemHerramientas(
      {required this.titulo,
      required this.descripcion,
      required this.rutaName,
      required this.iconData});
}
