import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class NoticiasPage extends StatelessWidget {
  const NoticiasPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          FadeInDown(child: _cardNoticiaPost(context)),
          FadeInDown(child: _cardNoticiaPost(context)),
          FadeInDown(child: _cardNoticiaPost(context)),
        ],
      ),
    );
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
          color: Color.fromRGBO(230, 230, 230, 1),
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
              Icon(
                Icons.star_outlined,
                color: Colors.yellow.shade800,
                size: 40,
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
          color: Colors.black54,
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
