import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:norkik_app/utils/color_util.dart';

class ComunidadPage extends StatelessWidget {
  const ComunidadPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [FadeInDown(child: _cardComunidadPost(context))],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: getPrimaryColor(),
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}

Widget _cardComunidadPost(context) {
  final Size sizeScreen = MediaQuery.of(context).size;
  final card = Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      //ENCABEZADO DEL CARD HEADER
      //DESCRIPCIÒN DEL CARD NOTICIA
      _cardBody(),
      _cardImageHeader(sizeScreen),
    ],
  );

  return Container(
    margin: const EdgeInsets.all(10),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: const Color.fromRGBO(230, 230, 230, 1),
        boxShadow: const <BoxShadow>[
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
      const ListTile(
        title: Text(
          'Malkik Anrango',
          style: TextStyle(color: Colors.black),
        ),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
              'https://cloudfront-us-east-1.images.arcpublishing.com/eluniverso/RHGONLCF6VCNZAVBVD2W5INW4Q.jpeg'),
        ),
        trailing: Text('03 dic. 2021'),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
        child: const Text(
          'Voluptate elit nulla ipsum adipisicing non cillum veniam mollit non velit.',
          textAlign: TextAlign.justify,
        ),
      ),
    ],
  );
}

Widget _cardImageHeader(Size sizeScreen) {
  return Column(
    children: [
      FadeInImage(
        image: const NetworkImage(
            'https://fotoarte.com.uy/wp-content/uploads/2019/03/Landscape-fotoarte.jpg'),
        placeholder: const AssetImage('assets/loadingUno.gif'),
        fadeInDuration: const Duration(milliseconds: 200),
        height: 200.0,
        width: sizeScreen.width,
        fit: BoxFit.fill,
      ),
      Container(
        alignment: Alignment.center,
        width: sizeScreen.width,
        height: 50,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(Icons.favorite_outlined,
                  size: 35, color: Colors.red.shade600),
              Text('202'),
              SizedBox(width: 10),
              SizedBox(
                height: 35,
                width: 1,
                child: Container(
                  color: Colors.black54,
                ),
              ),
              SizedBox(width: 10),
              Icon(
                FontAwesomeIcons.whatsappSquare,
                size: 35,
                color: Colors.green.shade900,
              ),
            ],
          ),
        ),
      )
    ],
  );
}
