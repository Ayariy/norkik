import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:norkik_app/models/noticia_model.dart';
import 'package:intl/intl.dart';

class NoticiaPage extends StatelessWidget {
  const NoticiaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NoticiaModel noticiaModel =
        ModalRoute.of(context)!.settings.arguments as NoticiaModel;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _CustomAppBar(
            noticiaItem: noticiaModel,
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            _DescriptionAndTitle(
              noticiaItem: noticiaModel,
            )
          ]))
        ],
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  final NoticiaModel noticiaItem;
  const _CustomAppBar({Key? key, required this.noticiaItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      actions: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          child: Hero(
            tag: noticiaItem.idNoticia,
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
              'Publicado: ' + DateFormat.yMMMEd('es').format(noticiaItem.fecha),
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyText2!.fontSize),
            )),
        background: FadeInImage(
          placeholder: AssetImage('assets/loadingDos.gif'),
          image: _getImagenNoticia(noticiaItem.imagen),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  ImageProvider _getImagenNoticia(String imagenUrl) {
    if (imagenUrl == '' || imagenUrl == 'no-img') {
      return AssetImage('assets/image_coming_soon.jpg');
    } else {
      return CachedNetworkImageProvider(imagenUrl);
    }
  }
}

class _DescriptionAndTitle extends StatelessWidget {
  final NoticiaModel noticiaItem;
  const _DescriptionAndTitle({Key? key, required this.noticiaItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      child: Column(
        children: [
          Text(
            noticiaItem.titulo,
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            noticiaItem.descripcion,
            textAlign: TextAlign.justify,
          )
        ],
      ),
    );
  }
}
