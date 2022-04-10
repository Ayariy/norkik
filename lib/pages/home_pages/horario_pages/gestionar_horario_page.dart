import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:norkik_app/models/horario_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/horario_provider.dart';
import 'package:norkik_app/providers/norkikdb_providers/user_providers.dart';
import 'package:norkik_app/utils/alert_temp.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class GestionarHorarios extends StatefulWidget {
  const GestionarHorarios({Key? key}) : super(key: key);

  @override
  State<GestionarHorarios> createState() => _GestionarHorariosState();
}

class _GestionarHorariosState extends State<GestionarHorarios> {
  bool isLoading = false;
  List<HorarioModel> listHorario = [];

  HorarioProvider horarioProvider = HorarioProvider();

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (mounted) {
      _getListHorarios();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar tus horarios'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.calendar_view_month_outlined),
          )
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : listHorario.isEmpty
              ? Center(
                  child: Text('No hay horarios agregados'),
                )
              : RefreshIndicator(
                  onRefresh: _getListHorarios,
                  child: ListView.separated(
                    itemCount: listHorario.length,
                    itemBuilder: (context, index) {
                      return _getTile(listHorario[index]);
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, 'crearHorario')
              .then((value) => _getListHorarios());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _getTile(HorarioModel horario) {
    return ListTile(
      leading: Icon(
        horario.activo ? Icons.check_circle : Icons.check_circle_outline,
        color: horario.activo ? Theme.of(context).indicatorColor : null,
      ),
      title: Text(horario.nombre),
      subtitle: Text(horario.descripcion),
      onTap: () {
        _showHorarioDetail(horario);
      },
      trailing: IconButton(
        icon: Icon(Icons.more_vert),
        onPressed: () async {
          if ((await horarioProvider.existHorario(horario.idHorario))) {
            _showModalWidget(horario);
          } else {
            getAlert(context, 'No existe horario',
                'El horario de clases seleccionado no existe');
            _getListHorarios();
          }
        },
      ),
    );
  }

  Future<void> _getListHorarios() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
      listHorario.clear();
      final UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      List<Future<HorarioModel>> listHorarioAux =
          await horarioProvider.getHorarios((await userProvider
              .getUserReferenceById(userProvider.userGlobal.idUsuario))!);
      for (var itemHorario in listHorarioAux) {
        HorarioModel horario = await itemHorario;
        listHorario.add(horario);
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showModalWidget(HorarioModel horarioModel) {
    UserProvider userProvider = Provider.of(context, listen: false);
    showModalBottomSheet(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(),
                width: double.infinity,
                child: TextButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_box),
                      SizedBox(
                        width: 15,
                      ),
                      Text('Seleccionar este horario de clases')
                    ],
                  ),
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    DocumentReference<Map<String, dynamic>> userRef =
                        (await userProvider.getUserReferenceById(
                            userProvider.userGlobal.idUsuario))!;
                    HorarioModel horarioActivo =
                        await horarioProvider.getHorarioByActivo(true, userRef);

                    horarioActivo.activo = false;
                    await horarioProvider.updateHorario(horarioActivo, userRef);

                    horarioModel.activo = true;
                    await horarioProvider.updateHorario(horarioModel, userRef);

                    _getListHorarios();
                    Navigator.pop(context);

                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(0),
                width: double.infinity,
                height: 0.5,
                color: Theme.of(context).textTheme.bodyText1!.color,
              ),
              Container(
                decoration: const BoxDecoration(),
                width: double.infinity,
                child: TextButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.edit_outlined),
                      SizedBox(
                        width: 15,
                      ),
                      Text('Editar horario de clases')
                    ],
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, 'editarHorario',
                            arguments: horarioModel)
                        .then((value) {
                      Navigator.pop(context);
                      _getListHorarios();
                    });
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(0),
                width: double.infinity,
                height: 0.5,
                color: Theme.of(context).textTheme.bodyText1!.color,
              ),
              Container(
                decoration: const BoxDecoration(),
                width: double.infinity,
                child: TextButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.delete_forever),
                      SizedBox(
                        width: 15,
                      ),
                      Text('Eliminar horario de clases')
                    ],
                  ),
                  onPressed: () async {
                    await horarioProvider.deleteHorario(
                        horarioModel.idHorario,
                        (await horarioProvider
                            .getHorarioReferenceById(horarioModel.idHorario))!);
                    Navigator.pop(context);
                    _getListHorarios();
                  },
                ),
              ),
            ],
          );
        });
  }

  _showHorarioDetail(HorarioModel horario) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(horario.nombre),
                IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close))
              ],
            ),
            children: [
              ListTile(
                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                leading: const Icon(Icons.description),
                title: const Text('Descripción'),
                subtitle: Text(horario.descripcion),
              ),
              ListTile(
                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                leading: const Icon(Icons.date_range),
                title: const Text('Fecha de creación del horario'),
                subtitle: Text(DateFormat("EEEE, d MMMM y HH:mm", 'es')
                    .format(horario.fecha)),
              ),
              ListTile(
                visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                leading: Icon(
                  horario.activo
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color:
                      horario.activo ? Theme.of(context).indicatorColor : null,
                ),
                title: Text(horario.activo
                    ? 'Este horario de clases está activo'
                    : 'Este horario de clases no está activo'),
              )
            ],
          );
        });
  }
}
