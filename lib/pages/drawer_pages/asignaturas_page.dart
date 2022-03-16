import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:norkik_app/models/asignatura_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/asignatura_provider.dart';
import 'package:norkik_app/providers/storage_shared.dart';
import 'package:norkik_app/widget/charts_lineal.dart';

class AsignaturasPage extends StatefulWidget {
  const AsignaturasPage({Key? key}) : super(key: key);

  @override
  State<AsignaturasPage> createState() => _AsignaturasPageState();
}

class _AsignaturasPageState extends State<AsignaturasPage> {
  AsignaturaProvider asignaturaProvider = AsignaturaProvider();
  StorageShared storageShared = StorageShared();

  bool isLoading = false;
  bool isSecondAppbarSelection = false;

  List<AsignaturaModel> listAsignatura = [];
  List<AsignaturaModel> listAsignaturaRespaldo = [];
  Map<String, dynamic> mapColors = {};

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _getListAsignatura();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isSecondAppbarSelection
          ? AppBar(
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    isSecondAppbarSelection = false;
                    listAsignatura = listAsignaturaRespaldo;
                  });
                },
              ),
              title: TextField(
                autofocus: true,
                decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    hintText: 'Buscar',
                    hintStyle: TextStyle(
                        color: Theme.of(context).appBarTheme.foregroundColor)),
                style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor),
                onChanged: (text) {
                  _searchAsignaturas(text);
                },
              ),
            )
          : AppBar(
              title: Text('Asignaturas'),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        isSecondAppbarSelection = true;
                      });
                    },
                    icon: Icon(Icons.search))
              ],
            ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : listAsignatura.isEmpty
              ? Center(
                  child: Text('Aún no existe registros de asignaturas'),
                )
              : RefreshIndicator(
                  onRefresh: _getListAsignatura,
                  child: ListView.separated(
                      itemBuilder: (context, index) {
                        return _listTileAsignatura(listAsignatura[index]);
                      },
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: listAsignatura.length),
                ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        overlayOpacity: 0.3,
        spacing: 10,
        children: [
          SpeedDialChild(
              label: 'Mostar mis asignaturas del horario de clases',
              child: const Icon(Icons.class__outlined),
              onTap: () {
                _getMisAsignaturas();
              }),
          SpeedDialChild(
              label: 'Mostrar todas las asignaturas',
              child: const Icon(Icons.class_),
              onTap: () {
                setState(() {
                  listAsignatura = listAsignaturaRespaldo;
                });
              }),
          SpeedDialChild(
              label: 'Agregar nueva Asignatura',
              child: const Icon(Icons.add),
              onTap: () {
                Navigator.pushNamed(context, 'crearAsignatura')
                    .then((value) => _getListAsignatura());
              }),
        ],
      ),
    );
  }

  _getMisAsignaturas() {
    setState(() {
      isLoading = true;
    });
    listAsignatura = listAsignaturaRespaldo
        .where((element) => mapColors.containsKey(element.idAsignatura))
        .toList();
    setState(() {
      isLoading = false;
    });
  }

  _searchAsignaturas(String nombreAsignatura) {
    setState(() {
      isLoading = true;
    });
    listAsignatura = listAsignaturaRespaldo
        .where((element) => element.nombre
            .toLowerCase()
            .contains(nombreAsignatura.toLowerCase()))
        .toList();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getListAsignatura() async {
    setState(() {
      isLoading = true;
    });
    listAsignatura.clear();
    listAsignaturaRespaldo.clear();

    List<Future<AsignaturaModel>> listAsignaturaAux =
        await asignaturaProvider.getAsignaturas();
    for (var itemAsignatura in listAsignaturaAux) {
      AsignaturaModel asignatura = await itemAsignatura;
      listAsignatura.add(asignatura);
    }
    listAsignatura.sort((a, b) => a.nombre.compareTo(b.nombre));
    listAsignaturaRespaldo = listAsignatura;
    mapColors = await storageShared.obtenerColoresAsignaturaList();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _listTileAsignatura(AsignaturaModel asignaturaModel) {
    return ListTile(
      leading: Icon(
        Icons.class_,
        color: mapColors[asignaturaModel.idAsignatura] != null
            ? Color(mapColors[asignaturaModel.idAsignatura])
            : null,
      ),
      title: Text(asignaturaModel.nombre),
      subtitle: Text("Msc. " +
          asignaturaModel.docente.nombre +
          " " +
          asignaturaModel.docente.apellido),
      trailing: const Icon(Icons.arrow_forward_ios_rounded),
      onTap: () {
        Navigator.pushNamed(context, 'verAsignatura',
            arguments: asignaturaModel);
      },
    );
  }
}
