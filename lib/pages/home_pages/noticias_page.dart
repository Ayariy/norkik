import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:norkik_app/models/noticia_model.dart';
import 'package:norkik_app/providers/norkikdb_providers/noticia_provider.dart';

class NoticiasPage extends StatefulWidget {
  const NoticiasPage({Key? key}) : super(key: key);

  @override
  State<NoticiasPage> createState() => _NoticiasPageState();
}

class _NoticiasPageState extends State<NoticiasPage> {
  bool selectedIconStar = true;
  probando() async {
    NoticiaProvider noticiaProvider = NoticiaProvider();
    List<NoticiaModel> noticias = await noticiaProvider.getNoticias();
    noticias.forEach((element) {
      print(element.fecha);
    });
  }

  @override
  Widget build(BuildContext context) {
    probando();
    return Scaffold(body: ListView.builder(itemBuilder: (context, int) {
      return FadeInDown(child: _cardNoticiaPost(context));
    }));
  }

  Widget _cardNoticiaPost(context) {
    final Size sizeScreen = MediaQuery.of(context).size;
    final card = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //ENCABEZADO DEL CARD HEADER
        _cardImageHeader(sizeScreen),
        //DESCRIPCIÒN DEL CARD NOTICIA
        _cardBody(),
      ],
    );

    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Theme.of(context).cardColor,
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black26,
                blurRadius: 5.0,
                spreadRadius: 2.0,
                offset: Offset(2.0, 4.0))
          ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: card,
      ),
    );
  }

  Column _cardBody() {
    return Column(
      children: [
        Container(
            padding: EdgeInsets.all(10.0),
            child: Text(
                'La Universidad Politécnica Estatal del Carchi (UPEC) y el Gobierno Autónomo Descentralizado Municipal de Mon La Universidad Politécnica Estatal del Carchi (UPEC) fue el escenario del Primer Seminario “Cultivo de Café',
                textAlign: TextAlign.justify)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    selectedIconStar = !selectedIconStar;
                  });
                },
                icon: Icon(selectedIconStar ? Icons.star : Icons.star_border),
                color: Colors.yellow.shade800,
                iconSize: 40,
              ),
              Text('02 dic. 2021')
            ],
          ),
        ),
      ],
    );
  }

  Stack _cardImageHeader(Size sizeScreen) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        FadeInImage(
          image: NetworkImage(
              'https://fotoarte.com.uy/wp-content/uploads/2019/03/Landscape-fotoarte.jpg'),
          placeholder: AssetImage('assets/loadingUno.gif'),
          fadeInDuration: Duration(milliseconds: 200),
          height: 200.0,
          width: sizeScreen.width,
          fit: BoxFit.fill,
        ),
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Colors.black.withAlpha(0),
              Colors.black38,
              Colors.black45,
              Colors.black54,
              Colors.black54
            ],
          )),
          width: sizeScreen.width,
          height: 50,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'EQUIPOS UPEC – YACHAY OBTUVIERON SEGUNDO Y TERCER LUGAR EN RALLY DE INNOVACIÓN',
              style: TextStyle(
                  color: Colors.white, overflow: TextOverflow.ellipsis),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        )
      ],
    );
  }
}
