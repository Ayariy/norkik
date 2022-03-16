import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:norkik_app/models/docente_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/docente_provider.dart';

class DocentesPage extends StatefulWidget {
  DocentesPage({Key? key}) : super(key: key);

  @override
  State<DocentesPage> createState() => _DocentesPageState();
}

class _DocentesPageState extends State<DocentesPage> {
  DocenteProvider docenteProvider = DocenteProvider();

  bool isLoading = false;
  List<DocenteModel> listDocentes = [];

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _getListDocentes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doncentes'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : listDocentes.isEmpty
              ? Center(
                  child: Text('Aún no existe registros de docentes'),
                )
              : ListView.separated(
                  itemBuilder: (context, index) {
                    return _listTileDocente(listDocentes[index]);
                  },
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: listDocentes.length),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        overlayOpacity: 0.3,
        spacing: 10,
        children: [
          SpeedDialChild(
              label: 'Agregar nuevo docente',
              child: const Icon(Icons.add),
              onTap: () {
                Navigator.pushNamed(context, 'crearDocente').then((value) {
                  _getListDocentes();
                });
              }),
        ],
      ),
    );
  }

  Widget _listTileDocente(DocenteModel docenteModel) {
    return ListTile(
      leading: Hero(
        tag: docenteModel.idDocente,
        child: CircleAvatar(
          child: Text(docenteModel.nombre[0] + docenteModel.apellido[0]),
        ),
      ),
      title: Text(docenteModel.nombre + " " + docenteModel.apellido),
      subtitle: Text(docenteModel.email),
      onTap: () {
        Navigator.pushNamed(context, 'verDocente', arguments: docenteModel);
      },
    );
  }

  _getListDocentes() async {
    isLoading = true;
    listDocentes = await docenteProvider.getDocentes();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}
