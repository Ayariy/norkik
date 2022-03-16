import 'package:flutter/material.dart';
import 'package:norkik_app/models/docente_model.dart';

class VerDocente extends StatefulWidget {
  VerDocente({Key? key}) : super(key: key);

  @override
  State<VerDocente> createState() => _VerDocenteState();
}

class _VerDocenteState extends State<VerDocente> {
  DocenteModel? docenteModel;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    docenteModel = ModalRoute.of(context)!.settings.arguments as DocenteModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: docenteModel == null
          ? Center(
              child: Text('No se ha seleccionado el docente a visualizar'),
            )
          : CustomScrollView(
              slivers: [
                _CustomAppBar(docenteModel!),
                SliverList(
                    delegate: SliverChildListDelegate([
                  _bodySliver(
                    docenteModel!,
                  )
                ]))
              ],
            ),
    );
  }

  Widget _CustomAppBar(DocenteModel docenteModel) {
    return SliverAppBar(
      actions: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          child: Hero(
            tag: docenteModel.idDocente,
            child: FadeInImage(
                placeholder: AssetImage('assets/loadingDos.gif'),
                image: AssetImage('assets/upec.png')),
          ),
        )
      ],
      expandedHeight: 300,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.zero,
          centerTitle: true,
          title: Container(
              color: Colors.black38,
              width: double.infinity,
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Msc. ' + docenteModel.nombre + " " + docenteModel.apellido,
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyText2!.fontSize),
              )),
          background: Container(
            color: Theme.of(context).primaryColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  docenteModel.nombre[0] + docenteModel.apellido[0],
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.5),
                ),
              ],
            ),
          )),
    );
  }

  Widget _bodySliver(DocenteModel docenteModel) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Theme.of(context).cardColor,
          boxShadow: const <BoxShadow>[
            BoxShadow(
                color: Colors.black26,
                blurRadius: 5.0,
                spreadRadius: 2.0,
                offset: Offset(2.0, 4.0))
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Nombre y Apellido'),
              subtitle: Text(docenteModel.nombre + " " + docenteModel.apellido),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Correo electrónico'),
              subtitle: Text(docenteModel.email),
            ),
          ],
        ),
      ),
    );
  }
}
